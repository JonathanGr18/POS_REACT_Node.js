const express = require('express');
const cors = require('cors');
const path = require('path');
const rateLimit = require('express-rate-limit');
const helmet = require('helmet');
const app = express();
require('dotenv').config();

// Rutas
const productosRoutes = require('./routes/productos');
const ventasRoutes = require('./routes/ventas');
const reportesRoutes = require('./routes/reportes');
const dashboardRoutes = require('./routes/dashboard');
const tiendasRoutes = require('./routes/tiendas');
const listaComprasRoutes = require('./routes/listaCompras');
const iaRoutes = require('./routes/ia');
const egresosRoutes = require('./routes/egresos');
const authRoutes = require('./routes/auth');

// Middlewares
app.use(cors({
  origin: process.env.CORS_ORIGIN
    ? process.env.CORS_ORIGIN.split(',')
    : ['http://localhost:3000', 'http://localhost:3001'],
  methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE'],
  optionsSuccessStatus: 200
}));

// Seguridad: headers HTTP
app.use(helmet({
  crossOriginResourcePolicy: { policy: 'cross-origin' }
}));

// Rate limiting general: 200 requests por 15 minutos por IP
const limiterGeneral = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 200,
  standardHeaders: true,
  legacyHeaders: false,
  message: { error: 'Demasiadas solicitudes, intenta más tarde' }
});

// Rate limiting estricto para ventas: 60 por 15 minutos (evita spam de ventas)
const limiterVentas = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 60,
  standardHeaders: true,
  legacyHeaders: false,
  message: { error: 'Límite de registro de ventas alcanzado' }
});

// Rate limiting para autenticación: 10 intentos por 15 minutos (anti brute-force)
const limiterAuth = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 10,
  standardHeaders: true,
  legacyHeaders: false,
  message: { error: 'Demasiados intentos de acceso, intenta más tarde' }
});

// Rate limiting para IA: 20 mensajes por 15 min (anti abuse de tokens DeepSeek)
const limiterIA = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 20,
  standardHeaders: true,
  legacyHeaders: false,
  message: { error: 'Demasiadas consultas al asistente IA, intenta más tarde' }
});

app.use('/api', limiterGeneral);
app.use('/api/auth', limiterAuth);
app.use('/api/ventas', limiterVentas);
app.use('/api/ia', limiterIA);

// JSON body limitado + strict. verify() valida el raw body ANTES de parsear
// para detectar claves peligrosas que Node podría eliminar silenciosamente.
app.use(express.json({
  limit: '200kb',
  strict: true,
  verify: (req, res, buf) => {
    if (buf.length === 0) return;
    const raw = buf.toString('utf8');
    // Detectar __proto__, constructor, prototype como claves JSON
    if (/"__proto__"\s*:/.test(raw) || /"constructor"\s*:/.test(raw) || /"prototype"\s*:/.test(raw)) {
      const err = new SyntaxError('Request body contiene claves prohibidas');
      err.status = 400;
      throw err;
    }
  }
}));

// Asegurar req.body siempre sea un objeto en POST/PUT/PATCH (evita crash en destructuring)
app.use((req, res, next) => {
  if (['POST', 'PUT', 'PATCH'].includes(req.method) && (req.body == null || typeof req.body !== 'object')) {
    req.body = {};
  }
  next();
});

// Anti prototype pollution: rechazar claves peligrosas en req.body
// Usa getOwnPropertyNames porque __proto__ es non-enumerable
const clavesProhibidas = ['__proto__', 'constructor', 'prototype'];
const tieneClavesProhibidas = (obj, depth = 0) => {
  if (depth > 5 || !obj || typeof obj !== 'object') return false;
  // Detectar incluso propiedades no enumerables
  const keys = Object.getOwnPropertyNames(obj);
  for (const key of keys) {
    if (clavesProhibidas.includes(key)) return true;
    const val = obj[key];
    if (typeof val === 'object' && val !== null && tieneClavesProhibidas(val, depth + 1)) return true;
  }
  return false;
};
app.use((req, res, next) => {
  if (req.body && typeof req.body === 'object' && tieneClavesProhibidas(req.body)) {
    return res.status(400).json({ error: 'Request body inválido' });
  }
  next();
});

// Servir archivos estáticos (imágenes de productos)
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Endpoints
app.use('/api/productos', productosRoutes);
app.use('/api/ventas', ventasRoutes);
app.use('/api/reportes', reportesRoutes);
app.use('/api/dashboard', dashboardRoutes);
app.use('/api/tiendas', tiendasRoutes);
app.use('/api/lista-compras', listaComprasRoutes);
app.use('/api/ia', iaRoutes);
app.use('/api/egresos', egresosRoutes);
app.use('/api/auth', authRoutes);

// Manejo centralizado de errores
app.use((err, req, res, next) => {
  console.error(`[ERROR] ${req.method} ${req.path}:`, err.message);
  const status = err.status || 500;
  const isProd = process.env.NODE_ENV === 'production';
  // En produccion, no exponer detalles internos en errores 500
  if (status >= 500 && isProd) {
    return res.status(status).json({ error: 'Error interno del servidor' });
  }
  res.status(status).json({ error: err.message || 'Error interno del servidor' });
});

// Ruta no encontrada
app.use((req, res) => {
  res.status(404).json({ error: 'Ruta no encontrada' });
});

// Servidor
const PORT = process.env.SERVER_PORT || 3000;
app.listen(PORT, () => {
  console.log(`Servidor en puerto ${PORT}`);
});
