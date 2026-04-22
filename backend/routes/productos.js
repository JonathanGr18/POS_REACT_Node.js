const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const sharp = require('sharp');
const rateLimit = require('express-rate-limit');
const pool = require('../config/db');
const productosCon = require('../controllers/productosCon');

// ── Rate limit para uploads (anti-DoS de disco) ──
const limiterUploads = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 15,
  standardHeaders: true,
  legacyHeaders: false,
  message: { error: 'Límite de subida de imágenes alcanzado' }
});

// ── Multer config ──────────────────────────────────────────────
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, path.join(__dirname, '..', 'uploads', 'productos'));
  },
  filename: (req, file, cb) => {
    // Generar nombre seguro (ignorar originalname del cliente)
    const ext = path.extname(file.originalname).toLowerCase().slice(0, 5);
    const extSegura = /^\.(jpg|jpeg|png|webp)$/.test(ext) ? ext : '.jpg';
    cb(null, `${Date.now()}-${Math.round(Math.random() * 1e9)}${extSegura}`);
  }
});

// Validacion en dos pasos: extension + MIME declarado
const MIME_PERMITIDOS = ['image/jpeg', 'image/jpg', 'image/png', 'image/webp'];
const EXT_PERMITIDAS = ['.jpg', '.jpeg', '.png', '.webp'];

const fileFilter = (req, file, cb) => {
  const ext = path.extname(file.originalname).toLowerCase();
  if (!EXT_PERMITIDAS.includes(ext)) {
    return cb(new Error('Solo se permiten imágenes jpg, jpeg, png o webp'));
  }
  if (!MIME_PERMITIDOS.includes(file.mimetype)) {
    return cb(new Error('Tipo de archivo no permitido'));
  }
  cb(null, true);
};

const upload = multer({
  storage,
  fileFilter,
  limits: { fileSize: 5 * 1024 * 1024 } // 5MB
});

// ── Procesamiento de imagen: convierte a WebP en 2 tamaños ──
// Devuelve { fullPath, thumbPath, fullUrl, thumbUrl } o lanza error.
const procesarImagen = async (origenPath, uploadsDir) => {
  // Base sin extensión, ej: 1775245917149-726030
  const baseName = path.basename(origenPath, path.extname(origenPath));
  const fullName = `${baseName}.webp`;
  const thumbName = `${baseName}.thumb.webp`;
  const fullDest = path.join(uploadsDir, fullName);
  const thumbDest = path.join(uploadsDir, thumbName);

  // Versión completa para modal/detalle: máx 800x800, fit inside (preserva aspect)
  await sharp(origenPath)
    .rotate() // respeta EXIF
    .resize(800, 800, { fit: 'inside', withoutEnlargement: true })
    .webp({ quality: 82 })
    .toFile(fullDest);

  // Thumbnail para grillas/catálogos: 200x200 cover (recorte cuadrado)
  await sharp(origenPath)
    .rotate()
    .resize(200, 200, { fit: 'cover' })
    .webp({ quality: 75 })
    .toFile(thumbDest);

  return {
    fullUrl: `/uploads/productos/${fullName}`,
    thumbUrl: `/uploads/productos/${thumbName}`,
  };
};

// Verificar magic bytes (MIME real) despues del upload
const verificarMagicBytes = (filepath) => {
  try {
    const buf = Buffer.alloc(12);
    const fd = fs.openSync(filepath, 'r');
    fs.readSync(fd, buf, 0, 12, 0);
    fs.closeSync(fd);

    // JPEG: FF D8 FF
    if (buf[0] === 0xFF && buf[1] === 0xD8 && buf[2] === 0xFF) return 'image/jpeg';
    // PNG: 89 50 4E 47 0D 0A 1A 0A
    if (buf[0] === 0x89 && buf[1] === 0x50 && buf[2] === 0x4E && buf[3] === 0x47) return 'image/png';
    // WebP: RIFF....WEBP
    if (buf[0] === 0x52 && buf[1] === 0x49 && buf[2] === 0x46 && buf[3] === 0x46
        && buf[8] === 0x57 && buf[9] === 0x45 && buf[10] === 0x42 && buf[11] === 0x50) return 'image/webp';
    return null;
  } catch {
    return null;
  }
};

