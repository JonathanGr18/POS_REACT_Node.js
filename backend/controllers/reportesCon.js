const pool = require('../config/db');

// Helper: validar formato YYYY-MM-DD y rango sano
const validarRango = (desde, hasta) => {
  const dateRegex = /^\d{4}-\d{2}-\d{2}$/;
  if (!desde || !hasta) return 'Parámetros desde y hasta son requeridos';
  if (!dateRegex.test(desde) || !dateRegex.test(hasta)) return 'Formato de fecha inválido (YYYY-MM-DD)';
  const d1 = new Date(desde);
  const d2 = new Date(hasta);
  if (isNaN(d1.getTime()) || isNaN(d2.getTime())) return 'Fecha inválida';
  if (d1 > d2) return 'La fecha "desde" no puede ser posterior a "hasta"';
  return null;
};

// Últimos 28 días (total por día) — con rango de fechas para mayor eficiencia
exports.obtenerResumenDias = async (req, res, next) => {
  try {
    const result = await pool.query(`
      SELECT TO_CHAR((fecha AT TIME ZONE 'America/Mexico_City')::date, 'YYYY-MM-DD') AS dia,
             SUM(total)::float AS total_dia
      FROM ventas
      WHERE (fecha AT TIME ZONE 'America/Mexico_City')::date >= (NOW() AT TIME ZONE 'America/Mexico_City')::date - INTERVAL '28 days'
      GROUP BY (fecha AT TIME ZONE 'America/Mexico_City')::date
      ORDER BY dia DESC
    `);
    res.json(result.rows);
  } catch (error) {
    next(error);
  }
};

// Ventas de un día específico — usa JOIN en lugar de N+1
exports.obtenerDetalleDelDia = async (req, res, next) => {
  const { fecha } = req.params;

  if (!fecha || !/^\d{4}-\d{2}-\d{2}$/.test(fecha)) {
    return res.status(400).json({ error: 'Fecha inválida (formato: YYYY-MM-DD)' });
  }
  if (isNaN(new Date(fecha).getTime())) {
    return res.status(400).json({ error: 'Fecha inválida' });
  }

  try {
    const result = await pool.query(`
      SELECT
        v.id,
        v.fecha,
        v.total::float AS total,
        COALESCE(
          json_agg(
            json_build_object(
              'producto', dv.nombre,
              'cantidad', dv.cantidad,
              'precio', dv.precio
            )
          ) FILTER (WHERE dv.id IS NOT NULL),
          '[]'
        ) AS productos
      FROM ventas v
      LEFT JOIN detalle_venta dv ON dv.venta_id = v.id
      WHERE (v.fecha AT TIME ZONE 'America/Mexico_City')::date = $1
      GROUP BY v.id, v.fecha, v.total
      ORDER BY v.fecha DESC
    `, [fecha]);

    res.json(result.rows);
  } catch (error) {
    next(error);
  }
};

// Buscar ventas por fecha exacta — usa JOIN en lugar de N+1
exports.buscarPorFecha = async (req, res, next) => {
  const { fecha } = req.params;

  if (!fecha || !/^\d{4}-\d{2}-\d{2}$/.test(fecha)) {
    return res.status(400).json({ error: 'Fecha inválida (formato: YYYY-MM-DD)' });
  }
  if (isNaN(new Date(fecha).getTime())) {
    return res.status(400).json({ error: 'Fecha inválida' });
  }

  try {
    const result = await pool.query(`
      SELECT
        v.id,
        v.fecha,
        v.total::float AS total,
        COALESCE(
          json_agg(
            json_build_object(
              'producto', dv.nombre,
              'cantidad', dv.cantidad,
              'precio', dv.precio
            )
          ) FILTER (WHERE dv.id IS NOT NULL),
          '[]'
        ) AS productos
      FROM ventas v
      LEFT JOIN detalle_venta dv ON dv.venta_id = v.id
      WHERE (v.fecha AT TIME ZONE 'America/Mexico_City')::date = $1
      GROUP BY v.id, v.fecha, v.total
      ORDER BY v.fecha
    `, [fecha]);

    res.json(result.rows);
  } catch (err) {
    next(err);
  }
};

