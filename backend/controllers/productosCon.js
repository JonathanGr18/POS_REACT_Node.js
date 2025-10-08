const pool = require('../config/db');

// Obtener todos los productos
exports.getProductos = async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM productos ORDER BY nombre ASC');
    res.json(result.rows);
  } catch (error) {
    console.error('Error en la consulta:', error);
    res.status(500).json({ error: 'Error en la consulta' });
  }
};

// Crear nuevo producto
exports.createProducto = async (req, res) => {
  const { nombre, precio, descripcion, codigo, stock, status } = req.body;
  try {
    const result = await pool.query(
      'INSERT INTO productos (nombre, precio, descripcion, codigo, stock, status) VALUES ($1, $2, $3, $4, $5, $6) RETURNING *',
      [nombre, precio, descripcion, codigo, stock, status]
    );
    res.status(201).json(result.rows[0]);
  } catch (error) {
    console.error('Error al crear el producto:', error);
    res.status(500).json({ error: 'Error al crear el producto' });
  }
};

// Actualizar producto
exports.updateProducto = async (req, res) => {
  const { id } = req.params;
  const { nombre, precio, descripcion, codigo, stock } = req.body;

  try {
    const result = await pool.query(
      'UPDATE productos SET nombre = $1, precio = $2, descripcion = $3, codigo = $4, stock = $5 WHERE id = $6 RETURNING *',
      [nombre, precio, descripcion, codigo, stock, id]
    );

    if (result.rowCount === 0) return res.status(404).json({ error: 'Producto no encontrado' });

    res.json(result.rows[0]);
  } catch (error) {
    console.error('Error al actualizar el producto:', error);
    res.status(500).json({ error: 'Error al actualizar el producto' });
  }
};

// Eliminar producto
exports.deleteProducto = async (req, res) => {
  const { id } = req.params;

  try {
    const result = await pool.query('DELETE FROM productos WHERE id = $1 RETURNING *', [id]);

    if (result.rowCount === 0) return res.status(404).json({ error: 'Producto no encontrado' });

    res.json({ mensaje: 'Producto eliminado correctamente' });
  } catch (error) {
    console.error('Error al eliminar el producto:', error);
    res.status(500).json({ error: 'Error al eliminar el producto' });
  }
};

// Obtener productos faltantes (stock bajo)
exports.obtenerFaltantes = async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT * FROM productos
      WHERE stock <= 5
      ORDER BY stock ASC
    `);
    res.json(result.rows);
  } catch (error) {
    console.error('Error al obtener faltantes:', error);
    res.status(500).json({ error: 'Error interno del servidor' });
  }
};

// Resurtir stock de producto
exports.resurtirProducto = async (req, res) => {
  const { id } = req.params;
  const { cantidad } = req.body;

  try {
    await pool.query(
      'UPDATE productos SET stock = stock + $1 WHERE id = $2',
      [cantidad, id]
    );
    res.status(200).json({ mensaje: 'Producto resurtido' });
  } catch (error) {
    console.error('Error al resurtir:', error);
    res.status(500).json({ error: 'Error al resurtir producto' });
  }
};

// Registrar egreso
exports.agregarEgreso = async (req, res) => {
  const { monto } = req.body;

  if (!monto || isNaN(monto) || monto <= 0) {
    return res.status(400).json({ error: 'Monto inválido' });
  }

  try {
    await pool.query('INSERT INTO egresos (monto) VALUES ($1)', [monto]);
    res.status(201).json({ mensaje: 'Egreso registrado correctamente' });
  } catch (error) {
    console.error('Error al guardar egreso:', error);
    res.status(500).json({ error: 'Error interno al registrar egreso' });
  }
};
