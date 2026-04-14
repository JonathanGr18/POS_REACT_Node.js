const pool = require('../config/db');

// Helpers de validacion
const validarString = (val, max, { requerido = false, campo = 'campo' } = {}) => {
  if (val == null || val === '') {
    if (requerido) throw Object.assign(new Error(`${campo} es requerido`), { status: 400 });
    return null;
  }
  if (typeof val !== 'string') {
    throw Object.assign(new Error(`${campo} inválido`), { status: 400 });
  }
  const limpio = val.replace(/\x00/g, '').trim();
  if (limpio === '' && requerido) throw Object.assign(new Error(`${campo} es requerido`), { status: 400 });
  if (limpio.length > max) throw Object.assign(new Error(`${campo} demasiado largo (máx ${max})`), { status: 400 });
  return limpio;
};

const validarEntero = (val, { min = null, max = null, requerido = true, campo = 'campo' } = {}) => {
  if (val == null || val === '') {
    if (requerido) throw Object.assign(new Error(`${campo} es requerido`), { status: 400 });
    return null;
  }
  const n = Number(val);
  if (!Number.isInteger(n)) throw Object.assign(new Error(`${campo} debe ser entero`), { status: 400 });
  if (min != null && n < min) throw Object.assign(new Error(`${campo} debe ser >= ${min}`), { status: 400 });
  if (max != null && n > max) throw Object.assign(new Error(`${campo} debe ser <= ${max}`), { status: 400 });
  return n;
};

const validarDecimal = (val, { min = null, max = null, campo = 'campo' } = {}) => {
  if (val == null || val === '') return null;
  const n = Number(val);
  if (!Number.isFinite(n)) throw Object.assign(new Error(`${campo} inválido`), { status: 400 });
  if (min != null && n < min) throw Object.assign(new Error(`${campo} debe ser >= ${min}`), { status: 400 });
  if (max != null && n > max) throw Object.assign(new Error(`${campo} debe ser <= ${max}`), { status: 400 });
  return n;
};

// GET /lista-compras — items agrupados por tienda
const getLista = async (req, res, next) => {
  try {
    const result = await pool.query(`
      SELECT lc.*, t.nombre AS nombre_tienda, t.direccion AS direccion_tienda
      FROM lista_compras lc
      LEFT JOIN tiendas t ON t.id = lc.tienda_id
      ORDER BY t.nombre ASC, lc.completado ASC, lc.created_at ASC
    `);
    res.json(result.rows);
  } catch (err) {
    next(err);
  }
};

