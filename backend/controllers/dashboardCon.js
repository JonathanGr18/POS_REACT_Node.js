const pool = require('../config/db');

exports.getResumen = async (req, res, next) => {
  try {
    // Umbral configurable via query param (default 15, clampado 1-1000)
    // Si el query param es invalido (no numerico) devolver 400
    const umbralRaw = req.query.umbral;
    let umbral = 15;
    let umbralExplicito = false;
    if (umbralRaw !== undefined) {
      const parsed = parseInt(umbralRaw, 10);
      if (isNaN(parsed) || parsed <= 0 || parsed > 1000) {
        return res.status(400).json({ error: 'Parametro umbral invalido (debe ser entero 1-1000)' });
      }
      umbral = parsed;
      umbralExplicito = true;
    }

    const [
      ventasHoy,
      ingresosHoy,
      totalProductos,
      stockCritico,
      topProductos,
      ultimasVentas
    ] = await Promise.all([
      // 1. Cantidad de ventas hoy (TZ America/Mexico_City para consistencia)
      pool.query("SELECT COUNT(*)::int AS cantidad FROM ventas WHERE (fecha AT TIME ZONE 'America/Mexico_City')::date = (NOW() AT TIME ZONE 'America/Mexico_City')::date"),
      // 2. Total ingresos hoy
      pool.query("SELECT COALESCE(SUM(total), 0)::float AS total FROM ventas WHERE (fecha AT TIME ZONE 'America/Mexico_City')::date = (NOW() AT TIME ZONE 'America/Mexico_City')::date"),
      // 3. Total productos activos
      pool.query("SELECT COUNT(*)::int AS cantidad FROM productos WHERE status = true"),
      // 4. Productos con stock crítico
      // Si el umbral viene explicito en query, USARLO globalmente (ignora stock_minimo individual)
      // Si no, usa stock_minimo individual con fallback al default 15
      umbralExplicito
        ? pool.query(
            `SELECT COUNT(*)::int AS cantidad FROM productos WHERE stock <= $1 AND status = true`,
            [umbral]
          )
        : pool.query(`
            SELECT COUNT(*)::int AS cantidad FROM productos
            WHERE stock <= COALESCE(NULLIF(stock_minimo, 0), $1) AND status = true
          `, [umbral]),
      // 5. Top 5 productos más vendidos hoy
      pool.query(`SELECT dv.nombre, SUM(dv.cantidad)::int AS total_vendido
        FROM detalle_venta dv
        JOIN ventas v ON v.id = dv.venta_id
        WHERE (v.fecha AT TIME ZONE 'America/Mexico_City')::date = (NOW() AT TIME ZONE 'America/Mexico_City')::date
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
