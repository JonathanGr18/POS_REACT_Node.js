/**
 * Script para importar datos desde respaldo_total_pos.sql (esquema viejo)
 * a la nueva estructura de BD del POS.
 *
 * Mapeo:
 *   productos: agrega categoria='General', precio_costo=0, stock_minimo=15, imagen_url=null
 *   ventas: agrega descuento=0, monto_recibido=total, metodo_pago='efectivo'
 *   detalle_venta: copia tal cual
 *   egresos: agrega concepto=null
 *   calendario y reportes: NO se importan (legacy)
 */

const fs = require('fs');
const path = require('path');
const pool = require('../config/db');

const SQL_FILE = path.join(__dirname, '..', '..', '..', 'respaldo_total_pos.sql');

// Parsea un bloque COPY del SQL file
// Retorna array de arrays con los valores de cada fila
function parseCopyBlock(content, tableName) {
  const startRegex = new RegExp(`COPY public\\.${tableName}\\s*\\([^)]+\\)\\s*FROM stdin;\\s*\\n`);
  const startMatch = content.match(startRegex);
  if (!startMatch) {
    console.warn(`[WARN] No se encontró bloque COPY para ${tableName}`);
    return [];
  }
  const startIdx = startMatch.index + startMatch[0].length;
  const endIdx = content.indexOf('\n\\.\n', startIdx);
  if (endIdx === -1) {
    console.warn(`[WARN] No se encontró fin (\\.) del COPY de ${tableName}`);
    return [];
  }
  const block = content.slice(startIdx, endIdx);
  const lines = block.split('\n').filter(l => l.length > 0);

  return lines.map(line => {
    // Parsear TSV: campos separados por \t, \N = null, \\ = \, \t = tab
    const fields = line.split('\t').map(f => {
      if (f === '\\N') return null;
      return f
        .replace(/\\n/g, '\n')
        .replace(/\\r/g, '\r')
        .replace(/\\t/g, '\t')
        .replace(/\\\\/g, '\\');
    });
    return fields;
  });
}

// Inserta en batch usando UNNEST arrays (más rápido que uno por uno)
async function insertBatch(tableName, columns, rows, client) {
  if (rows.length === 0) return 0;
  const BATCH_SIZE = 500;
  let total = 0;

  for (let i = 0; i < rows.length; i += BATCH_SIZE) {
    const batch = rows.slice(i, i + BATCH_SIZE);
    const placeholders = batch
      .map((_, idx) => {
        const start = idx * columns.length + 1;
        return `(${columns.map((_, j) => `$${start + j}`).join(',')})`;
      })
      .join(',');
    const values = batch.flat();
    const sql = `INSERT INTO ${tableName} (${columns.join(',')}) VALUES ${placeholders}`;
    const res = await client.query(sql, values);
    total += res.rowCount;
  }
  return total;
}

