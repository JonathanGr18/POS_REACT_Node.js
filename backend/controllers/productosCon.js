const pool = require('../config/db');

// Normaliza tipos numéricos de un producto
const normalizeProducto = (row) => ({
  ...row,
  precio: parseFloat(row.precio),
  stock:  parseInt(row.stock, 10)
});

// Obtener todos los productos
exports.getProductos = async (req, res, next) => {
  try {
    const result = await pool.query('SELECT id, nombre, precio, descripcion, codigo, stock, status, imagen_url FROM productos ORDER BY nombre ASC');
    res.json(result.rows.map(normalizeProducto));
  } catch (error) {
    next(error);
  }
};

// Crear nuevo producto
exports.createProducto = async (req, res, next) => {
  const { nombre, precio, descripcion, codigo, stock, status } = req.body;

  if (!nombre || nombre.trim() === '') return res.status(400).json({ error: 'El nombre es requerido' });
  if (precio === undefined || isNaN(precio) || Number(precio) < 0) return res.status(400).json({ error: 'Precio inválido' });
  if (!codigo || codigo.toString().trim() === '') return res.status(400).json({ error: 'El código es requerido' });
  if (stock === undefined || isNaN(stock) || Number(stock) < 0) return res.status(400).json({ error: 'Stock inválido' });

  try {
    const result = await pool.query(
      'INSERT INTO productos (nombre, precio, descripcion, codigo, stock, status) VALUES ($1, $2, $3, $4, $5, $6) RETURNING *',
      [nombre.trim(), precio, descripcion || 'Sin descripcion', codigo.toString().trim(), stock, status ?? true]
    );
    res.status(201).json(normalizeProducto(result.rows[0]));
  } catch (error) {
    if (error.code === '23505') return res.status(409).json({ error: 'Ya existe un producto con ese código' });
    next(error);
  }
};

// Actualizar producto
exports.updateProducto = async (req, res, next) => {
  const { id } = req.params;
  if (!id || isNaN(parseInt(id, 10))) return res.status(400).json({ error: 'ID inválido' });

  const { nombre, precio, descripcion, codigo, stock, status } = req.body;

  if (!nombre || nombre.trim() === '') return res.status(400).json({ error: 'El nombre es requerido' });
  if (precio === undefined || isNaN(precio) || Number(precio) < 0) return res.status(400).json({ error: 'Precio inválido' });
  if (!codigo || codigo.toString().trim() === '') return res.status(400).json({ error: 'El código es requerido' });
  if (stock === undefined || isNaN(stock) || Number(stock) < 0) return res.status(400).json({ error: 'Stock inválido' });

  try {
    const result = await pool.query(
      'UPDATE productos SET nombre = $1, precio = $2, descripcion = $3, codigo = $4, stock = $5, status = $6 WHERE id = $7 RETURNING *',
      [nombre.trim(), Number(precio), descripcion || null, codigo.toString().trim(), Number(stock), status ?? true, parseInt(id, 10)]
    );

    if (result.rowCount === 0) return res.status(404).json({ error: 'Producto no encontrado' });

    res.json(normalizeProducto(result.rows[0]));
  } catch (error) {
    if (error.code === '23505') return res.status(409).json({ error: 'Ya existe un producto con ese código' });
    next(error);
  }
};

// Eliminar producto
exports.deleteProducto = async (req, res, next) => {
  const { id } = req.params;
  if (!id || isNaN(parseInt(id, 10))) return res.status(400).json({ error: 'ID inválido' });

  try {
    const result = await pool.query('DELETE FROM productos WHERE id = $1 RETURNING *', [parseInt(id, 10)]);

    if (result.rowCount === 0) return res.status(404).json({ error: 'Producto no encontrado' });

    res.json({ mensaje: 'Producto eliminado correctamente' });
  } catch (error) {
    next(error);
  }
};

// Obtener productos faltantes (stock bajo) con conteo de ventas del último mes
exports.obtenerFaltantes = async (req, res, next) => {
  const umbral = parseInt(req.query.umbral, 10);
  const stockUmbral = (!isNaN(umbral) && umbral > 0) ? umbral : 15;
  try {
    const result = await pool.query(`
      SELECT
        p.id, p.nombre, p.codigo, p.descripcion, p.stock, p.status, p.imagen_url,
        COALESCE(SUM(dv.cantidad)::int, 0) AS vendidos_mes
      FROM productos p
      LEFT JOIN detalle_venta dv ON dv.nombre = p.nombre
      LEFT JOIN ventas v ON v.id = dv.venta_id
        AND v.fecha >= NOW() - INTERVAL '30 days'
      WHERE p.stock <= $1
      GROUP BY p.id
      ORDER BY p.stock ASC
    `, [stockUmbral]);
    res.json(result.rows.map(r => ({ ...normalizeProducto(r), vendidos_mes: Number(r.vendidos_mes) })));
  } catch (error) {
    next(error);
  }
};

// Resurtir stock de producto
exports.resurtirProducto = async (req, res, next) => {
  const { id } = req.params;
  const { cantidad } = req.body;

  if (!id || isNaN(parseInt(id, 10))) return res.status(400).json({ error: 'ID inválido' });
  const cantidadParsed = parseInt(cantidad, 10);
  if (!cantidad || isNaN(cantidadParsed) || cantidadParsed <= 0) {
    return res.status(400).json({ error: 'Cantidad inválida' });
  }

  try {
    const result = await pool.query(
      'UPDATE productos SET stock = stock + $1 WHERE id = $2 RETURNING *',
      [cantidadParsed, parseInt(id, 10)]
    );
    if (result.rowCount === 0) return res.status(404).json({ error: 'Producto no encontrado' });
    res.status(200).json({ mensaje: 'Producto resurtido', producto: normalizeProducto(result.rows[0]) });
  } catch (error) {
    next(error);
  }
};

// Registrar egreso
exports.agregarEgreso = async (req, res, next) => {
  const { monto, concepto } = req.body;

  if (!monto || isNaN(monto) || Number(monto) <= 0) {
    return res.status(400).json({ error: 'Monto inválido' });
  }

  try {
    await pool.query(
      'INSERT INTO egresos (monto, concepto) VALUES ($1, $2)',
      [monto, concepto?.trim() || null]
    );
    res.status(201).json({ mensaje: 'Egreso registrado correctamente' });
  } catch (error) {
    next(error);
  }
};
