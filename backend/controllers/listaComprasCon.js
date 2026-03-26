const pool = require('../config/db');

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
    const tienda_id = req.body.tienda_id || null;
    const nombre_producto = req.body.nombre_producto ? req.body.nombre_producto.trim() : '';
    const cantidad = req.body.cantidad !== undefined ? parseInt(req.body.cantidad, 10) : 1;
    const precio_ref = req.body.precio_ref !== undefined && req.body.precio_ref !== null ? req.body.precio_ref : null;
    const notas = req.body.notas || null;

    if (!nombre_producto) {
      const err = new Error('El nombre del producto es requerido');
      err.status = 400;
      return next(err);
    }
    if (isNaN(cantidad) || cantidad <= 0) {
      const err = new Error('La cantidad debe ser mayor a 0');
      err.status = 400;
      return next(err);
    }

    const result = await pool.query(
      `INSERT INTO lista_compras (tienda_id, nombre_producto, cantidad, precio_ref, notas)
       VALUES ($1, $2, $3, $4, $5) RETURNING *`,
      [tienda_id, nombre_producto, cantidad, precio_ref, notas]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
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
  const { cantidad, notas } = req.body;

  if (!id || isNaN(parseInt(id, 10))) {
    const err = new Error('ID inválido');
    err.status = 400;
    return next(err);
  }
  // FIX: rechazar body vacío; al menos un campo debe venir en la petición
  if (cantidad === undefined && notas === undefined) {
    const err = new Error('Se requiere al menos un campo para actualizar (cantidad o notas)');
    err.status = 400;
    return next(err);
  }
  if (cantidad !== undefined && (isNaN(Number(cantidad)) || Number(cantidad) <= 0)) {
    const err = new Error('Cantidad inválida');
    err.status = 400;
    return next(err);
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
        cantidad !== undefined ? Number(cantidad) : null,
        notas !== undefined,        // $2: flag que indica si notas viene en el body
        notas !== undefined ? notas : null,  // $3: valor de notas (puede ser null para borrar)
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
