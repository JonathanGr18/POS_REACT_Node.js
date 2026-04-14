const pool = require('../config/db');
const fs = require('fs');
const path = require('path');

// Normaliza tipos numéricos de un producto
const normalizeProducto = (row) => {
  const sm = parseInt(row.stock_minimo, 10);
  return {
    ...row,
    precio:       parseFloat(row.precio),
    precio_costo: parseFloat(row.precio_costo) || 0,
    stock:        parseInt(row.stock, 10),
    // Respetar 0 explicito (no sobreescribir con fallback)
    stock_minimo: Number.isNaN(sm) ? 15 : sm,
  };
};

// Obtener todos los productos
exports.getProductos = async (req, res, next) => {
  try {
    const result = await pool.query('SELECT id, nombre, precio, precio_costo, descripcion, codigo, stock, stock_minimo, status, imagen_url, categoria FROM productos ORDER BY nombre ASC');
    res.json(result.rows.map(normalizeProducto));
  } catch (error) {
    next(error);
  }
};

// Obtener categorías únicas
exports.getCategorias = async (req, res, next) => {
  try {
    const result = await pool.query("SELECT DISTINCT categoria FROM productos WHERE categoria IS NOT NULL AND categoria != '' ORDER BY categoria ASC");
    res.json(result.rows.map(r => r.categoria));
  } catch (error) {
    next(error);
  }
};