// Resumen mensual de últimos 12 meses (query directa, no usa vista materializada)
exports.obtenerResumenMensual = async (req, res, next) => {
  try {
    const { rows } = await pool.query(`
      WITH ventas_por_mes AS (
        SELECT date_trunc('month', fecha AT TIME ZONE 'America/Mexico_City')::date AS mes_inicio,
               sum(total)                         AS ingresos,
               count(DISTINCT (fecha AT TIME ZONE 'America/Mexico_City')::date) AS dias_con_ventas
        FROM public.ventas
        WHERE (fecha AT TIME ZONE 'America/Mexico_City') >= date_trunc('month', (NOW() AT TIME ZONE 'America/Mexico_City')) - INTERVAL '11 months'
        GROUP BY 1
      ),
      egresos_por_mes AS (
        SELECT date_trunc('month', fecha AT TIME ZONE 'America/Mexico_City')::date AS mes_inicio,
               sum(monto)                         AS egresos
        FROM public.egresos
        WHERE (fecha AT TIME ZONE 'America/Mexico_City') >= date_trunc('month', (NOW() AT TIME ZONE 'America/Mexico_City')) - INTERVAL '11 months'
        GROUP BY 1
      )
      SELECT
        to_char(vpm.mes_inicio, 'YYYY-MM')              AS mes,
        vpm.ingresos,
        COALESCE(epm.egresos, 0)                        AS egresos,
        (date_part('days', (vpm.mes_inicio + INTERVAL '1 month') - vpm.mes_inicio))::int AS dias_en_mes,
        vpm.dias_con_ventas,
        ((date_part('days', (vpm.mes_inicio + INTERVAL '1 month') - vpm.mes_inicio)) - vpm.dias_con_ventas)::int AS dias_no_trabajados,
        (vpm.ingresos - COALESCE(epm.egresos, 0))       AS ganancia
      FROM ventas_por_mes vpm
      LEFT JOIN egresos_por_mes epm ON epm.mes_inicio = vpm.mes_inicio
      ORDER BY vpm.mes_inicio DESC
      LIMIT 12
    `);
    res.json(rows);
  } catch (error) {
    next(error);
  }
};

// Detalle mensual por mes (ingresos, egresos, días no abiertos)
exports.obtenerReporteMensualPorMes = async (req, res, next) => {
  const mesIdx = parseInt(req.params.mes, 10);

  if (isNaN(mesIdx) || mesIdx < 0 || mesIdx > 11) {
    return res.status(400).json({ error: 'Mes inválido (0-11)' });
  }

  const mes = mesIdx + 1;
  let year = new Date().getFullYear();
  if (req.query.year) {
    const parsedYear = parseInt(req.query.year, 10);
    if (isNaN(parsedYear) || parsedYear < 1900 || parsedYear > new Date().getFullYear() + 1) {
      return res.status(400).json({ error: 'Año inválido' });
    }
    year = parsedYear;
  }

  try {
    const [{ rows: ingresosRows }, { rows: egresosRows }, { rows: diasConRows }] = await Promise.all([
      pool.query(
        `SELECT COALESCE(SUM(total), 0) AS ingresos
         FROM ventas
         WHERE EXTRACT(MONTH FROM (fecha AT TIME ZONE 'America/Mexico_City')) = $1
           AND EXTRACT(YEAR FROM (fecha AT TIME ZONE 'America/Mexico_City')) = $2`,
        [mes, year]
      ),
      pool.query(
        `SELECT COALESCE(SUM(monto), 0) AS egresos
         FROM egresos
         WHERE EXTRACT(MONTH FROM (fecha AT TIME ZONE 'America/Mexico_City')) = $1
           AND EXTRACT(YEAR FROM (fecha AT TIME ZONE 'America/Mexico_City')) = $2`,
        [mes, year]
      ),
      pool.query(
        `SELECT DISTINCT EXTRACT(DAY FROM (fecha AT TIME ZONE 'America/Mexico_City'))::int AS dia
         FROM ventas
         WHERE EXTRACT(MONTH FROM (fecha AT TIME ZONE 'America/Mexico_City')) = $1
           AND EXTRACT(YEAR FROM (fecha AT TIME ZONE 'America/Mexico_City')) = $2`,
        [mes, year]
      )
    ]);

    const ingresos = parseFloat(ingresosRows[0].ingresos);
    const egresos  = parseFloat(egresosRows[0].egresos);

    const diasEnMes = new Date(year, mes, 0).getDate();
    // Ya viene como int desde PG (no hay que parsear con new Date)
    const diasConVentas = diasConRows.map(r => r.dia);
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
    next(err);
  }
};

// Días sin ventas (consultando tabla calendario) — con LEFT JOIN en lugar de NOT IN
exports.obtenerDiasNoAbiertos = async (req, res, next) => {
  const mesIndex = parseInt(req.params.mes, 10);

  if (isNaN(mesIndex) || mesIndex < 0 || mesIndex > 11) {
    return res.status(400).json({ error: 'Mes inválido (0-11)' });
  }

  const year = new Date().getFullYear();
  const mes = mesIndex + 1;

  try {
    // Genera todos los días del mes y excluye los que tienen ventas
    const diasEnMes = new Date(year, mes, 0).getDate();
    const todosDias = Array.from({ length: diasEnMes }, (_, k) => k + 1);

    const { rows } = await pool.query(`
      SELECT DISTINCT EXTRACT(DAY FROM (fecha AT TIME ZONE 'America/Mexico_City'))::int AS dia
      FROM ventas
      WHERE EXTRACT(MONTH FROM (fecha AT TIME ZONE 'America/Mexico_City')) = $1
        AND EXTRACT(YEAR FROM (fecha AT TIME ZONE 'America/Mexico_City')) = $2
    `, [mes, year]);

    const diasConVentas = new Set(rows.map(r => r.dia));
    const diasNoAbiertos = todosDias.filter(d => !diasConVentas.has(d));

    res.json({ diasNoAbiertos, cantidad: diasNoAbiertos.length });
  } catch (error) {
    next(error);
  }
};