// POST /lista-compras — agregar item
const addItem = async (req, res, next) => {
  try {
    const body = req.body || {};
    const nombre_producto = validarString(body.nombre_producto, 200, { requerido: true, campo: 'Nombre del producto' });
    const cantidad = validarEntero(body.cantidad ?? 1, { min: 1, max: 100000, campo: 'Cantidad' });
    const tienda_id = body.tienda_id != null && body.tienda_id !== ''
      ? validarEntero(body.tienda_id, { min: 1, campo: 'tienda_id' })
      : null;
    const precio_ref = validarDecimal(body.precio_ref, { min: 0, max: 999999.99, campo: 'Precio ref' });
    const notas = validarString(body.notas, 500, { campo: 'Notas' });

    // Validar que la tienda exista (evita FK error 500)
    if (tienda_id != null) {
      const existe = await pool.query('SELECT id FROM tiendas WHERE id = $1', [tienda_id]);
      if (existe.rowCount === 0) {
        return res.status(400).json({ error: `La tienda con id ${tienda_id} no existe` });
      }
    }

    const result = await pool.query(
      `INSERT INTO lista_compras (tienda_id, nombre_producto, cantidad, precio_ref, notas)
       VALUES ($1, $2, $3, $4, $5) RETURNING *`,
      [tienda_id, nombre_producto, cantidad, precio_ref, notas]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    if (err.status) return res.status(err.status).json({ error: err.message });
    // Codigo 23503 = foreign_key_violation (defensa en profundidad)
    if (err.code === '23503') return res.status(400).json({ error: 'Referencia invalida' });
    next(err);
  }
};

// PATCH /lista-compras/:id/toggle — marcar/desmarcar completado
const toggleItem = async (req, res, next) => {
  try {
    const id = parseInt(req.params.id, 10);

    if (!id || isNaN(id)) {
      const err = new Error('ID de item inválido');
      err.status = 400;
      return next(err);
    }

    const result = await pool.query(
      'UPDATE lista_compras SET completado = NOT completado WHERE id=$1 RETURNING *',
      [id]
    );

    if (result.rows.length === 0) {
      const err = new Error('Item no encontrado');
      err.status = 404;
      return next(err);
    }
    res.json(result.rows[0]);
  } catch (err) {
    next(err);
  }
};

// DELETE /lista-compras/:id — eliminar item
const deleteItem = async (req, res, next) => {
  try {
    const id = parseInt(req.params.id, 10);

    if (!id || isNaN(id)) {
      const err = new Error('ID de item inválido');
      err.status = 400;
      return next(err);
    }

    const result = await pool.query(
      'DELETE FROM lista_compras WHERE id=$1 RETURNING id',
      [id]
    );

    if (result.rows.length === 0) {
      const err = new Error('Item no encontrado');
      err.status = 404;
      return next(err);
    }
    res.json({ message: 'Item eliminado correctamente', id });
  } catch (err) {
    next(err);
  }
};

// PATCH /lista-compras/:id — actualizar cantidad y/o notas de un item
const updateItem = async (req, res, next) => {
  const { id } = req.params;
  const { cantidad, notas } = req.body || {};

  if (!id || isNaN(parseInt(id, 10))) {
    return res.status(400).json({ error: 'ID inválido' });
  }
  if (cantidad === undefined && notas === undefined) {
    return res.status(400).json({ error: 'Se requiere al menos un campo (cantidad o notas)' });
  }
  let cantidadValida = null;
  if (cantidad !== undefined) {
    try { cantidadValida = validarEntero(cantidad, { min: 1, max: 100000, campo: 'Cantidad' }); }
    catch (e) { return res.status(400).json({ error: e.message }); }
  }
  // Validar notas si viene (puede ser null/'' para borrar)
  if (notas !== undefined && notas !== null) {
    try { validarString(notas, 500, { campo: 'Notas' }); }
    catch (e) { return res.status(400).json({ error: e.message }); }
  }

  try {
    // BUG #6 FIX: usar actualización condicional por columna en lugar de COALESCE, de modo que
    // enviar notas: null explícitamente borre las notas en lugar de mantener el valor anterior.
    const result = await pool.query(
      `UPDATE lista_compras SET
        cantidad = CASE WHEN $1::int IS NOT NULL THEN $1::int ELSE cantidad END,
        notas    = CASE WHEN $2::boolean THEN $3 ELSE notas END
       WHERE id = $4 RETURNING *`,
      [
        cantidadValida,
        notas !== undefined,
        notas !== undefined ? (notas == null ? null : String(notas).slice(0, 500)) : null,
        parseInt(id, 10)
      ]
    );
    if (result.rowCount === 0) {
      const err = new Error('Item no encontrado');
      err.status = 404;
      return next(err);
    }
    res.json(result.rows[0]);
  } catch (error) {
    next(error);
  }
};

// DELETE /lista-compras/completados — limpiar items completados
const clearCompletados = async (req, res, next) => {
  try {
    const result = await pool.query(
      'DELETE FROM lista_compras WHERE completado = TRUE RETURNING id'
    );
    res.json({ message: 'Items completados eliminados', cantidad: result.rowCount });
  } catch (err) {
    next(err);
  }
};

module.exports = {
  getLista,
  addItem,
  toggleItem,
  updateItem,
  deleteItem,
  clearCompletados
};
