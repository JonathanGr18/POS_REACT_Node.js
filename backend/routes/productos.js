const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const pool = require('../config/db');
const productosCon = require('../controllers/productosCon');

// ── Multer config ──────────────────────────────────────────────
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, path.join(__dirname, '..', 'uploads', 'productos'));
  },
  filename: (req, file, cb) => {
    const ext = path.extname(file.originalname).toLowerCase();
    cb(null, `${Date.now()}-${Math.round(Math.random() * 1e6)}${ext}`);
  }
});

const fileFilter = (req, file, cb) => {
  const allowed = ['.jpg', '.jpeg', '.png', '.webp'];
  const ext = path.extname(file.originalname).toLowerCase();
  if (allowed.includes(ext)) {
    cb(null, true);
  } else {
    cb(new Error('Solo se permiten imágenes jpg, jpeg, png o webp'));
  }
};

const upload = multer({
  storage,
  fileFilter,
  limits: { fileSize: 5 * 1024 * 1024 } // 5MB
});

// ── Rutas específicas PRIMERO (antes de /:id para evitar conflictos de Express)
router.get('/faltantes', productosCon.obtenerFaltantes);   // Productos con poco o sin stock
router.post('/egresos', productosCon.agregarEgreso);        // Registrar egreso
router.put('/resurtir/:id', productosCon.resurtirProducto); // Resurtir producto

// ── Imagen de producto ─────────────────────────────────────────
// POST /productos/:id/imagen — subir imagen
router.post('/:id/imagen', upload.single('imagen'), async (req, res, next) => {
  const id = parseInt(req.params.id, 10);
  if (isNaN(id)) return res.status(400).json({ error: 'ID inválido' });
  if (!req.file) return res.status(400).json({ error: 'No se recibió ningún archivo' });

  const imagen_url = `/uploads/productos/${req.file.filename}`;

  try {
    // Obtener imagen anterior para eliminarla
    const prev = await pool.query('SELECT imagen_url FROM productos WHERE id = $1', [id]);
    if (prev.rowCount === 0) return res.status(404).json({ error: 'Producto no encontrado' });

    const prevUrl = prev.rows[0].imagen_url;

    // Guardar nueva URL en DB
    await pool.query('UPDATE productos SET imagen_url = $1 WHERE id = $2', [imagen_url, id]);

    // Eliminar archivo anterior si existía
    if (prevUrl) {
      const prevPath = path.join(__dirname, '..', prevUrl);
      fs.unlink(prevPath, () => {}); // silencioso si no existe
    }

    res.json({ imagen_url });
  } catch (err) {
    // Si hay error de DB, borrar el archivo recién subido
    fs.unlink(req.file.path, () => {});
    next(err);
  }
});

// DELETE /productos/:id/imagen — quitar imagen
router.delete('/:id/imagen', async (req, res, next) => {
  const id = parseInt(req.params.id, 10);
  if (isNaN(id)) return res.status(400).json({ error: 'ID inválido' });

  try {
    // Obtener URL actual antes de limpiarla
    const sel = await pool.query('SELECT imagen_url FROM productos WHERE id = $1', [id]);
    if (sel.rowCount === 0) return res.status(404).json({ error: 'Producto no encontrado' });

    const prevUrl = sel.rows[0].imagen_url;

    await pool.query('UPDATE productos SET imagen_url = NULL WHERE id = $1', [id]);

    // Eliminar archivo físico si existía
    if (prevUrl) {
      const prevPath = path.join(__dirname, '..', prevUrl);
      fs.unlink(prevPath, () => {}); // silencioso si no existe
    }

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
