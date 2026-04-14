const pool = require('../config/db');

const DEEPSEEK_API_URL = 'https://api.deepseek.com/chat/completions';

// Recopila contexto completo del negocio desde la BD
async function obtenerContextoNegocio() {
  const [
    ventasHoy,
    ingresosHoy,
    totalProductos,
    stockCritico,
    topProductosHoy,
    resumenMes,
    resumenMesAnterior,
    productosPocoStock,
    productosSinMovimiento,
    topProductosMes,
    ticketPromedio,
    ventasPorMetodo,
    ventasPorHora,
    egresosDelMes,
    productosMasRentables
  ] = await Promise.all([
    // 1. Ventas hoy (TZ America/Mexico_City)
    pool.query("SELECT COUNT(*)::int AS cantidad FROM ventas WHERE (fecha AT TIME ZONE 'America/Mexico_City')::date = (NOW() AT TIME ZONE 'America/Mexico_City')::date"),
    // 2. Ingresos hoy
    pool.query("SELECT COALESCE(SUM(total), 0)::float AS total FROM ventas WHERE (fecha AT TIME ZONE 'America/Mexico_City')::date = (NOW() AT TIME ZONE 'America/Mexico_City')::date"),
    // 3. Total productos activos
    pool.query("SELECT COUNT(*)::int AS cantidad FROM productos WHERE status = true"),
    // 4. Stock crítico
    pool.query("SELECT COUNT(*)::int AS cantidad FROM productos WHERE stock <= 5 AND status = true"),
    // 5. Top productos vendidos hoy
    pool.query(`
      SELECT dv.nombre, SUM(dv.cantidad)::int AS total_vendido
      FROM detalle_venta dv JOIN ventas v ON v.id = dv.venta_id
      WHERE (v.fecha AT TIME ZONE 'America/Mexico_City')::date = (NOW() AT TIME ZONE 'America/Mexico_City')::date
      GROUP BY dv.nombre ORDER BY total_vendido DESC LIMIT 5
    `),
    // 6. Resumen mes actual (TZ)
    pool.query(`
      SELECT COALESCE(SUM(total), 0)::float AS ingresos,
             COUNT(*)::int AS num_ventas,
             COALESCE(AVG(total), 0)::float AS ticket_promedio
      FROM ventas
      WHERE (fecha AT TIME ZONE 'America/Mexico_City') >= date_trunc('month', NOW() AT TIME ZONE 'America/Mexico_City')
    `),
    // 7. Resumen mes anterior (para comparar)
    pool.query(`
      SELECT COALESCE(SUM(total), 0)::float AS ingresos,
             COUNT(*)::int AS num_ventas
      FROM ventas
      WHERE (fecha AT TIME ZONE 'America/Mexico_City') >= date_trunc('month', NOW() AT TIME ZONE 'America/Mexico_City') - INTERVAL '1 month'
        AND (fecha AT TIME ZONE 'America/Mexico_City') <  date_trunc('month', NOW() AT TIME ZONE 'America/Mexico_City')
    `),
    // 8. Productos con poco stock (detallado)
    pool.query(`
      SELECT nombre, stock, precio::float AS precio
      FROM productos WHERE stock <= 5 AND status = true
      ORDER BY stock ASC LIMIT 15
    `),
    // 9. Productos sin movimiento en 30 días (join por nombre, detalle_venta no tiene producto_id)
    pool.query(`
      SELECT p.nombre, p.stock, p.precio::float AS precio
      FROM productos p
      WHERE p.status = true
        AND p.nombre NOT IN (
          SELECT DISTINCT dv.nombre FROM detalle_venta dv
          JOIN ventas v ON v.id = dv.venta_id
          WHERE v.fecha >= NOW() - INTERVAL '30 days'
        )
      ORDER BY p.precio DESC LIMIT 10
    `),
    // 10. Top 10 productos más vendidos del mes
    pool.query(`
      SELECT dv.nombre, SUM(dv.cantidad)::int AS unidades,
             SUM(dv.cantidad * dv.precio)::float AS ingresos
      FROM detalle_venta dv JOIN ventas v ON v.id = dv.venta_id
      WHERE (v.fecha AT TIME ZONE 'America/Mexico_City') >= date_trunc('month', NOW() AT TIME ZONE 'America/Mexico_City')
      GROUP BY dv.nombre ORDER BY unidades DESC LIMIT 10
    `),
    // 11. Ticket promedio últimos 7 días (ventana movil OK sin TZ)
    pool.query(`
      SELECT COALESCE(AVG(total), 0)::float AS promedio,
             COALESCE(MAX(total), 0)::float AS maximo,
             COALESCE(MIN(total), 0)::float AS minimo
      FROM ventas WHERE fecha >= NOW() - INTERVAL '7 days'
    `),
    // 12. Ventas por método de pago (mes actual)
    pool.query(`
      SELECT metodo_pago, COUNT(*)::int AS num_ventas, SUM(total)::float AS total
      FROM ventas
      WHERE (fecha AT TIME ZONE 'America/Mexico_City') >= date_trunc('month', NOW() AT TIME ZONE 'America/Mexico_City')
      GROUP BY metodo_pago ORDER BY total DESC
    `),
    // 13. Distribución por hora (últimos 30 días)
    pool.query(`
      SELECT EXTRACT(HOUR FROM (fecha AT TIME ZONE 'America/Mexico_City'))::int AS hora,
             COUNT(*)::int AS num_ventas
      FROM ventas WHERE fecha >= NOW() - INTERVAL '30 days'
      GROUP BY hora ORDER BY num_ventas DESC LIMIT 5
    `),
    // 14. Egresos del mes
    pool.query(`
      SELECT COALESCE(SUM(monto), 0)::float AS total_egresos, COUNT(*)::int AS num_egresos
      FROM egresos
      WHERE (fecha AT TIME ZONE 'America/Mexico_City') >= date_trunc('month', NOW() AT TIME ZONE 'America/Mexico_City')
    `),
    // 15. Productos más rentables del mes (por ingreso total)
    pool.query(`
      SELECT dv.nombre, SUM(dv.cantidad * dv.precio)::float AS ingreso_total,
             SUM(dv.cantidad)::int AS unidades
      FROM detalle_venta dv JOIN ventas v ON v.id = dv.venta_id
      WHERE (v.fecha AT TIME ZONE 'America/Mexico_City') >= date_trunc('month', NOW() AT TIME ZONE 'America/Mexico_City')
      GROUP BY dv.nombre ORDER BY ingreso_total DESC LIMIT 10
    `)
  ]);

  // Calcular crecimiento vs mes anterior
  const ingresosMes = resumenMes.rows[0].ingresos;
  const ingresosMesAnterior = resumenMesAnterior.rows[0].ingresos;
  const crecimiento = ingresosMesAnterior > 0
    ? (((ingresosMes - ingresosMesAnterior) / ingresosMesAnterior) * 100).toFixed(1)
    : null;

  return {
    ventasHoy: ventasHoy.rows[0].cantidad,
    ingresosHoy: ingresosHoy.rows[0].total,
    totalProductos: totalProductos.rows[0].cantidad,
    stockCritico: stockCritico.rows[0].cantidad,
    topProductosHoy: topProductosHoy.rows,
    ingresosMes,
    ventasMes: resumenMes.rows[0].num_ventas,
    ticketPromedioMes: resumenMes.rows[0].ticket_promedio,
    ingresosMesAnterior,
    ventasMesAnterior: resumenMesAnterior.rows[0].num_ventas,
    crecimientoVsMesAnterior: crecimiento,
    productosPocoStock: productosPocoStock.rows,
    productosSinMovimiento: productosSinMovimiento.rows,
    topProductosMes: topProductosMes.rows,
    ticketPromedio7dias: ticketPromedio.rows[0],
    ventasPorMetodo: ventasPorMetodo.rows,
    horasPico: ventasPorHora.rows,
    egresosDelMes: egresosDelMes.rows[0],
    productosMasRentables: productosMasRentables.rows
  };
}

