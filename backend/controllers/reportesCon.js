const pool = require('../config/db');

// Últimos 30 días (total por día)
exports.obtenerResumenDias = async (req, res) => {
  try {
    const result = await pool.query(`
      SELECT DATE(fecha) AS dia, SUM(total) AS total_dia
      FROM ventas
      GROUP BY dia
      ORDER BY dia DESC
      LIMIT 30
    `);
    res.json(result.rows);
  } catch (error) {
    console.error('Error al obtener resumen:', error);
    res.status(500).json({ error: 'Error al obtener resumen de días' });
  }
};

// Ventas de un día específico
exports.obtenerDetalleDelDia = async (req, res) => {
  const { fecha } = req.params;
  try {
    const ventas = await pool.query(
      `SELECT * FROM ventas WHERE DATE(fecha) = $1 ORDER BY fecha DESC`,
      [fecha]
    );

    for (const venta of ventas.rows) {
      const productos = await pool.query(
        `SELECT nombre AS producto, cantidad, precio FROM detalle_venta WHERE venta_id = $1`,
        [venta.id]
      );
      venta.productos = productos.rows;
    }

    res.json(ventas.rows);
  } catch (error) {
    console.error('Error al obtener detalle:', error);
    res.status(500).json({ error: 'Error al obtener detalle del día' });
  }
};

// Buscar ventas por fecha exacta
exports.buscarPorFecha = async (req, res) => {
  const { fecha } = req.params;
  try {
    const resultVentas = await pool.query(
      `SELECT * FROM ventas WHERE DATE(fecha) = $1 ORDER BY fecha`,
      [fecha]
    );

    const ventas = resultVentas.rows;
    for (const venta of ventas) {
      const productos = await pool.query(
        `SELECT nombre AS producto, cantidad, precio FROM detalle_venta WHERE venta_id = $1`,
        [venta.id]
      );
      venta.productos = productos.rows;
    }

    res.json(ventas);
  } catch (err) {
    console.error("Error al buscar por fecha:", err);
    res.status(500).json({ error: 'Error al buscar ventas por fecha' });
  }
};

// (Vista) resumen mensual de últimos 12 meses
exports.obtenerResumenMensual = async (req, res) => {
  try {
    const { rows } = await pool.query(`
      SELECT mes, ingresos, egresos, dias_en_mes, dias_no_trabajados, ganancia
      FROM public.resumen_mensual
      ORDER BY mes DESC
      LIMIT 12
    `);
    res.json(rows);
  } catch (error) {
    console.error('Error al obtener resumen mensual:', error);
    res.status(500).json({ error: 'No se pudo obtener el resumen mensual' });
  }
};

// Detalle mensual por mes (ingresos, egresos, días no abiertos)
exports.obtenerReporteMensualPorMes = async (req, res) => {
  const mesIdx = parseInt(req.params.mes, 10); // 0 = enero
  const mes = mesIdx + 1;
  const year = new Date().getFullYear();

  try {
    // Ingresos y egresos del mes
    const [{ rows: ingresosRows }, { rows: egresosRows }] = await Promise.all([
      pool.query(
        `SELECT COALESCE(SUM(total),0) AS ingresos
         FROM ventas
         WHERE EXTRACT(MONTH FROM fecha) = $1 AND EXTRACT(YEAR FROM fecha) = $2`,
        [mes, year]
      ),
      pool.query(
        `SELECT COALESCE(SUM(monto),0) AS egresos
         FROM egresos
         WHERE EXTRACT(MONTH FROM fecha) = $1 AND EXTRACT(YEAR FROM fecha) = $2`,
        [mes, year]
      )
    ]);

    const ingresos = parseFloat(ingresosRows[0].ingresos);
    const egresos  = parseFloat(egresosRows[0].egresos);

    // Días no abiertos
    const diasEnMes = new Date(year, mes, 0).getDate();
    const { rows: diasConRows } = await pool.query(
      `SELECT DISTINCT DATE(fecha) AS dia
       FROM ventas
       WHERE EXTRACT(MONTH FROM fecha) = $1 AND EXTRACT(YEAR FROM fecha) = $2`,
      [mes, year]
    );
    const diasConVentas = diasConRows.map(r => r.dia.getDate());
    const diasNoAbiertos = [];
    for (let d = 1; d <= diasEnMes; d++) {
      if (!diasConVentas.includes(d)) diasNoAbiertos.push(d);
    }

    res.json({
      ingresos,
      egresos,
      dias_no_abiertos: diasNoAbiertos,
      ganancia: parseFloat((ingresos - egresos).toFixed(2))
    });
  } catch (err) {
    console.error('Error en reporte mensual por mes:', err);
    res.status(500).json({ error: 'Error al obtener reporte mensual' });
  }
};

// Días sin ventas (consultando tabla calendario)
exports.obtenerDiasNoAbiertos = async (req, res) => {
  const mesIndex = parseInt(req.params.mes, 10);
  const year = new Date().getFullYear();
  try {
    const { rows } = await pool.query(`
      SELECT fecha 
      FROM public.calendario
      WHERE EXTRACT(MONTH FROM fecha) = $1 
        AND EXTRACT(YEAR FROM fecha) = $2
        AND fecha NOT IN (
          SELECT DATE(fecha) FROM ventas
          WHERE EXTRACT(MONTH FROM fecha) = $1 
            AND EXTRACT(YEAR FROM fecha) = $2
        )
    `, [mesIndex + 1, year]);

    const diasNoAbiertos = rows.map(r => r.fecha.getDate());
    res.json({ diasNoAbiertos, cantidad: diasNoAbiertos.length });
  } catch (error) {
    console.error('Error obteniendo días no abiertos:', error);
    res.status(500).json({ error: 'Error interno del servidor' });
  }
};
