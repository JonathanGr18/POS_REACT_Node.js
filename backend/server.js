const express = require('express');
const cors = require('cors');
const app = express();
require('dotenv').config(); 

// Rutas
const productosRoutes = require('./routes/productos');
const ventasRoutes = require('./routes/ventas');
const reportesRoutes = require('./routes/reportes');

// Middlewares
app.use(cors()); // Habilita CORS
app.use(express.json()); // Parsea JSON

// Endpoints
app.use('/api/productos', productosRoutes);
app.use('/api/ventas', ventasRoutes);
app.use('/api/reportes', reportesRoutes);

// Servidor
const PORT = process.env.SERVER_PORT || 3000;
app.listen(PORT, () => {
  console.log(`Servidor en puerto ${PORT}`);
});
