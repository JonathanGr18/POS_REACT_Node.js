const pool = require('../config/db');

// Query auxiliar: obtiene ventas con sus productos en una sola query (elimina N+1)
const queryVentasConProductos = async (whereClause, params) => {
  const result = await pool.query(`
    SELECT
      v.id,
      v.fecha,
      v.total::float          AS total,
      v.descuento::float      AS descuento,
      v.monto_recibido::float AS monto_recibido,
      v.metodo_pago,
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
    ${whereClause}
    GROUP BY v.id, v.fecha, v.total, v.descuento, v.monto_recibido, v.metodo_pago
    ORDER BY v.fecha DESC
  `, params);
  return result.rows;
};

// Helper: redondeo a centavos para evitar float precision
const round2 = (n) => Math.round(Number(n) * 100) / 100;

// Registrar una venta con productos
exports.registrarVenta = async (req, res, next) => {
  const { productos, descuento = 0, monto_recibido = 0, metodo_pago = 'efectivo' } = req.body || {};
  const metodosValidos = ['efectivo', 'tarjeta', 'transferencia'];
  const metodo = metodosValidos.includes(metodo_pago) ? metodo_pago : 'efectivo';

  if (!productos || !Array.isArray(productos) || productos.length === 0) {
    return res.status(400).json({ error: 'Se requiere al menos un producto' });
  }
  // Validar descuento (numérico, no negativo)
  if (isNaN(descuento) || Number(descuento) < 0) {
    return res.status(400).json({ error: 'Descuento inválido' });
  }
  if (!Number.isFinite(Number(descuento)) || Number(descuento) > 999999) {
    return res.status(400).json({ error: 'Descuento fuera de rango' });
  }
  // Validar monto_recibido (numérico, no negativo, tope razonable)
  const montoRecibidoNum = Number(monto_recibido);
  if (isNaN(montoRecibidoNum) || montoRecibidoNum < 0) {
    return res.status(400).json({ error: 'Monto recibido inválido' });
  }
  if (montoRecibidoNum > 9999999) {
    return res.status(400).json({ error: 'Monto recibido fuera de rango' });
  }
  // Limitar tamaño del carrito para evitar DoS
  if (productos.length > 200) {
    return res.status(400).json({ error: 'Demasiados productos en una sola venta' });
  }

  // Consolidar productos duplicados por id (evita saltarse validacion de stock)
  const consolidados = new Map();
  for (const p of productos) {
    // Validación estricta: id debe ser entero válido (no acepta "5abc")
    const idNum = Number(p?.id);
    if (!Number.isInteger(idNum) || idNum <= 0) {
      return res.status(400).json({ error: 'Producto con id inválido' });
    }
    const id = idNum;
    const cantidad = Number(p?.cantidad);
    if (isNaN(cantidad) || cantidad <= 0) {
      return res.status(400).json({ error: 'Producto con cantidad inválida' });
    }
    if (!Number.isInteger(cantidad)) {
      return res.status(400).json({ error: 'La cantidad debe ser un número entero' });
    }
    if (cantidad > 10000) {
      return res.status(400).json({ error: 'Cantidad fuera de rango' });
    }
    consolidados.set(id, (consolidados.get(id) || 0) + cantidad);
  }

  // Lista ordenada por id para evitar deadlocks (mismo orden de locks en transacciones concurrentes)
  const idsOrdenados = [...consolidados.keys()].sort((a, b) => a - b);

  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    // Leer productos desde BD en orden de id (evita deadlocks con transacciones concurrentes)
    const productosValidados = [];
    let totalCalculado = 0;
    for (const id of idsOrdenados) {
      const cantidad = consolidados.get(id);
      const prodResult = await client.query(
        'SELECT id, nombre, precio, stock FROM productos WHERE id = $1 FOR UPDATE',
        [id]
      );
      if (!prodResult.rows[0]) {
        throw { status: 404, message: `Producto ${id} no encontrado` };
      }
      const prodDB = prodResult.rows[0];
      if (Number(prodDB.stock) < cantidad) {
        throw { status: 400, message: `Stock insuficiente para "${prodDB.nombre}"` };
      }
      productosValidados.push({
        id: prodDB.id,
        nombre: prodDB.nombre,
        precio: round2(prodDB.precio),
        cantidad,
      });
      totalCalculado = round2(totalCalculado + round2(prodDB.precio) * cantidad);
    }

    // Clampar descuento al total calculado (no permitir guardar descuento > total)
    const descuentoNum = round2(Math.min(Number(descuento) || 0, totalCalculado));
    const totalFinal = round2(Math.max(0, totalCalculado - descuentoNum));

    // Validar monto recibido para pagos en efectivo
    if (metodo === 'efectivo' && montoRecibidoNum > 0 && montoRecibidoNum < totalFinal) {
      throw { status: 400, message: 'Monto recibido menor al total' };
    }

    // Insertar venta (usar total calculado servidor, no del cliente)
    const ventaResult = await client.query(
      'INSERT INTO ventas (fecha, total, descuento, monto_recibido, metodo_pago) VALUES (CURRENT_TIMESTAMP, $1, $2, $3, $4) RETURNING id, fecha',
      [totalFinal, descuentoNum, montoRecibidoNum, metodo]
    );
    const ventaId = ventaResult.rows[0].id;
    const fechaVenta = ventaResult.rows[0].fecha;

    // Insertar detalles y actualizar stock con WHERE defensivo (anti-race)
    for (const p of productosValidados) {
      await client.query(
        'INSERT INTO detalle_venta (venta_id, nombre, cantidad, precio) VALUES ($1, $2, $3, $4)',
        [ventaId, p.nombre, p.cantidad, p.precio]
      );
      const updateResult = await client.query(
        'UPDATE productos SET stock = stock - $1 WHERE id = $2 AND stock >= $1',
        [p.cantidad, p.id]
      );
      if (updateResult.rowCount !== 1) {
        // Si llegamos aqui, algo rompio la precondicion (otro proceso drenó stock)
        throw { status: 409, message: `Stock cambió durante la transacción para "${p.nombre}", intenta de nuevo` };
      }
    }

    await client.query('COMMIT');
    res.status(201).json({
      mensaje: 'Venta registrada con éxito',
      id: ventaId,
      fecha: fechaVenta,
      total: totalFinal,
      descuento: descuentoNum,
    });

  } catch (error) {
    await client.query('ROLLBACK');
    if (error.status) {
      return res.status(error.status).json({ error: error.message });
    }
    next(error);
  } finally {
    client.release();
  }
};