async function main() {
  console.log(`Leyendo archivo: ${SQL_FILE}`);
  if (!fs.existsSync(SQL_FILE)) {
    throw new Error(`No existe el archivo: ${SQL_FILE}`);
  }
  const content = fs.readFileSync(SQL_FILE, 'utf8');
  console.log(`Tamaño: ${(content.length / 1024).toFixed(1)} KB\n`);

  // Parsear cada bloque
  console.log('=== Parseando respaldo ===');
  const productos = parseCopyBlock(content, 'productos');
  console.log(`  productos: ${productos.length} filas`);
  const ventas = parseCopyBlock(content, 'ventas');
  console.log(`  ventas: ${ventas.length} filas`);
  const detalleVenta = parseCopyBlock(content, 'detalle_venta');
  console.log(`  detalle_venta: ${detalleVenta.length} filas`);
  const egresos = parseCopyBlock(content, 'egresos');
  console.log(`  egresos: ${egresos.length} filas`);

  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    // Verificar que las tablas estén vacías
    const countProd = await client.query('SELECT COUNT(*)::int c FROM productos');
    const countVen  = await client.query('SELECT COUNT(*)::int c FROM ventas');
    if (countProd.rows[0].c > 0 || countVen.rows[0].c > 0) {
      throw new Error('Las tablas NO están vacías. Aborta para evitar colisiones de ID. Ejecuta TRUNCATE primero.');
    }

    // ── PRODUCTOS ──
    // Esquema viejo: (id, nombre, precio, descripcion, codigo, stock, status)
    // Nuevo: + imagen_url (null), categoria ('General'), precio_costo (0), stock_minimo (15)
    console.log('\n=== Insertando productos ===');
    const prodRows = productos.map(r => [
      parseInt(r[0]),              // id
      r[1],                        // nombre
      parseFloat(r[2]),            // precio
      r[3],                        // descripcion
      r[4],                        // codigo
      parseInt(r[5]),              // stock
      r[6] === null ? true : (r[6] === 't' || r[6] === 'true'),  // status
      null,                        // imagen_url
      'General',                   // categoria
      0,                           // precio_costo
      15,                          // stock_minimo
    ]);
    // Deduplicar por codigo (por si hay duplicados en el dump)
    const codigosVistos = new Set();
    const prodDedup = prodRows.filter(r => {
      if (codigosVistos.has(r[4])) return false;
      codigosVistos.add(r[4]);
      return true;
    });
    console.log(`  Deduplicados: ${prodRows.length} → ${prodDedup.length}`);
    const insProd = await insertBatch(
      'productos',
      ['id', 'nombre', 'precio', 'descripcion', 'codigo', 'stock', 'status', 'imagen_url', 'categoria', 'precio_costo', 'stock_minimo'],
      prodDedup,
      client
    );
    console.log(`  Insertados: ${insProd}`);

    // ── VENTAS ──
    // Esquema viejo: (id, fecha, total)
    // Nuevo: + descuento (0), monto_recibido (total), metodo_pago ('efectivo')
    console.log('\n=== Insertando ventas ===');
    const ventasRows = ventas.map(r => [
      parseInt(r[0]),              // id
      r[1],                        // fecha
      parseFloat(r[2]),            // total
      0,                           // descuento
      parseFloat(r[2]),            // monto_recibido = total (asumimos pago exacto)
      'efectivo',                  // metodo_pago
    ]);
    const insVen = await insertBatch(
      'ventas',
      ['id', 'fecha', 'total', 'descuento', 'monto_recibido', 'metodo_pago'],
      ventasRows,
      client
    );
    console.log(`  Insertados: ${insVen}`);

    // ── DETALLE_VENTA ──
    // Esquema viejo y nuevo iguales: (id, venta_id, nombre, cantidad, precio)
    console.log('\n=== Insertando detalle_venta ===');
    const detalleRows = detalleVenta.map(r => [
      parseInt(r[0]),              // id
      parseInt(r[1]),              // venta_id
      r[2],                        // nombre
      parseInt(r[3]),              // cantidad
      parseFloat(r[4]),            // precio
    ]);
    // Filtrar huérfanos (venta_id que no existe en ventas)
    const ventaIdsSet = new Set(ventas.map(v => parseInt(v[0])));
    const detalleSinHuerfanos = detalleRows.filter(d => ventaIdsSet.has(d[1]));
    const huerfanos = detalleRows.length - detalleSinHuerfanos.length;
    if (huerfanos > 0) console.log(`  Huérfanos descartados: ${huerfanos}`);
    const insDet = await insertBatch(
      'detalle_venta',
      ['id', 'venta_id', 'nombre', 'cantidad', 'precio'],
      detalleSinHuerfanos,
      client
    );
    console.log(`  Insertados: ${insDet}`);

    // ── EGRESOS ──
    // Esquema viejo: (id, monto, fecha)
    // Nuevo: + concepto (null)
    console.log('\n=== Insertando egresos ===');
    const egresosRows = egresos.map(r => [
      parseInt(r[0]),              // id
      parseFloat(r[1]),            // monto
      r[2],                        // fecha
      null,                        // concepto
    ]);
    const insEgr = await insertBatch(
      'egresos',
      ['id', 'monto', 'fecha', 'concepto'],
      egresosRows,
      client
    );
    console.log(`  Insertados: ${insEgr}`);

    // ── Ajustar secuencias al max(id) ──
    console.log('\n=== Ajustando secuencias ===');
    await client.query("SELECT setval('productos_id_seq', COALESCE((SELECT MAX(id) FROM productos), 1))");
    await client.query("SELECT setval('ventas_id_seq', COALESCE((SELECT MAX(id) FROM ventas), 1))");
    await client.query("SELECT setval('detalle_venta_id_seq', COALESCE((SELECT MAX(id) FROM detalle_venta), 1))");
    await client.query("SELECT setval('egresos_id_seq', COALESCE((SELECT MAX(id) FROM egresos), 1))");
    console.log('  OK');

    await client.query('COMMIT');
    console.log('\n✅ IMPORTACIÓN EXITOSA');
  } catch (err) {
    await client.query('ROLLBACK');
    console.error('\n❌ ERROR:', err.message);
    throw err;
  } finally {
    client.release();
  }

  // Stats finales
  console.log('\n=== Verificación final ===');
  const tables = ['productos', 'ventas', 'detalle_venta', 'egresos'];
  for (const t of tables) {
    const r = await pool.query(`SELECT COUNT(*)::int c FROM ${t}`);
    console.log(`  ${t}: ${r.rows[0].c}`);
  }
}

main()
  .then(() => { pool.end(); process.exit(0); })
  .catch(err => { console.error(err); pool.end(); process.exit(1); });