// Helper: capitaliza cada palabra (Title Case) respetando articulos cortos en minuscula
// Ej: "impresion b/n" -> "Impresion B/N", "hoja de papel" -> "Hoja de Papel"
const ARTICULOS_MINUS = new Set(['de', 'del', 'la', 'el', 'los', 'las', 'y', 'o', 'a', 'en', 'con', 'para', 'por']);
const capitalizarNombre = (texto) => {
  if (typeof texto !== 'string') return texto;
  return texto
    .trim()
    .split(/\s+/)
    .map((palabra, idx) => {
      if (!palabra) return palabra;
      const lower = palabra.toLowerCase();
      // La primera palabra siempre va capitalizada. Articulos en medio van en minuscula.
      if (idx > 0 && ARTICULOS_MINUS.has(lower)) return lower;
      // Capitalizar tramos separados por /, -, ( (para "Impresion B/N", "Hoja A-4")
      return lower.replace(/(^|[\/\-(])([a-záéíóúñü])/g, (m, sep, ch) => sep + ch.toUpperCase());
    })
    .join(' ');
};

// Helper: valida y sanitiza strings con limite de longitud
const validarString = (valor, max, requerido = false, label = 'campo') => {
  if (valor == null || valor === '') {
    if (requerido) throw { status: 400, message: `${label} es requerido` };
    return null;
  }
  if (typeof valor !== 'string') {
    throw { status: 400, message: `${label} inválido` };
  }
  // Quitar null bytes (pueden romper queries)
  const limpio = valor.replace(/\x00/g, '').trim();
  if (limpio === '' && requerido) throw { status: 400, message: `${label} es requerido` };
  if (limpio.length > max) throw { status: 400, message: `${label} demasiado largo (máx ${max} caracteres)` };
  return limpio;
};

// Crear nuevo producto
exports.createProducto = async (req, res, next) => {
  const { precio, precio_costo, stock, stock_minimo, status } = req.body || {};

  let nombre, codigo, descripcion, categoria;
  try {
    nombre = validarString(req.body.nombre, 200, true, 'El nombre');
    codigo = validarString(req.body.codigo?.toString(), 50, true, 'El código');
    descripcion = validarString(req.body.descripcion, 500, false, 'La descripción') || 'Sin descripcion';
    categoria = validarString(req.body.categoria, 100, false, 'La categoría') || 'General';
  } catch (e) {
    if (e.status) return res.status(e.status).json({ error: e.message });
    throw e;
  }

  // Capitalizar nombre y categoria (Title Case)
  nombre = capitalizarNombre(nombre);
  categoria = capitalizarNombre(categoria);

  if (precio === undefined || isNaN(precio) || Number(precio) < 0) return res.status(400).json({ error: 'Precio inválido' });
  if (stock === undefined || isNaN(stock) || Number(stock) < 0) return res.status(400).json({ error: 'Stock inválido' });

  // Respetar stock_minimo = 0 explícito (usar ?? no ||)
  const stockMinimoNum = stock_minimo !== undefined && stock_minimo !== null && stock_minimo !== ''
    ? Number(stock_minimo)
    : 15;
  if (!Number.isFinite(stockMinimoNum) || stockMinimoNum < 0) {
    return res.status(400).json({ error: 'stock_minimo inválido' });
  }

  try {
    const result = await pool.query(
      `INSERT INTO productos (nombre, precio, precio_costo, descripcion, codigo, stock, stock_minimo, status, categoria)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9) RETURNING *`,
      [
        nombre,
        Number(precio),
        Number(precio_costo) || 0,
        descripcion,
        codigo,
        Number(stock),
        stockMinimoNum,
        typeof status === 'boolean' ? status : true,
        categoria
      ]
    );
    res.status(201).json(normalizeProducto(result.rows[0]));
  } catch (error) {
    if (error.code === '23505') return res.status(409).json({ error: 'Ya existe un producto con ese código' });
    next(error);
  }
};

// Actualizar producto
exports.updateProducto = async (req, res, next) => {
  const { id } = req.params;
  if (!id || isNaN(parseInt(id, 10))) return res.status(400).json({ error: 'ID inválido' });

  const { precio, precio_costo, stock, stock_minimo, status } = req.body || {};

  let nombre, codigo, descripcion, categoria;
  try {
    nombre = validarString(req.body.nombre, 200, true, 'El nombre');
    codigo = validarString(req.body.codigo?.toString(), 50, true, 'El código');
    descripcion = validarString(req.body.descripcion, 500, false, 'La descripción') || 'Sin descripcion';
    categoria = validarString(req.body.categoria, 100, false, 'La categoría') || 'General';
  } catch (e) {
    if (e.status) return res.status(e.status).json({ error: e.message });
    throw e;
  }

  // Capitalizar nombre y categoria (Title Case)
  nombre = capitalizarNombre(nombre);
  categoria = capitalizarNombre(categoria);

  if (precio === undefined || isNaN(precio) || Number(precio) < 0) return res.status(400).json({ error: 'Precio inválido' });
  if (stock === undefined || isNaN(stock) || Number(stock) < 0) return res.status(400).json({ error: 'Stock inválido' });

  // Respetar stock_minimo = 0 explícito
  const stockMinimoNum = stock_minimo !== undefined && stock_minimo !== null && stock_minimo !== ''
    ? Number(stock_minimo)
    : 15;
  if (!Number.isFinite(stockMinimoNum) || stockMinimoNum < 0) {
    return res.status(400).json({ error: 'stock_minimo inválido' });
  }

  try {
    const result = await pool.query(
      `UPDATE productos SET nombre = $1, precio = $2, precio_costo = $3, descripcion = $4, codigo = $5,
       stock = $6, stock_minimo = $7, status = $8, categoria = $9 WHERE id = $10 RETURNING *`,
      [
        nombre,
        Number(precio),
        Number(precio_costo) || 0,
        descripcion,
        codigo,
        Number(stock),
        stockMinimoNum,
        typeof status === 'boolean' ? status : true,
        categoria,
        parseInt(id, 10)
      ]
    );

    if (result.rowCount === 0) return res.status(404).json({ error: 'Producto no encontrado' });

    res.json(normalizeProducto(result.rows[0]));
  } catch (error) {
    if (error.code === '23505') return res.status(409).json({ error: 'Ya existe un producto con ese código' });
    next(error);
  }
};

// Eliminar producto
exports.deleteProducto = async (req, res, next) => {
  const { id } = req.params;
  if (!id || isNaN(parseInt(id, 10))) return res.status(400).json({ error: 'ID inválido' });

  try {
    const result = await pool.query('DELETE FROM productos WHERE id = $1 RETURNING *', [parseInt(id, 10)]);

    if (result.rowCount === 0) return res.status(404).json({ error: 'Producto no encontrado' });

    // Limpiar imagen del disco si existia (evita leak de archivos huerfanos)
    const imagenUrl = result.rows[0]?.imagen_url;
    if (imagenUrl) {
      const rutaImagen = path.join(__dirname, '..', imagenUrl);
      fs.unlink(rutaImagen, () => { /* silencioso si no existe */ });
    }

    res.json({ mensaje: 'Producto eliminado correctamente' });
  } catch (error) {
    next(error);
  }
};

// Obtener productos faltantes (stock bajo) con conteo de ventas del último mes
// Usa stock_minimo individual de cada producto como umbral
exports.obtenerFaltantes = async (req, res, next) => {
  // Validar query param umbral (si viene invalido → 400)
  let fallback = 15;
  if (req.query.umbral !== undefined) {
    const umbralGlobal = parseInt(req.query.umbral, 10);
    if (isNaN(umbralGlobal) || umbralGlobal <= 0 || umbralGlobal > 1000) {
      return res.status(400).json({ error: 'Parametro umbral invalido (entero 1-1000)' });
    }
    fallback = umbralGlobal;
  }
  try {
    const result = await pool.query(`
      SELECT
        p.id, p.nombre, p.codigo, p.descripcion, p.stock, p.status, p.imagen_url,
        p.precio, p.precio_costo, p.categoria, p.stock_minimo,
        COALESCE(SUM(dv.cantidad)::int, 0) AS vendidos_mes
      FROM productos p
      LEFT JOIN detalle_venta dv ON dv.nombre = p.nombre
      LEFT JOIN ventas v ON v.id = dv.venta_id
        AND v.fecha >= NOW() - INTERVAL '30 days'
      WHERE p.stock <= COALESCE(NULLIF(p.stock_minimo, 0), $1)
      GROUP BY p.id
      ORDER BY p.stock ASC
    `, [fallback]);
    res.json(result.rows.map(r => ({ ...normalizeProducto(r), vendidos_mes: Number(r.vendidos_mes) })));
  } catch (error) {
    next(error);
  }
};

// Resurtir stock de producto
exports.resurtirProducto = async (req, res, next) => {
  const { id } = req.params;
  const { cantidad } = req.body || {};

  if (!id || isNaN(parseInt(id, 10))) return res.status(400).json({ error: 'ID inválido' });
  // Validar entero estricto (no permitir decimales ni strings numericas tipo "1.5")
  const cantidadNum = Number(cantidad);
  if (!Number.isInteger(cantidadNum) || cantidadNum <= 0) {
    return res.status(400).json({ error: 'Cantidad debe ser un entero positivo' });
  }
  const cantidadParsed = cantidadNum;
  if (cantidadParsed > 100000) {
    return res.status(400).json({ error: 'Cantidad de resurtido fuera de rango (máx 100,000)' });
  }

  try {
    // Validar que stock+cantidad no supere INT32 max de Postgres
    const result = await pool.query(
      `UPDATE productos SET stock = stock + $1
       WHERE id = $2 AND (stock + $1) <= 2000000000
       RETURNING *`,
      [cantidadParsed, parseInt(id, 10)]
    );
    if (result.rowCount === 0) {
      // Verificar si existe para dar mensaje correcto
      const existe = await pool.query('SELECT id FROM productos WHERE id = $1', [parseInt(id, 10)]);
      if (existe.rowCount === 0) return res.status(404).json({ error: 'Producto no encontrado' });
      return res.status(400).json({ error: 'El stock resultante excede el límite permitido' });
    }
    res.status(200).json({ mensaje: 'Producto resurtido', producto: normalizeProducto(result.rows[0]) });
  } catch (error) {
    next(error);
  }
};

// Registrar egreso
exports.agregarEgreso = async (req, res, next) => {
  const { monto, concepto } = req.body || {};

  const montoNum = Number(monto);
  if (!Number.isFinite(montoNum) || montoNum <= 0) {
    return res.status(400).json({ error: 'Monto inválido' });
  }
  if (montoNum > 999999.99) {
    return res.status(400).json({ error: 'Monto fuera de rango' });
  }

  // Validar concepto: debe ser string o null
  let conceptoLimpio = null;
  if (concepto != null) {
    if (typeof concepto !== 'string') {
      return res.status(400).json({ error: 'Concepto inválido' });
    }
    conceptoLimpio = concepto.trim().slice(0, 200) || null;
  }

  try {
    await pool.query(
      'INSERT INTO egresos (monto, concepto) VALUES ($1, $2)',
      [montoNum, conceptoLimpio]
    );
    res.status(201).json({ mensaje: 'Egreso registrado correctamente' });
  } catch (error) {
    next(error);
  }
};
