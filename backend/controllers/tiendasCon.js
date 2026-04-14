const pool = require('../config/db');

// GET /tiendas — todas las tiendas con count de productos
const getTiendas = async (req, res, next) => {
  try {
    const result = await pool.query(`
      SELECT t.*, COUNT(tp.id)::int AS total_productos
      FROM tiendas t
      LEFT JOIN tienda_productos tp ON tp.tienda_id = t.id
      GROUP BY t.id
      ORDER BY t.nombre ASC
    `);
    res.json(result.rows);
  } catch (err) {
    next(err);
  }
};

// Helper de validación local
const str = (val, max, requerido = false) => {
  if (val == null || val === '') {
    if (requerido) throw Object.assign(new Error('Campo requerido'), { status: 400 });
    return null;
  }
  if (typeof val !== 'string') throw Object.assign(new Error('Campo inválido (debe ser texto)'), { status: 400 });
  const limpio = val.replace(/\x00/g, '').trim();
  if (limpio === '' && requerido) throw Object.assign(new Error('Campo requerido'), { status: 400 });
  if (limpio.length > max) throw Object.assign(new Error(`Campo demasiado largo (máx ${max})`), { status: 400 });
  return limpio;
};

// POST /tiendas — crear tienda
const createTienda = async (req, res, next) => {
  try {
    const body = req.body || {};
    let nombre, direccion, telefono, notas;
    try {
      nombre = str(body.nombre, 200, true);
      direccion = str(body.direccion, 300);
      telefono = str(body.telefono, 50);
      notas = str(body.notas, 500);
    } catch (e) {
      return res.status(400).json({ error: e.message });
    }

    const result = await pool.query(
      'INSERT INTO tiendas (nombre, direccion, telefono, notas) VALUES ($1, $2, $3, $4) RETURNING *',
      [nombre, direccion, telefono, notas]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    next(err);
  }
};

// GET /tiendas/:id — obtener tienda por ID
const getTienda = async (req, res, next) => {
  try {
    const id = parseInt(req.params.id, 10);
    if (!id || isNaN(id)) {
      const err = new Error('ID de tienda inválido');
      err.status = 400;
      return next(err);
    }
    const result = await pool.query(
      'SELECT * FROM tiendas WHERE id=$1',
      [id]
    );
    if (result.rows.length === 0) {
      const err = new Error('Tienda no encontrada');
      err.status = 404;
      return next(err);
    }
    res.json(result.rows[0]);
  } catch (err) {
    next(err);
  }
};

// PUT /tiendas/:id — actualizar tienda
const updateTienda = async (req, res, next) => {
  try {
    const id = parseInt(req.params.id, 10);
    if (!id || isNaN(id)) {
      return res.status(400).json({ error: 'ID de tienda inválido' });
    }
    const body = req.body || {};
    let nombre, direccion, telefono, notas;
    try {
      nombre = str(body.nombre, 200, true);
      direccion = str(body.direccion, 300);
      telefono = str(body.telefono, 50);
      notas = str(body.notas, 500);
    } catch (e) {
      return res.status(400).json({ error: e.message });
    }

    const result = await pool.query(
      'UPDATE tiendas SET nombre=$1, direccion=$2, telefono=$3, notas=$4 WHERE id=$5 RETURNING *',
      [nombre, direccion, telefono, notas, id]
    );

    if (result.rows.length === 0) {
      const err = new Error('Tienda no encontrada');
      err.status = 404;
      return next(err);
    }
    res.json(result.rows[0]);
  } catch (err) {
    next(err);
  }
};

// DELETE /tiendas/:id — eliminar tienda
const deleteTienda = async (req, res, next) => {
  try {
    const id = parseInt(req.params.id, 10);

    if (!id || isNaN(id)) {
      const err = new Error('ID de tienda inválido');
      err.status = 400;
      return next(err);
    }

    const result = await pool.query('DELETE FROM tiendas WHERE id=$1 RETURNING id', [id]);

    if (result.rows.length === 0) {
      const err = new Error('Tienda no encontrada');
      err.status = 404;
      return next(err);
    }
    res.json({ message: 'Tienda eliminada correctamente', id });
  } catch (err) {
    next(err);
  }
};

// GET /tiendas/:id/productos — productos de una tienda
const getProductosTienda = async (req, res, next) => {
  try {
    const id = parseInt(req.params.id, 10);

    if (!id || isNaN(id)) {
      const err = new Error('ID de tienda inválido');
      err.status = 400;
      return next(err);
    }

    const result = await pool.query(
      'SELECT * FROM tienda_productos WHERE tienda_id = $1 ORDER BY nombre ASC',
      [id]
    );
    res.json(result.rows);
  } catch (err) {
    next(err);
  }
};

// POST /tiendas/:id/productos — agregar producto a tienda
const addProductoTienda = async (req, res, next) => {
  try {
    const tienda_id = parseInt(req.params.id, 10);
    const nombre = req.body.nombre ? req.body.nombre.trim() : '';
    const precio = req.body.precio !== undefined && req.body.precio !== null ? req.body.precio : null;
    const notas = req.body.notas ? req.body.notas.trim() : null;

    if (!tienda_id || isNaN(tienda_id)) {
      const err = new Error('ID de tienda inválido');
      err.status = 400;
      return next(err);
    }
    if (!nombre) {
      const err = new Error('El nombre del producto es requerido');
      err.status = 400;
      return next(err);
    }
    if (precio !== null && (isNaN(parseFloat(precio)) || parseFloat(precio) < 0)) {
      const err = new Error('El precio debe ser un número positivo');
      err.status = 400;
      return next(err);
    }

    const result = await pool.query(
      'INSERT INTO tienda_productos (tienda_id, nombre, precio, notas) VALUES ($1, $2, $3, $4) RETURNING *',
      [tienda_id, nombre, precio, notas]
    );
    res.status(201).json(result.rows[0]);
  } catch (err) {
    next(err);
  }
};

// PUT /tiendas/productos/:productoId — actualizar producto
const updateProductoTienda = async (req, res, next) => {
  try {
    const productoId = parseInt(req.params.productoId, 10);
    const nombre = req.body.nombre ? req.body.nombre.trim() : '';
    const precio = req.body.precio !== undefined && req.body.precio !== null ? req.body.precio : null;
    const notas = req.body.notas ? req.body.notas.trim() : null;

    if (!productoId || isNaN(productoId)) {
      const err = new Error('ID de producto inválido');
      err.status = 400;
      return next(err);
    }
    if (!nombre) {
      const err = new Error('El nombre del producto es requerido');
      err.status = 400;
      return next(err);
    }
    if (precio !== null && (isNaN(parseFloat(precio)) || parseFloat(precio) < 0)) {
      const err = new Error('El precio debe ser un número positivo');
      err.status = 400;
      return next(err);
    }

    const result = await pool.query(
      'UPDATE tienda_productos SET nombre=$1, precio=$2, notas=$3, updated_at=NOW() WHERE id=$4 RETURNING *',
      [nombre, precio, notas, productoId]
    );

    if (result.rows.length === 0) {
      const err = new Error('Producto no encontrado');
      err.status = 404;
      return next(err);
    }
    res.json(result.rows[0]);
  } catch (err) {
    next(err);
  }
};

// DELETE /tiendas/productos/:productoId — eliminar producto
const deleteProductoTienda = async (req, res, next) => {
  try {
    const productoId = parseInt(req.params.productoId, 10);

    if (!productoId || isNaN(productoId)) {
      const err = new Error('ID de producto inválido');
      err.status = 400;
      return next(err);
    }

    const result = await pool.query(
      'DELETE FROM tienda_productos WHERE id=$1 RETURNING id',
      [productoId]
    );

    if (result.rows.length === 0) {
      const err = new Error('Producto no encontrado');
      err.status = 404;
      return next(err);
    }
    res.json({ message: 'Producto eliminado correctamente', id: productoId });
  } catch (err) {
    next(err);
  }
};

module.exports = {
  getTiendas,
  getTienda,
  createTienda,
  updateTienda,
  deleteTienda,
  getProductosTienda,
  addProductoTienda,
  updateProductoTienda,
  deleteProductoTienda
};
