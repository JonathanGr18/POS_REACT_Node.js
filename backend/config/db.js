const { Pool } = require('pg');
require('dotenv').config({ path: __dirname + '/../.env' }); // Cargar variables de entorno

// Crear pool de conexión
const pool = new Pool({
  user: process.env.DB_USER,
  host: process.env.HOST,
  database: process.env.DATABASE,
  password: process.env.DB_PASSWORD,
  port: parseInt(process.env.PORT),
});

module.exports = pool; // Exportar pool
