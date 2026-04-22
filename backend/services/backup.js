/**
 * Servicio de backup de BD con pg_dump + compresión gzip.
 * - Uso manual (ejecutarBackup) desde endpoint admin.
 * - Programado (iniciarBackupProgramado) cada 24h, rota los últimos N.
 */
const { execFile } = require('child_process');
const path = require('path');
const fs = require('fs');
const zlib = require('zlib');
const { pipeline } = require('stream/promises');
const cron = require('node-cron');

const BACKUPS_DIR = path.join(__dirname, '..', 'backups');
const MAX_BACKUPS = 14;      // rotar: mantener solo los últimos 14
const CRON_EXPR = '0 3 * * *'; // 3:00 AM todos los días

const PG_DUMP_CANDIDATES = [
  'pg_dump',
  'C:\\Program Files\\PostgreSQL\\18\\bin\\pg_dump.exe',
  'C:\\Program Files\\PostgreSQL\\17\\bin\\pg_dump.exe',
  'C:\\Program Files\\PostgreSQL\\16\\bin\\pg_dump.exe',
  'C:\\Program Files\\PostgreSQL\\15\\bin\\pg_dump.exe',
];

let pgDumpCache = null;

function encontrarPgDump() {
  if (pgDumpCache) return pgDumpCache;
  const { execSync } = require('child_process');
  for (const cmd of PG_DUMP_CANDIDATES) {
    try {
      execSync(`"${cmd}" --version`, { stdio: 'ignore' });
      pgDumpCache = cmd;
      return cmd;
    } catch {}
  }
  throw new Error('pg_dump no encontrado en PATH. Instala PostgreSQL o agrega a PATH.');
}

function ahoraStamp() {
  const d = new Date();
  const pad = (n) => String(n).padStart(2, '0');
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}_${pad(d.getHours())}-${pad(d.getMinutes())}-${pad(d.getSeconds())}`;
}

function asegurarDir() {
  fs.mkdirSync(BACKUPS_DIR, { recursive: true });
}

/**
 * Ejecuta pg_dump y comprime el resultado a un .sql.gz fechado.
 * Devuelve la ruta absoluta del archivo generado.
 */
async function ejecutarBackup({ tipo = 'manual' } = {}) {
  asegurarDir();

  const pg_dump = encontrarPgDump();
  const stamp = ahoraStamp();
  const nombre = `papepos_${tipo}_${stamp}.sql.gz`;
  const destino = path.join(BACKUPS_DIR, nombre);
  const tmpSql = path.join(BACKUPS_DIR, `.tmp_${stamp}.sql`);

  const {
    DB_USER = 'postgres',
    DB_PASSWORD = '',
    HOST = '127.0.0.1',
    DATABASE = 'papepos',
    PORT = '5432',
  } = process.env;

  const args = [
    '-U', DB_USER,
    '-h', HOST,
    '-p', String(PORT),
    '-d', DATABASE,
    '--no-owner',
    '--no-privileges',
    '--clean',
    '--if-exists',
    '-f', tmpSql,
  ];

  // Ejecutar pg_dump
  await new Promise((resolve, reject) => {
    const env = { ...process.env, PGPASSWORD: DB_PASSWORD };
    execFile(pg_dump, args, { env, maxBuffer: 200 * 1024 * 1024 }, (err, stdout, stderr) => {
      if (err) {
        try { fs.unlinkSync(tmpSql); } catch {}
        return reject(new Error(stderr || err.message));
      }
      resolve();
    });
  });

  // Comprimir a .sql.gz
  try {
    await pipeline(
      fs.createReadStream(tmpSql),
      zlib.createGzip({ level: 9 }),
      fs.createWriteStream(destino)
    );
    fs.unlinkSync(tmpSql);
  } catch (err) {
    try { fs.unlinkSync(tmpSql); } catch {}
    try { fs.unlinkSync(destino); } catch {}
    throw err;
  }

  return destino;
}

/**
 * Lista los backups existentes (más recientes primero).
 */
function listarBackups() {
  asegurarDir();
  return fs.readdirSync(BACKUPS_DIR)
    .filter(f => f.endsWith('.sql.gz'))
    .map(f => {
      const p = path.join(BACKUPS_DIR, f);
      const st = fs.statSync(p);
      return {
        nombre: f,
        tamano: st.size,
        fecha: st.mtime.toISOString(),
      };
    })
    .sort((a, b) => b.fecha.localeCompare(a.fecha));
}

/**
 * Elimina backups más viejos, manteniendo solo los últimos `max`.
 */
function rotarBackups(max = MAX_BACKUPS) {
  const lista = listarBackups();
  if (lista.length <= max) return 0;
  const aBorrar = lista.slice(max);
  for (const b of aBorrar) {
    try { fs.unlinkSync(path.join(BACKUPS_DIR, b.nombre)); } catch {}
  }
  return aBorrar.length;
}

/**
 * Arranca el job programado cada 24h a las 3 AM.
 */
function iniciarBackupProgramado() {
  if (process.env.BACKUP_DISABLED === '1') {
    console.log('[backup] Deshabilitado por BACKUP_DISABLED=1');
    return;
  }
  cron.schedule(CRON_EXPR, async () => {
    console.log('[backup] Ejecutando respaldo programado...');
    try {
      const archivo = await ejecutarBackup({ tipo: 'auto' });
      const rotados = rotarBackups();
      console.log(`[backup] OK: ${path.basename(archivo)} (rotados ${rotados})`);
    } catch (err) {
      console.error('[backup] Falló respaldo programado:', err.message);
    }
  }, { timezone: process.env.TZ || 'America/Mexico_City' });
  console.log(`[backup] Programado: "${CRON_EXPR}" (mantiene últimos ${MAX_BACKUPS})`);
}

/**
 * Borra un backup por nombre (valida que exista y esté en BACKUPS_DIR).
 */
function borrarBackup(nombre) {
  if (!nombre || typeof nombre !== 'string') return false;
  // Prevenir path traversal
  if (nombre.includes('/') || nombre.includes('\\') || nombre.includes('..')) return false;
  if (!nombre.endsWith('.sql.gz')) return false;
  const destino = path.join(BACKUPS_DIR, nombre);
  if (!fs.existsSync(destino)) return false;
  fs.unlinkSync(destino);
  return true;
}

function rutaBackup(nombre) {
  if (!nombre || typeof nombre !== 'string') return null;
  if (nombre.includes('/') || nombre.includes('\\') || nombre.includes('..')) return null;
  if (!nombre.endsWith('.sql.gz')) return null;
  const destino = path.join(BACKUPS_DIR, nombre);
  if (!fs.existsSync(destino)) return null;
  return destino;
}

module.exports = {
  ejecutarBackup,
  listarBackups,
  rotarBackups,
  iniciarBackupProgramado,
  borrarBackup,
  rutaBackup,
  BACKUPS_DIR,
};
