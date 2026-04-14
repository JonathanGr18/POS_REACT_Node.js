const express = require('express');
const router = express.Router();
const crypto = require('crypto');
const bcrypt = require('bcrypt');

// Comparación en tiempo constante (anti timing-attack)
const safeCompare = (a, b) => {
  const aBuf = Buffer.from(String(a));
  const bBuf = Buffer.from(String(b));
  if (aBuf.length !== bBuf.length) {
    // Aún así hacer una comparación para igualar tiempos
    crypto.timingSafeEqual(aBuf, aBuf);
    return false;
  }
  return crypto.timingSafeEqual(aBuf, bBuf);
};

// POST /api/auth/verificar — validar contraseña de acceso a productos
router.post('/verificar', async (req, res) => {
  const { password } = req.body || {};

  if (!password || typeof password !== 'string') {
    return res.status(400).json({ error: 'Contraseña requerida' });
  }

  const hash = process.env.ACCESS_PASSWORD_HASH;
  const plain = process.env.ACCESS_PASSWORD;

  // No permitir arranque sin credencial configurada (evita fallback "admin" inseguro)
  if (!hash && !plain) {
    console.error('[AUTH] Ninguna variable ACCESS_PASSWORD o ACCESS_PASSWORD_HASH configurada. Acceso rechazado.');
    return res.status(503).json({ error: 'Autenticación no configurada en el servidor' });
  }

  try {
    let ok = false;
    if (hash) {
      ok = await bcrypt.compare(password, hash);
    } else {
      ok = safeCompare(password, plain);
    }

    if (ok) return res.json({ autorizado: true });
    return res.status(401).json({ error: 'Contraseña incorrecta', autorizado: false });
  } catch (err) {
    console.error('[AUTH] Error interno:', err.message);
    return res.status(500).json({ error: 'Error de autenticación' });
  }
});

module.exports = router;
