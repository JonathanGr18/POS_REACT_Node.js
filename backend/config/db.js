const { Pool } = require('pg');
require('dotenv').config({ path: __dirname + '/../.env' });

// Validar variables de entorno críticas al iniciar
const required = ['DB_USER', 'DB_PASSWORD', 'HOST', 'DATABASE', 'PORT'];
required.forEach(v => {
  if (!process.env[v]) {
    console.error(`[DB] Variable de entorno "${v}" no definida. Revisa el archivo .env`);
    process.exit(1);
  }
});

const pool = new Pool({
  user:     process.env.DB_USER,
  host:     process.env.HOST,
  database: process.env.DATABASE,
  password: process.env.DB_PASSWORD,
  port:     parseInt(process.env.PORT, 10),

  // Pool configuration
  max:                    20,
  min:                    2,
  idleTimeoutMillis:      30000,
  connectionTimeoutMillis: 10000,
});

pool.on('error', (err) => {
  console.error('[DB] Error inesperado en pool de conexiones:', err.message);
});

module.exports = pool;