// TOP PRODUCTOS por período
exports.topProductos = async (req, res, next) => {
  const { desde, hasta, limite = 10 } = req.query;
  // Si vienen ambas, validar formato
  if (desde || hasta) {
    const err = validarRango(desde, hasta);
    if (err) return res.status(400).json({ error: err });
  }
  // Limite seguro
  const limiteNum = Math.min(Math.max(parseInt(limite, 10) || 10, 1), 100);
  try {
    const params = [];
    let where = '';
    if (desde && hasta) {
      where = "WHERE (v.fecha AT TIME ZONE 'America/Mexico_City')::date BETWEEN $1 AND $2";
      params.push(desde, hasta);
    } else {
      where = "WHERE (v.fecha AT TIME ZONE 'America/Mexico_City')::date >= (NOW() AT TIME ZONE 'America/Mexico_City')::date - INTERVAL '30 days'";
    }
    params.push(limiteNum);
    const { rows } = await pool.query(`
      SELECT
        dv.nombre AS producto,
        SUM(dv.cantidad)::int             AS total_unidades,
        SUM(dv.cantidad * dv.precio)::float AS total_ingresos,
        COUNT(DISTINCT dv.venta_id)::int  AS num_ventas
      FROM detalle_venta dv
      JOIN ventas v ON v.id = dv.venta_id
      ${where}
      GROUP BY dv.nombre
      ORDER BY total_unidades DESC
      LIMIT $${params.length}
    `, params);
    res.json(rows);
  } catch (err) { next(err); }
};

// RESUMEN por rango de fechas
exports.resumenPeriodo = async (req, res, next) => {
  const { desde, hasta } = req.query;
  const errMsg = validarRango(desde, hasta);
  if (errMsg) return res.status(400).json({ error: errMsg });
  try {
    const [{ rows: dias }, { rows: resumen }] = await Promise.all([
      pool.query(
        `SELECT TO_CHAR((fecha AT TIME ZONE 'America/Mexico_City')::date, 'YYYY-MM-DD') AS dia,
                SUM(total)::float AS total_dia, COUNT(*)::int AS num_ventas
         FROM ventas
         WHERE (fecha AT TIME ZONE 'America/Mexico_City')::date BETWEEN $1 AND $2
         GROUP BY (fecha AT TIME ZONE 'America/Mexico_City')::date
         ORDER BY dia ASC`,
        [desde, hasta]
      ),
      pool.query(
        `SELECT
           COALESCE(SUM(total), 0)::float AS total,
           COUNT(*)::int                  AS num_ventas,
           COALESCE(AVG(total), 0)::float AS promedio_venta,
           COALESCE(MAX(total), 0)::float AS venta_max,
           COALESCE(MIN(total), 0)::float AS venta_min
         FROM ventas
         WHERE (fecha AT TIME ZONE 'America/Mexico_City')::date BETWEEN $1 AND $2`,
        [desde, hasta]
      ),
    ]);
    res.json({ dias, ...resumen[0] });
  } catch (err) { next(err); }
};

// RESUMEN de los últimos 12 meses con egresos (para gráfica comparativa)
exports.mesesResumen = async (req, res, next) => {
  try {
    const { rows } = await pool.query(`
      WITH ventas_mes AS (
        SELECT DATE_TRUNC('month', fecha AT TIME ZONE 'America/Mexico_City') AS mes,
               SUM(total)::float AS total_mes,
               COUNT(*)::int    AS num_ventas
        FROM ventas
        WHERE (fecha AT TIME ZONE 'America/Mexico_City') >= DATE_TRUNC('month', NOW() AT TIME ZONE 'America/Mexico_City') - INTERVAL '11 months'
        GROUP BY DATE_TRUNC('month', fecha AT TIME ZONE 'America/Mexico_City')
      ),
      egresos_mes AS (
        SELECT DATE_TRUNC('month', fecha AT TIME ZONE 'America/Mexico_City') AS mes,
               SUM(monto)::float AS total_egresos
        FROM egresos
        WHERE (fecha AT TIME ZONE 'America/Mexico_City') >= DATE_TRUNC('month', NOW() AT TIME ZONE 'America/Mexico_City') - INTERVAL '11 months'
        GROUP BY DATE_TRUNC('month', fecha AT TIME ZONE 'America/Mexico_City')
      )
      SELECT
        TO_CHAR(v.mes, 'YYYY-MM')         AS mes,
        v.total_mes,
        v.num_ventas,
        COALESCE(e.total_egresos, 0)      AS total_egresos,
        (v.total_mes - COALESCE(e.total_egresos, 0))::float AS ganancia
      FROM ventas_mes v
      LEFT JOIN egresos_mes e ON e.mes = v.mes
      ORDER BY v.mes ASC
    `);
    res.json(rows);
  } catch (err) { next(err); }
};

