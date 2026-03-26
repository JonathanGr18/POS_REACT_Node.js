const pool = require('../config/db');

exports.getResumen = async (req, res, next) => {
  try {
    const [
      ventasHoy,
      ingresosHoy,
      totalProductos,
      stockCritico,
      topProductos,
      ultimasVentas
    ] = await Promise.all([
      // 1. Cantidad de ventas hoy
      pool.query("SELECT COUNT(*)::int AS cantidad FROM ventas WHERE DATE(fecha) = CURRENT_DATE"),
      // 2. Total ingresos hoy
      pool.query("SELECT COALESCE(SUM(total), 0)::float AS total FROM ventas WHERE DATE(fecha) = CURRENT_DATE"),
      // 3. Total productos activos
      pool.query("SELECT COUNT(*)::int AS cantidad FROM productos WHERE status = true"),
      // 4. Productos con stock crítico (stock <= 5)
      pool.query("SELECT COUNT(*)::int AS cantidad FROM productos WHERE stock <= 5 AND status = true"),
      // 5. Top 5 productos más vendidos hoy (de detalle_venta)
      pool.query(`SELECT dv.nombre, SUM(dv.cantidad)::int AS total_vendido
        FROM detalle_venta dv
        JOIN ventas v ON v.id = dv.venta_id
        WHERE DATE(v.fecha) = CURRENT_DATE
        GROUP BY dv.nombre ORDER BY total_vendido DESC LIMIT 5`),
      // 6. Últimas 5 ventas
      pool.query("SELECT id, fecha, total::float AS total FROM ventas ORDER BY fecha DESC LIMIT 5")
    ]);

    res.json({
      ventasHoy:      parseInt(ventasHoy.rows[0].cantidad, 10),
      ingresosHoy:    parseFloat(ingresosHoy.rows[0].total),
      totalProductos: parseInt(totalProductos.rows[0].cantidad, 10),
      stockCritico:   parseInt(stockCritico.rows[0].cantidad, 10),
      topProductos:   topProductos.rows.map(r => ({
        nombre:         r.nombre,
        total_vendido:  parseInt(r.total_vendido, 10)
      })),
      ultimasVentas:  ultimasVentas.rows.map(r => ({
        id:    r.id,
        fecha: r.fecha,
        total: parseFloat(r.total)
      }))
    });
  } catch (err) {
    next(err);
  }
};