exports.chat = async (req, res, next) => {
  try {
    const { mensaje, historial = [] } = req.body || {};

    if (!mensaje || typeof mensaje !== 'string' || mensaje.trim().length === 0) {
      return res.status(400).json({ error: 'El mensaje es requerido' });
    }
    // Limitar longitud del mensaje (backend no puede confiar en limit del frontend)
    if (mensaje.length > 2000) {
      return res.status(400).json({ error: 'Mensaje demasiado largo (máx 2000 caracteres)' });
    }

    // Sanitizar historial: solo roles user/assistant, content string, max 10 items
    const historialSanitizado = Array.isArray(historial)
      ? historial
          .filter(m => m && typeof m === 'object'
            && (m.role === 'user' || m.role === 'assistant')
            && typeof m.content === 'string'
            && m.content.length > 0
            && m.content.length <= 2000)
          .slice(-10)
      : [];

    const apiKey = process.env.DEEPSEEK_API_KEY;
    if (!apiKey) {
      return res.status(500).json({ error: 'API key de DeepSeek no configurada' });
    }

    const contexto = await obtenerContextoNegocio();

    // Helper local para formatear numeros de forma segura (evita crash si hay null)
    const n = (v, dec = 2) => (Number(v) || 0).toFixed(dec);

    const systemPrompt = `Eres "POS Expert", un consultor de negocios especializado en papelerías y negocios minoristas en México.
Tienes 15 años de experiencia ayudando papelerías a crecer, optimizar inventario y maximizar ganancias.

TU PERSONALIDAD:
- Hablas en español mexicano, profesional pero cercano
- Eres directo, das consejos accionables, no teoría
- Usas los datos reales del negocio para fundamentar cada recomendación
- Cuando ves un problema, lo dices con claridad y das la solución
- Priorizas: rentabilidad > rotación de inventario > satisfacción del cliente

CONOCIMIENTO EXPERTO EN PAPELERÍAS:
- Temporadas clave: regreso a clases (agosto), Día del Maestro (mayo), fin de año escolar (junio-julio), época navideña, inicio de año
- Productos de alta rotación: cuadernos, lápices, plumas, hojas, cartulinas, pegamento, tijeras
- Productos de alto margen: mochilas, calculadoras, artículos de oficina, tinta, artículos de regalo
- Estrategias probadas: combos escolares, paquetes por grado, promociones 2x1 en temporada baja, programa de clientes frecuentes
- Proveedores comunes en México y mejores prácticas de negociación

DATOS EN TIEMPO REAL DEL NEGOCIO:

📊 HOY:
- Ventas: ${contexto.ventasHoy} transacciones por $${n(contexto.ingresosHoy)} MXN
- Productos más vendidos hoy: ${(contexto.topProductosHoy || []).map(p => `${p.nombre} (${p.total_vendido} uds)`).join(', ') || 'Sin ventas aún'}

📈 MES ACTUAL:
- Ingresos: $${n(contexto.ingresosMes)} MXN en ${contexto.ventasMes} ventas
- Ticket promedio: $${n(contexto.ticketPromedioMes)} MXN
- Egresos: $${n(contexto.egresosDelMes?.total_egresos)} MXN (${contexto.egresosDelMes?.num_egresos || 0} registros)
- Ganancia estimada: $${n(Number(contexto.ingresosMes) - Number(contexto.egresosDelMes?.total_egresos || 0))} MXN
${contexto.crecimientoVsMesAnterior !== null ? `- Crecimiento vs mes anterior: ${contexto.crecimientoVsMesAnterior}%` : '- Sin datos del mes anterior para comparar'}

📊 MES ANTERIOR:
- Ingresos: $${n(contexto.ingresosMesAnterior)} MXN en ${contexto.ventasMesAnterior} ventas

🏆 TOP 10 PRODUCTOS MÁS VENDIDOS (mes actual):
${(contexto.topProductosMes || []).map((p, i) => `${i + 1}. ${p.nombre}: ${p.unidades} uds → $${n(p.ingresos)}`).join('\n') || 'Sin datos'}

💰 PRODUCTOS MÁS RENTABLES (por ingreso total, mes actual):
${(contexto.productosMasRentables || []).map((p, i) => `${i + 1}. ${p.nombre}: $${n(p.ingreso_total)} (${p.unidades} uds)`).join('\n') || 'Sin datos'}

🎯 TICKET PROMEDIO (últimos 7 días):
- Promedio: $${n(contexto.ticketPromedio7dias?.promedio)} | Máximo: $${n(contexto.ticketPromedio7dias?.maximo)} | Mínimo: $${n(contexto.ticketPromedio7dias?.minimo)}

💳 MÉTODOS DE PAGO (mes actual):
${(contexto.ventasPorMetodo || []).map(m => `- ${m.metodo_pago || 'No especificado'}: ${m.num_ventas} ventas → $${n(m.total)}`).join('\n') || 'Sin datos'}

⏰ HORAS PICO (últimos 30 días, top 5):
${(contexto.horasPico || []).map(h => `- ${h.hora}:00 hrs: ${h.num_ventas} ventas`).join('\n') || 'Sin datos'}

📦 INVENTARIO:
- Total productos activos: ${contexto.totalProductos}
- Productos con stock crítico (≤5 unidades): ${contexto.stockCritico}
- Detalle stock bajo: ${(contexto.productosPocoStock || []).map(p => `${p.nombre} (stock: ${p.stock}, precio: $${n(p.precio)})`).join(', ') || 'Ninguno'}

⚠️ PRODUCTOS SIN MOVIMIENTO (30 días sin venderse):
${(contexto.productosSinMovimiento || []).map(p => `- ${p.nombre} (stock: ${p.stock}, precio: $${n(p.precio)})`).join('\n') || 'Todos los productos tuvieron movimiento'}

INSTRUCCIONES DE RESPUESTA:
1. Analiza los datos antes de responder
2. Da consejos ESPECÍFICOS basados en los números reales, no genéricos
3. Si ves alertas (stock bajo, productos sin movimiento, caída en ventas), menciónalas proactivamente
4. Sugiere acciones concretas: "Resurtir X producto", "Hacer promoción 2x1 en Y", "Subir precio de Z"
5. Cuando sea relevante, menciona temporadas que se acercan y cómo prepararse
6. Si te preguntan algo que no puedes saber con estos datos, dilo honestamente
7. No inventes cifras ni datos. Solo usa lo que tienes
8. Responde de forma concisa pero completa. Usa viñetas y formato claro
9. Si el usuario pide un análisis general, da un diagnóstico tipo consultor con: fortalezas, áreas de mejora y plan de acción`;

    const messages = [
      { role: 'system', content: systemPrompt },
      ...historialSanitizado,
      { role: 'user', content: mensaje.trim() }
    ];

    // Timeout de 30s para evitar requests colgados
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), 30000);

    let response;
    try {
      response = await fetch(DEEPSEEK_API_URL, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${apiKey}`
        },
        body: JSON.stringify({
          model: 'deepseek-chat',
          messages,
          max_tokens: 2048,
          temperature: 0.7
        }),
        signal: controller.signal
      });
    } catch (err) {
      clearTimeout(timeoutId);
      if (err.name === 'AbortError') {
        return res.status(504).json({ error: 'Timeout al comunicarse con DeepSeek' });
      }
      throw err;
    }
    clearTimeout(timeoutId);

    if (!response.ok) {
      // No exponer errorData al cliente (puede tener info sensible)
      console.error('[DeepSeek Error]', response.status);
      return res.status(502).json({ error: 'Error al comunicarse con DeepSeek' });
    }

    const data = await response.json();
    const respuesta = data.choices?.[0]?.message?.content || 'No se obtuvo respuesta';

    res.json({ respuesta });
  } catch (err) {
    next(err);
  }
};
