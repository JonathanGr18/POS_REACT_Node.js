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

// Registrar una venta con productos
exports.registrarVenta = async (req, res, next) => {
  const { total, productos, descuento = 0, monto_recibido = 0, metodo_pago = 'efectivo' } = req.body;
  const metodosValidos = ['efectivo', 'tarjeta', 'transferencia'];
  const metodo = metodosValidos.includes(metodo_pago) ? metodo_pago : 'efectivo';

  if (!productos || !Array.isArray(productos) || productos.length === 0) {
    return res.status(400).json({ error: 'Se requiere al menos un producto' });
  }
  if (total === undefined || isNaN(total) || Number(total) <= 0) {
    return res.status(400).json({ error: 'Total inválido' });
  }

  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    // Validar stock suficiente ANTES de registrar (con FOR UPDATE para evitar race condition)
    for (const producto of productos) {
      if (!producto.id || isNaN(parseInt(producto.id, 10))) {
        throw { status: 400, message: 'ID de producto inválido' };
      }
      if (!producto.nombre || producto.nombre.toString().trim() === '') {
        throw { status: 400, message: 'Nombre de producto requerido' };
      }
      if (isNaN(producto.cantidad) || Number(producto.cantidad) <= 0) {
        throw { status: 400, message: 'Cantidad de producto inválida' };
      }
      if (isNaN(producto.precio) || Number(producto.precio) < 0) {
        throw { status: 400, message: 'Precio de producto inválido' };
      }

      const stockResult = await client.query(
        'SELECT stock FROM productos WHERE id = $1 FOR UPDATE',
        [parseInt(producto.id, 10)]
      );
      if (!stockResult.rows[0]) {
        throw { status: 404, message: `Producto ${producto.id} no encontrado` };
      }
      // BUG FIX: Castear cantidad a número para evitar comparación string vs number
      if (stockResult.rows[0].stock < Number(producto.cantidad)) {
        throw { status: 400, message: `Stock insuficiente para "${producto.nombre}"` };
      }
    }

    // Insertar venta
    const ventaResult = await client.query(
      'INSERT INTO ventas (fecha, total, descuento, monto_recibido, metodo_pago) VALUES (CURRENT_TIMESTAMP, $1, $2, $3, $4) RETURNING id',
      [total, descuento, monto_recibido, metodo]
    );
    const ventaId = ventaResult.rows[0].id;

    // Insertar detalles y actualizar stock
    for (const producto of productos) {
      await client.query(
        'INSERT INTO detalle_venta (venta_id, nombre, cantidad, precio) VALUES ($1, $2, $3, $4)',
        [ventaId, producto.nombre.toString().trim(), producto.cantidad, producto.precio]
      );
      await client.query(
        'UPDATE productos SET stock = stock - $1 WHERE id = $2',
        [producto.cantidad, producto.id]
      );
    }

    await client.query('COMMIT');
    res.status(201).json({ mensaje: 'Venta registrada con éxito', id: ventaId });

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

// Obtener ventas del día actual
exports.obtenerVentasDelDia = async (req, res, next) => {
  try {
    const ventas = await queryVentasConProductos('WHERE DATE(v.fecha) = CURRENT_DATE', []);
    res.json(ventas);
  } catch (error) {
    next(error);
  }
};

// Obtener ventas anteriores a hoy
exports.obtenerVentasAnteriores = async (req, res, next) => {
  try {
    const ventas = await queryVentasConProductos('WHERE DATE(v.fecha) < CURRENT_DATE', []);
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
      'WHERE DATE(v.fecha) BETWEEN $1 AND $2',
      [desde, hasta]
    );
    res.json(ventas);
  } catch (error) {
    next(error);
  }
};
