const express = require('express');
const router = express.Router();
const path = require('path');
const bcrypt = require('bcrypt');
const crypto = require('crypto');
const {
  ejecutarBackup,
  listarBackups,
  rotarBackups,
  borrarBackup,
  rutaBackup,
} = require('../services/backup');

// Comparación constante
const safeCompare = (a, b) => {
  const aBuf = Buffer.from(String(a));
  const bBuf = Buffer.from(String(b));
  if (aBuf.length !== bBuf.length) {
    crypto.timingSafeEqual(aBuf, aBuf);
    return false;
  }
  return crypto.timingSafeEqual(aBuf, bBuf);
};

// Middleware: requiere header x-admin-password con la clave de acceso
const requiereAdmin = async (req, res, next) => {
  const pass = req.get('x-admin-password') || req.body?.password || req.query?.password;
  if (!pass) return res.status(401).json({ error: 'Contraseña requerida' });

  const hash = process.env.ACCESS_PASSWORD_HASH;
  const plain = process.env.ACCESS_PASSWORD;
  if (!hash && !plain) {
    return res.status(503).json({ error: 'Autenticación no configurada' });
  }

  try {
    const ok = hash ? await bcrypt.compare(pass, hash) : safeCompare(pass, plain);
    if (!ok) return res.status(401).json({ error: 'Contraseña incorrecta' });
    next();
  } catch {
    return res.status(500).json({ error: 'Error de autenticación' });
  }
};

// GET /api/admin/backups — lista de respaldos existentes
router.get('/backups', requiereAdmin, (req, res) => {
  try {
    res.json(listarBackups());
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// POST /api/admin/backups — genera respaldo nuevo (on-demand) y devuelve metadata
router.post('/backups', requiereAdmin, async (req, res) => {
  try {
    const archivo = await ejecutarBackup({ tipo: 'manual' });
    rotarBackups();
    const nombre = path.basename(archivo);
    res.json({ mensaje: 'Respaldo creado', nombre });
  } catch (err) {
    console.error('[admin/backup] Error:', err.message);
    res.status(500).json({ error: err.message });
  }
});

// GET /api/admin/backups/:nombre/descargar — descarga el .sql.gz
router.get('/backups/:nombre/descargar', requiereAdmin, (req, res) => {
  const ruta = rutaBackup(req.params.nombre);
  if (!ruta) return res.status(404).json({ error: 'Respaldo no encontrado' });
  res.download(ruta, req.params.nombre);
});

// DELETE /api/admin/backups/:nombre — elimina un respaldo
router.delete('/backups/:nombre', requiereAdmin, (req, res) => {
  const ok = borrarBackup(req.params.nombre);
  if (!ok) return res.status(404).json({ error: 'Respaldo no encontrado' });
  res.json({ mensaje: 'Respaldo eliminado' });
});

module.exports = router;