// ── Rutas específicas PRIMERO (antes de /:id para evitar conflictos de Express)
router.get('/faltantes', productosCon.obtenerFaltantes);   // Productos con poco o sin stock
router.get('/categorias', productosCon.getCategorias);      // Categorías únicas
router.post('/egresos', productosCon.agregarEgreso);        // Registrar egreso (legacy, usar /api/egresos)
router.put('/resurtir/:id', productosCon.resurtirProducto); // Resurtir producto
router.post('/resurtir-masivo', productosCon.resurtirMasivo); // Resurtir varios productos a la vez

// Dada una URL tipo /uploads/productos/base.webp devuelve la del thumbnail
const thumbPathFromFull = (fullUrl) => {
  if (!fullUrl) return null;
  // Inserta .thumb antes de la extensión (sólo para webp generados por nosotros)
  return fullUrl.replace(/\.webp$/i, '.thumb.webp');
};

// Borrado seguro de full + thumb
const borrarImagenDisco = (imagenUrl) => {
  if (!imagenUrl) return;
  const fullPath = path.join(__dirname, '..', imagenUrl);
  fs.unlink(fullPath, () => {});
  const thumbUrl = thumbPathFromFull(imagenUrl);
  if (thumbUrl && thumbUrl !== imagenUrl) {
    fs.unlink(path.join(__dirname, '..', thumbUrl), () => {});
  }
};

// ── Imagen de producto ─────────────────────────────────────────
// POST /productos/:id/imagen — subir imagen
router.post('/:id/imagen', limiterUploads, upload.single('imagen'), async (req, res, next) => {
  const id = parseInt(req.params.id, 10);
  if (isNaN(id)) return res.status(400).json({ error: 'ID inválido' });
  if (!req.file) return res.status(400).json({ error: 'No se recibió ningún archivo' });

  // Verificar magic bytes (MIME real vs declarado) para evitar polyglots
  const mimeReal = verificarMagicBytes(req.file.path);
  if (!mimeReal) {
    fs.unlink(req.file.path, () => {});
    return res.status(400).json({ error: 'Archivo no es una imagen válida' });
  }

  const uploadsDir = path.dirname(req.file.path);
  let fullUrl, thumbUrl;

  // Procesar a WebP (full + thumb)
  try {
    const procesado = await procesarImagen(req.file.path, uploadsDir);
    fullUrl = procesado.fullUrl;
    thumbUrl = procesado.thumbUrl;
  } catch (err) {
    fs.unlink(req.file.path, () => {});
    console.error('[sharp] Error procesando imagen:', err?.message);
    return res.status(400).json({ error: 'No se pudo procesar la imagen' });
  }

  // Borrar original (ya tenemos full + thumb en WebP)
  fs.unlink(req.file.path, () => {});

  try {
    // Obtener imagen anterior para eliminarla
    const prev = await pool.query('SELECT imagen_url FROM productos WHERE id = $1', [id]);
    if (prev.rowCount === 0) {
      // Limpiar los webp recién generados
      borrarImagenDisco(fullUrl);
      return res.status(404).json({ error: 'Producto no encontrado' });
    }

    const prevUrl = prev.rows[0].imagen_url;

    // Guardar nueva URL en DB (URL de la versión full; thumb se deriva por convención)
    await pool.query('UPDATE productos SET imagen_url = $1 WHERE id = $2', [fullUrl, id]);

    // Eliminar archivos anteriores (full + thumb)
    borrarImagenDisco(prevUrl);

    res.json({ imagen_url: fullUrl, imagen_thumb_url: thumbUrl });
  } catch (err) {
    borrarImagenDisco(fullUrl);
    next(err);
  }
});

// DELETE /productos/:id/imagen — quitar imagen
router.delete('/:id/imagen', async (req, res, next) => {
  const id = parseInt(req.params.id, 10);
  if (isNaN(id)) return res.status(400).json({ error: 'ID inválido' });

  try {
    const sel = await pool.query('SELECT imagen_url FROM productos WHERE id = $1', [id]);
    if (sel.rowCount === 0) return res.status(404).json({ error: 'Producto no encontrado' });

    const prevUrl = sel.rows[0].imagen_url;
    await pool.query('UPDATE productos SET imagen_url = NULL WHERE id = $1', [id]);
    borrarImagenDisco(prevUrl); // limpia full + thumb

    res.json({ mensaje: 'Imagen eliminada' });
  } catch (err) {
    next(err);
  }
});

// ── CRUD de productos ──────────────────────────────────────────
router.get('/', productosCon.getProductos);
router.post('/', productosCon.createProducto);
router.put('/:id', productosCon.updateProducto);
router.delete('/:id', productosCon.deleteProducto);

module.exports = router;