// Obtener todas las ventas
exports.obtenerVentas = async (req, res, next) => {
  try {
    const ventas = await queryVentasConProductos('', []);
    res.json(ventas);
  } catch (error) {
    next(error);
  }
};

// Obtener ventas del día actual (TZ Mexico_City consistente con reportesCon)
exports.obtenerVentasDelDia = async (req, res, next) => {
  try {
    const ventas = await queryVentasConProductos(
      "WHERE (v.fecha AT TIME ZONE 'America/Mexico_City')::date = (NOW() AT TIME ZONE 'America/Mexico_City')::date",
      []
    );
    res.json(ventas);
  } catch (error) {
    next(error);
  }
};

// Obtener ventas anteriores a hoy
exports.obtenerVentasAnteriores = async (req, res, next) => {
  try {
    const ventas = await queryVentasConProductos(
      "WHERE (v.fecha AT TIME ZONE 'America/Mexico_City')::date < (NOW() AT TIME ZONE 'America/Mexico_City')::date",
      []
    );
    res.json(ventas);
  } catch (error) {
    next(error);
  }
};

// Obtener ventas entre fechas (rango)
exports.obtenerVentasPorFecha = async (req, res, next) => {
  const { desde, hasta } = req.query;

  if (!desde || !hasta) {
    return res.status(400).json({ error: 'Parámetros desde y hasta son requeridos' });
  }
  const dateRegex = /^\d{4}-\d{2}-\d{2}$/;
  if (!dateRegex.test(desde) || !dateRegex.test(hasta)) {
    return res.status(400).json({ error: 'Formato de fecha inválido (YYYY-MM-DD)' });
  }
  if (isNaN(new Date(desde).getTime()) || isNaN(new Date(hasta).getTime())) {
    return res.status(400).json({ error: 'Fecha inválida' });
  }
  if (new Date(desde) > new Date(hasta)) {
    return res.status(400).json({ error: 'La fecha "desde" no puede ser posterior a "hasta"' });
  }

  try {
    const ventas = await queryVentasConProductos(
      "WHERE (v.fecha AT TIME ZONE 'America/Mexico_City')::date BETWEEN $1 AND $2",
      [desde, hasta]
    );
    res.json(ventas);
  } catch (error) {
    next(error);
  }
};