// HORAS PICO — distribución de ventas por hora del día (en zona horaria local)
exports.horasPico = async (req, res, next) => {
  const { desde, hasta } = req.query;
  if (desde || hasta) {
    const err = validarRango(desde, hasta);
    if (err) return res.status(400).json({ error: err });
  }
  try {
    let query, params = [];
    if (desde && hasta) {
      query = `
        SELECT EXTRACT(HOUR FROM (fecha AT TIME ZONE 'America/Mexico_City'))::int AS hora,
               COUNT(*)::int                AS num_ventas,
               SUM(total)::float            AS total
        FROM ventas
        WHERE (fecha AT TIME ZONE 'America/Mexico_City')::date BETWEEN $1 AND $2
        GROUP BY hora ORDER BY hora`;
      params = [desde, hasta];
    } else {
      query = `
        SELECT EXTRACT(HOUR FROM (fecha AT TIME ZONE 'America/Mexico_City'))::int AS hora,
               COUNT(*)::int                AS num_ventas,
               SUM(total)::float            AS total
        FROM ventas
        WHERE (fecha AT TIME ZONE 'America/Mexico_City')::date >= (NOW() AT TIME ZONE 'America/Mexico_City')::date - INTERVAL '30 days'
        GROUP BY hora ORDER BY hora`;
    }
    const { rows } = await pool.query(query, params);
    res.json(rows);
  } catch (err) { next(err); }
};

// MÉTODOS DE PAGO — distribución por tipo (efectivo/tarjeta/transferencia)
exports.metodosPago = async (req, res, next) => {
  const { desde, hasta } = req.query;
  if (desde || hasta) {
    const err = validarRango(desde, hasta);
    if (err) return res.status(400).json({ error: err });
  }
  try {
    let where = '';
    const params = [];
    if (desde && hasta) {
      where = "WHERE (fecha AT TIME ZONE 'America/Mexico_City')::date BETWEEN $1 AND $2";
      params.push(desde, hasta);
    } else {
      where = "WHERE (fecha AT TIME ZONE 'America/Mexico_City')::date >= (NOW() AT TIME ZONE 'America/Mexico_City')::date - INTERVAL '30 days'";
    }
    const { rows } = await pool.query(`
      SELECT
        metodo_pago,
        COUNT(*)::int        AS num_ventas,
        SUM(total)::float    AS total
      FROM ventas
      ${where}
      GROUP BY metodo_pago
      ORDER BY total DESC
    `, params);
    res.json(rows);
  } catch (err) { next(err); }
};

// DIAS con query params opcionales (desde/hasta)
exports.obtenerResumenDiasFiltrado = async (req, res, next) => {
  const { desde, hasta } = req.query;
  if (desde || hasta) {
    const err = validarRango(desde, hasta);
    if (err) return res.status(400).json({ error: err });
  }
  try {
    let query, params = [];
    if (desde && hasta) {
      query = `SELECT TO_CHAR((fecha AT TIME ZONE 'America/Mexico_City')::date, 'YYYY-MM-DD') AS dia,
                      SUM(total)::float AS total_dia, COUNT(*)::int AS num_ventas
               FROM ventas
               WHERE (fecha AT TIME ZONE 'America/Mexico_City')::date BETWEEN $1 AND $2
               GROUP BY (fecha AT TIME ZONE 'America/Mexico_City')::date
               ORDER BY dia DESC`;
      params = [desde, hasta];
    } else {
      query = `SELECT TO_CHAR((fecha AT TIME ZONE 'America/Mexico_City')::date, 'YYYY-MM-DD') AS dia,
                      SUM(total)::float AS total_dia, COUNT(*)::int AS num_ventas
               FROM ventas
               WHERE (fecha AT TIME ZONE 'America/Mexico_City')::date >= (NOW() AT TIME ZONE 'America/Mexico_City')::date - INTERVAL '30 days'
               GROUP BY (fecha AT TIME ZONE 'America/Mexico_City')::date
               ORDER BY dia DESC`;
    }
    const { rows } = await pool.query(query, params);
    res.json(rows);
  } catch (err) { next(err); }
};
