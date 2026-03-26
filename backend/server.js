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

app.use('/api', limiterGeneral);
app.use('/api/ventas', limiterVentas);

app.use(express.json());

// Servir archivos estáticos (imágenes de productos)
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Endpoints
app.use('/api/productos', productosRoutes);
app.use('/api/ventas', ventasRoutes);
app.use('/api/reportes', reportesRoutes);
app.use('/api/dashboard', dashboardRoutes);
app.use('/api/tiendas', tiendasRoutes);
app.use('/api/lista-compras', listaComprasRoutes);

// Manejo centralizado de errores
app.use((err, req, res, next) => {
  console.error(`[ERROR] ${req.method} ${req.path}:`, err.message);
  const status = err.status || 500;
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
