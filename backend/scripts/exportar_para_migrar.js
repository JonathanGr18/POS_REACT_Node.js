/**
 * Genera un nuevo dump SQL completo de la BD actual.
 * Reemplaza backups/papepos_full.sql con el estado actual.
 */
const { execSync } = require('child_process');
const path = require('path');
const fs = require('fs');
require('dotenv').config({ path: path.join(__dirname, '..', '.env') });

const {
  DB_USER = 'postgres',
  DB_PASSWORD = '',
  HOST = '127.0.0.1',
  DATABASE = 'papepos',
  PORT = '5432',
} = process.env;

// Detectar pg_dump
const PG_DUMP_CANDIDATES = [
  'pg_dump',
  'C:\\Program Files\\PostgreSQL\\18\\bin\\pg_dump.exe',
  'C:\\Program Files\\PostgreSQL\\17\\bin\\pg_dump.exe',
  'C:\\Program Files\\PostgreSQL\\16\\bin\\pg_dump.exe',
];

function findPgDump() {
  for (const cmd of PG_DUMP_CANDIDATES) {
    try {
      execSync(`"${cmd}" --version`, { stdio: 'ignore' });
      return cmd;
    } catch {}
  }
  throw new Error('pg_dump no encontrado. Instala PostgreSQL o agrega a PATH.');
}

const pg_dump = findPgDump();
console.log(`Usando: ${pg_dump}`);

const outputDir = path.join(__dirname, '..', 'backups');
fs.mkdirSync(outputDir, { recursive: true });

const timestamp = new Date().toISOString().slice(0, 19).replace(/[:T]/g, '-');
const outputFile = path.join(outputDir, 'papepos_full.sql');
const timestampedFile = path.join(outputDir, `papepos_full_${timestamp}.sql`);

console.log(`Exportando BD "${DATABASE}" → ${outputFile}`);

const env = { ...process.env, PGPASSWORD: DB_PASSWORD };
execSync(
  `"${pg_dump}" -U ${DB_USER} -h ${HOST} -p ${PORT} -d ${DATABASE} --no-owner --no-privileges --clean --if-exists -f "${outputFile}"`,
  { stdio: 'inherit', env }
);

// Copiar con timestamp para histórico
fs.copyFileSync(outputFile, timestampedFile);

const stats = fs.statSync(outputFile);
console.log(`\n✅ Exportación completada`);
console.log(`   Tamaño: ${(stats.size / 1024).toFixed(1)} KB`);
console.log(`   Archivos:`);
console.log(`     - ${outputFile} (actual, siempre se sobreescribe)`);
console.log(`     - ${timestampedFile} (backup histórico)`);
console.log(`\nPara importar en otra PC:`);
console.log(`   psql -U postgres -d papepos -f papepos_full.sql`);
