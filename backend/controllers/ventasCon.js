const pool = require('../config/db');

// Query auxiliar: obtiene ventas con sus productos en una sola query (elimina N+1)
// Soporta paginación opcional: pasa { limit, offset } para obtener una página.
const queryVentasConProductos = async (whereClause, params, opts = {}) => {
  const { limit, offset } = opts;
  let extra = '';
  const paramsLocal = [...params];
  if (Number.isInteger(limit) && limit > 0) {
    paramsLocal.push(limit);
    extra += ` LIMIT $${paramsLocal.length}`;
  }
  if (Number.isInteger(offset) && offset >= 0) {
    paramsLocal.push(offset);
    extra += ` OFFSET $${paramsLocal.length}`;
  }
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
            'id', dv.producto_id,
            'producto', dv.nombre,
            'descripcion', p.descripcion,
            'cantidad', dv.cantidad,
            'precio', dv.precio
          )
          ORDER BY dv.id
        ) FILTER (WHERE dv.id IS NOT NULL),
        '[]'
      ) AS productos
    FROM ventas v
    LEFT JOIN detalle_venta dv ON dv.venta_id = v.id
    LEFT JOIN productos p      ON p.id       = dv.producto_id
    ${whereClause}
    GROUP BY v.id, v.fecha, v.total, v.descuento, v.monto_recibido, v.metodo_pago
    ORDER BY v.fecha DESC
    ${extra}
  `, paramsLocal);
  return result.rows;
};

// Cuenta total de ventas que matchean el filtro (para paginación)
const contarVentas = async (whereClause, params) => {
  const { rows } = await pool.query(
    `SELECT COUNT(*)::int AS total FROM ventas v ${whereClause}`,
    params
  );
  return rows[0].total;
};

// Parsea y valida query params de paginación
const parsePagination = (req, maxLimit = 100, defaultLimit = 30) => {
  const page = Math.max(1, parseInt(req.query.page, 10) || 1);
  let limit = parseInt(req.query.limit, 10);
  if (!Number.isInteger(limit) || limit <= 0) limit = defaultLimit;
  if (limit > maxLimit) limit = maxLimit;
  return { page, limit, offset: (page - 1) * limit };
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
        'INSERT INTO detalle_venta (venta_id, producto_id, nombre, cantidad, precio) VALUES ($1, $2, $3, $4, $5)',
        [ventaId, p.id, p.nombre, p.cantidad, p.precio]
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

// Obtener ventas del día actual (TZ Mexico_City) — soporta paginado opcional
exports.obtenerVentasDelDia = async (req, res, next) => {
  try {
    const whereClause = "WHERE (v.fecha AT TIME ZONE 'America/Mexico_City')::date = (NOW() AT TIME ZONE 'America/Mexico_City')::date";
    // Si viene ?page=, devuelve respuesta paginada; si no, compat: devuelve array plano
    if (req.query.page != null || req.query.limit != null) {
      const { page, limit, offset } = parsePagination(req);
      const [ventas, total] = await Promise.all([
        queryVentasConProductos(whereClause, [], { limit, offset }),
        contarVentas(whereClause, []),
      ]);
      return res.json({ ventas, total, pagina: page, paginas: Math.max(1, Math.ceil(total / limit)), limit });
    }
    const ventas = await queryVentasConProductos(whereClause, []);
    res.json(ventas);
  } catch (error) { next(error); }
};

// Obtener ventas anteriores a hoy — soporta paginado opcional
exports.obtenerVentasAnteriores = async (req, res, next) => {
  try {
    const whereClause = "WHERE (v.fecha AT TIME ZONE 'America/Mexico_City')::date < (NOW() AT TIME ZONE 'America/Mexico_City')::date";
    if (req.query.page != null || req.query.limit != null) {
      const { page, limit, offset } = parsePagination(req);
      const [ventas, total] = await Promise.all([
        queryVentasConProductos(whereClause, [], { limit, offset }),
        contarVentas(whereClause, []),
      ]);
      return res.json({ ventas, total, pagina: page, paginas: Math.max(1, Math.ceil(total / limit)), limit });
    }
    const ventas = await queryVentasConProductos(whereClause, []);
    res.json(ventas);
  } catch (error) { next(error); }
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

// ── Helper: verificar contraseña admin ──
const crypto = require('crypto');
const bcrypt = require('bcrypt');
const verificarAdmin = async (password) => {
  if (!password || typeof password !== 'string') return false;
  const hash = process.env.ACCESS_PASSWORD_HASH;
  const plain = process.env.ACCESS_PASSWORD;
  if (!hash && !plain) return false;
  if (hash) return bcrypt.compare(password, hash);
  // Comparación constant-time
  const a = Buffer.from(String(password));
  const b = Buffer.from(String(plain));
  if (a.length !== b.length) { crypto.timingSafeEqual(a, a); return false; }
  return crypto.timingSafeEqual(a, b);
};

// ── EDITAR VENTA (productos + método pago + descuento) — requiere password admin ──
// Body: { password, metodo_pago?, descuento?, productos?: [{id?, nombre, cantidad, precio}], motivo? }
// Si viene `productos`, recalcula stock (delta por producto) y reemplaza detalle_venta.
exports.editarVenta = async (req, res, next) => {
  const { id } = req.params;
  const { metodo_pago, descuento, productos, password, motivo } = req.body || {};

  const ventaId = parseInt(id, 10);
  if (!id || isNaN(ventaId)) {
    return res.status(400).json({ error: 'ID de venta inválido' });
  }

  const esAdmin = await verificarAdmin(password);
  if (!esAdmin) {
    return res.status(401).json({ error: 'Contraseña de administrador incorrecta' });
  }

  const metodosValidos = ['efectivo', 'tarjeta', 'transferencia'];
  if (metodo_pago && !metodosValidos.includes(metodo_pago)) {
    return res.status(400).json({ error: 'Método de pago inválido' });
  }

  // Validar productos si se envía
  let productosNuevos = null;
  if (productos !== undefined) {
    if (!Array.isArray(productos) || productos.length === 0) {
      return res.status(400).json({ error: 'Debe haber al menos un producto en la venta' });
    }
    productosNuevos = [];
    for (const p of productos) {
      const cantidad = parseInt(p?.cantidad, 10);
      const precio = parseFloat(p?.precio);
      const nombre = typeof p?.nombre === 'string' ? p.nombre.trim() : null;
      const pid = p?.id != null ? parseInt(p.id, 10) : null;
      if (!nombre || !Number.isInteger(cantidad) || cantidad <= 0 || !isFinite(precio) || precio < 0) {
        return res.status(400).json({ error: `Producto inválido: ${nombre || 'sin nombre'}` });
      }
      productosNuevos.push({ id: pid, nombre, cantidad, precio });
    }
  }

  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    // Lock la venta
    const ventaRes = await client.query(
      'SELECT id, total, descuento, metodo_pago FROM ventas WHERE id = $1 FOR UPDATE',
      [ventaId]
    );
    if (ventaRes.rowCount === 0) {
      throw { status: 404, message: 'Venta no encontrada' };
    }
    const ventaPrev = ventaRes.rows[0];

    // Snapshot previo de productos (para devoluciones + recálculo stock)
    const detallePrev = await client.query(
      'SELECT producto_id, nombre, cantidad, precio::float AS precio FROM detalle_venta WHERE venta_id = $1',
      [ventaId]
    );
    // Clave compuesta: usa id cuando existe, sino "n:nombre"
    const claveDe = (r) => r.producto_id != null ? `id:${r.producto_id}` : `n:${r.nombre}`;
    const prevMap = {};  // clave → { cantidad, id, nombre }
    detallePrev.rows.forEach(d => {
      const k = claveDe(d);
      if (!prevMap[k]) prevMap[k] = { cantidad: 0, id: d.producto_id, nombre: d.nombre };
      prevMap[k].cantidad += Number(d.cantidad);
    });

    let nuevoTotal = Number(ventaPrev.total);
    let nuevoDesc = Number(ventaPrev.descuento);

    // Si cambian productos: recalcular stock con delta y reemplazar detalle
    if (productosNuevos) {
      const nuevoMap = {};
      productosNuevos.forEach(p => {
        const k = p.id != null ? `id:${p.id}` : `n:${p.nombre}`;
        if (!nuevoMap[k]) nuevoMap[k] = { cantidad: 0, id: p.id, nombre: p.nombre };
        nuevoMap[k].cantidad += p.cantidad;
      });

      // Todas las claves involucradas
      const claves = new Set([...Object.keys(prevMap), ...Object.keys(nuevoMap)]);

      for (const k of claves) {
        const prev = prevMap[k] || { cantidad: 0 };
        const next = nuevoMap[k] || { cantidad: 0 };
        const delta = prev.cantidad - next.cantidad;
        if (delta === 0) continue;

        const prodId = next.id ?? prev.id;
        const prodNombre = next.nombre ?? prev.nombre;

        // Ajuste: delta positivo = stock sube (producto salió); delta negativo = stock baja
        let upd;
        if (prodId != null) {
          // Match preciso por id (handles same-name products correctly)
          upd = await client.query(
            `UPDATE productos
               SET stock = stock + $1
               WHERE id = $2
               ${delta < 0 ? 'AND stock >= $3' : ''}
               RETURNING id`,
            delta < 0 ? [delta, prodId, -delta] : [delta, prodId]
          );
        } else {
          // Legacy fallback: match por nombre
          upd = await client.query(
            `UPDATE productos
               SET stock = stock + $1
               WHERE nombre = $2
               ${delta < 0 ? 'AND stock >= $3' : ''}
               RETURNING id`,
            delta < 0 ? [delta, prodNombre, -delta] : [delta, prodNombre]
          );
        }
        if (upd.rowCount === 0) {
          if (delta < 0) {
            throw { status: 409, message: `Stock insuficiente para "${prodNombre}" (faltan ${-delta})` };
          }
          console.warn(`[editarVenta] Producto "${prodNombre}" no se ajustó en stock`);
        }
      }

      // Reemplazar detalle_venta
      await client.query('DELETE FROM detalle_venta WHERE venta_id = $1', [ventaId]);
      for (const p of productosNuevos) {
        await client.query(
          'INSERT INTO detalle_venta (venta_id, producto_id, nombre, cantidad, precio) VALUES ($1, $2, $3, $4, $5)',
          [ventaId, p.id, p.nombre, p.cantidad, p.precio]
        );
      }

      // Recalcular total
      const subtotal = productosNuevos.reduce((a, p) => a + p.precio * p.cantidad, 0);
      if (descuento !== undefined) {
        nuevoDesc = Math.max(0, parseFloat(descuento) || 0);
      }
      nuevoTotal = round2(Math.max(0, subtotal - nuevoDesc));
    } else if (descuento !== undefined) {
      // Solo actualiza descuento (sin recalcular productos)
      nuevoDesc = Math.max(0, parseFloat(descuento) || 0);
    }

    // Actualizar venta
    const campos = ['total = $1', 'descuento = $2'];
    const valores = [nuevoTotal, nuevoDesc];
    let idx = 3;
    if (metodo_pago) {
      campos.push(`metodo_pago = $${idx++}`);
      valores.push(metodo_pago);
    }
    valores.push(ventaId);
    await client.query(
      `UPDATE ventas SET ${campos.join(', ')} WHERE id = $${idx}`,
      valores
    );

    // Registrar en devoluciones SI cambiaron productos o total (auditoría)
    const huboCambioProductos = productosNuevos !== null;
    const deltaTotal = round2(Number(ventaPrev.total) - nuevoTotal);
    if (huboCambioProductos || deltaTotal !== 0) {
      await client.query(
        `INSERT INTO devoluciones (venta_id, tipo, monto, productos, motivo)
         VALUES ($1, 'edicion', $2, $3::jsonb, $4)`,
        [
          ventaId,
          deltaTotal, // positivo si se redujo el monto (devolución parcial), negativo si aumentó
          JSON.stringify({ antes: detallePrev.rows, despues: productosNuevos }),
          motivo || null,
        ]
      );
    }

    await client.query('COMMIT');
    res.json({
      mensaje: 'Venta actualizada',
      venta_id: ventaId,
      total_nuevo: nuevoTotal,
      delta_total: deltaTotal,
    });
  } catch (error) {
    await client.query('ROLLBACK').catch(() => {});
    if (error.status) return res.status(error.status).json({ error: error.message });
    next(error);
  } finally {
    client.release();
  }
};

// ── ANULAR VENTA (devuelve stock + registra en devoluciones) — requiere password admin ──
exports.anularVenta = async (req, res, next) => {
  const { id } = req.params;
  const { password, motivo } = req.body || {};

  if (!id || isNaN(parseInt(id, 10))) {
    return res.status(400).json({ error: 'ID de venta inválido' });
  }

  // Verificar admin
  const esAdmin = await verificarAdmin(password);
  if (!esAdmin) {
    return res.status(401).json({ error: 'Contraseña de administrador incorrecta' });
  }

  const ventaId = parseInt(id, 10);
  const client = await pool.connect();

  try {
    await client.query('BEGIN');

    // Verificar que la venta existe
    const venta = await client.query(
      'SELECT id, total FROM ventas WHERE id = $1 FOR UPDATE',
      [ventaId]
    );
    if (venta.rowCount === 0) {
      throw { status: 404, message: 'Venta no encontrada' };
    }

    // Obtener productos de la venta para devolver stock + snapshot
    const detalles = await client.query(
      'SELECT nombre, cantidad, precio::float AS precio FROM detalle_venta WHERE venta_id = $1',
      [ventaId]
    );

    // Devolver stock de cada producto (buscar por nombre ya que no hay FK por id)
    for (const d of detalles.rows) {
      await client.query(
        `UPDATE productos SET stock = stock + $1
         WHERE nombre = $2`,
        [d.cantidad, d.nombre]
      );
    }

    // Registrar en devoluciones ANTES de eliminar
    await client.query(
      `INSERT INTO devoluciones (venta_id, tipo, monto, productos, motivo)
       VALUES ($1, 'anulacion', $2, $3::jsonb, $4)`,
      [
        ventaId,
        parseFloat(venta.rows[0].total),
        JSON.stringify(detalles.rows),
        motivo || null,
      ]
    );

    // Eliminar detalles y la venta
    await client.query('DELETE FROM detalle_venta WHERE venta_id = $1', [ventaId]);
    await client.query('DELETE FROM ventas WHERE id = $1', [ventaId]);

    await client.query('COMMIT');

    res.json({
      mensaje: 'Venta anulada y stock devuelto',
      venta_id: ventaId,
      productos_devueltos: detalles.rows.length,
      total_devuelto: parseFloat(venta.rows[0].total)
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
