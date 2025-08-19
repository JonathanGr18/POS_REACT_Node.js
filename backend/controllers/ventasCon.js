const pool = require('../config/db');

// Registrar una venta con productos
exports.registrarVenta = async (req, res) => {
  const { total, productos } = req.body;
  const client = await pool.connect();

  try {
    await client.query('BEGIN'); // Iniciar transacción

    // Insertar venta
    const ventaResult = await client.query(
      'INSERT INTO ventas (fecha, total) VALUES (CURRENT_TIMESTAMP, $1) RETURNING id',
      [total]
    );
    const ventaId = ventaResult.rows[0].id;

    // Insertar detalles y actualizar stock
    for (const producto of productos) {
      await client.query(
        'INSERT INTO detalle_venta (venta_id, nombre, cantidad, precio) VALUES ($1, $2, $3, $4)',
        [ventaId, producto.nombre, producto.cantidad, producto.precio]
      );

      await client.query(
        'UPDATE productos SET stock = stock - $1 WHERE id = $2',
        [producto.cantidad, producto.id]
      );
    }

    await client.query('COMMIT'); // Confirmar
    res.status(200).json({ mensaje: 'Venta registrada con éxito' });

  } catch (error) {
    await client.query('ROLLBACK'); // Deshacer en error
    console.error('Error al registrar venta:', error);
    res.status(500).json({ error: 'Error al registrar venta' });
  } finally {
    client.release();
  }
};

// Obtener todas las ventas (con sus productos)
exports.obtenerVentas = async (req, res) => {
  try {
    const ventasResult = await pool.query('SELECT * FROM ventas ORDER BY fecha DESC');
    const ventas = ventasResult.rows;

    // Agregar productos a cada venta
    for (const venta of ventas) {
      const productosResult = await pool.query(
        `SELECT nombre AS producto, cantidad, precio
         FROM detalle_venta WHERE venta_id = $1`,
        [venta.id]
      );
      venta.productos = productosResult.rows;
    }

    res.json(ventas);
  } catch (error) {
    console.error('Error al obtener ventas:', error);
    res.status(500).json({ mensaje: 'Error al obtener historial de ventas' });
  }
};

// Obtener ventas del día actual
exports.obtenerVentasDelDia = async (req, res) => {
  try {
    const ventasResult = await pool.query(`
      SELECT * FROM ventas
      WHERE DATE(fecha) = CURRENT_DATE
      ORDER BY fecha DESC
    `);

    const ventas = ventasResult.rows;

    for (const venta of ventas) {
      const productosResult = await pool.query(
        `SELECT nombre AS producto, cantidad, precio
         FROM detalle_venta WHERE venta_id = $1`,
        [venta.id]
      );
      venta.productos = productosResult.rows;
    }

    res.json(ventas);
  } catch (error) {
    console.error("Error al obtener ventas del día:", error);
    res.status(500).json({ error: "Error al obtener ventas del día" });
  }
};

// Obtener ventas anteriores a hoy
exports.obtenerVentasAnteriores = async (req, res) => {
  try {
    const ventasResult = await pool.query(`
      SELECT * FROM ventas
      WHERE DATE(fecha) < CURRENT_DATE
      ORDER BY fecha DESC
    `);

    const ventas = ventasResult.rows;

    for (const venta of ventas) {
      const productosResult = await pool.query(
        `SELECT nombre AS producto, cantidad, precio
         FROM detalle_venta WHERE venta_id = $1`,
        [venta.id]
      );
      venta.productos = productosResult.rows;
    }

    res.json(ventas);
  } catch (error) {
    console.error("Error al obtener ventas anteriores:", error);
    res.status(500).json({ error: "Error al obtener ventas anteriores" });
  }
};

// Obtener ventas entre fechas (rango)
exports.obtenerVentasPorFecha = async (req, res) => {
  const { desde, hasta } = req.query;

  try {
    const resultado = await pool.query(
      `SELECT * FROM ventas
       WHERE DATE(fecha) BETWEEN $1 AND $2
       ORDER BY fecha DESC`,
      [desde, hasta]
    );

    const ventas = resultado.rows;

    for (const venta of ventas) {
      const productos = await pool.query(
        `SELECT nombre AS producto, cantidad, precio
         FROM detalle_venta WHERE venta_id = $1`,
        [venta.id]
      );
      venta.productos = productos.rows;
    }

    res.json(ventas);
  } catch (error) {
    console.error("Error al filtrar ventas:", error);
    res.status(500).json({ mensaje: "Error al filtrar ventas" });
  }
};
