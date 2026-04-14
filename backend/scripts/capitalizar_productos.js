/**
 * Script one-off para capitalizar nombres de productos existentes.
 * También capitaliza nombres en detalle_venta (que JOINea por nombre).
 */

const pool = require('../config/db');

const ARTICULOS_MINUS = new Set(['de', 'del', 'la', 'el', 'los', 'las', 'y', 'o', 'a', 'en', 'con', 'para', 'por']);
const capitalizarNombre = (texto) => {
  if (typeof texto !== 'string') return texto;
  return texto
    .trim()
    .split(/\s+/)
    .map((palabra, idx) => {
      if (!palabra) return palabra;
      const lower = palabra.toLowerCase();
      if (idx > 0 && ARTICULOS_MINUS.has(lower)) return lower;
      return lower.replace(/(^|[\/\-(])([a-záéíóúñü])/g, (m, sep, ch) => sep + ch.toUpperCase());
    })
    .join(' ');
};

async function main() {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    // 1. Leer productos actuales
    const { rows: productos } = await client.query('SELECT id, nombre FROM productos ORDER BY id');
    console.log(`Productos a procesar: ${productos.length}`);

    let cambiados = 0;
    const mapaNombres = new Map(); // nombre_viejo -> nombre_nuevo
    for (const p of productos) {
      const nuevo = capitalizarNombre(p.nombre);
      if (nuevo !== p.nombre) {
        await client.query('UPDATE productos SET nombre = $1 WHERE id = $2', [nuevo, p.id]);
        mapaNombres.set(p.nombre, nuevo);
        cambiados++;
      }
    }
    console.log(`Productos actualizados: ${cambiados}`);

    // 2. Actualizar detalle_venta para mantener el JOIN por nombre consistente
    // Nota: detalle_venta.nombre guarda el snapshot del momento, pero mantenerlo
    // alineado facilita los reportes/top-productos que hacen JOIN por nombre.
    let detalleCambiados = 0;
    for (const [viejo, nuevo] of mapaNombres.entries()) {
      const r = await client.query(
        'UPDATE detalle_venta SET nombre = $1 WHERE nombre = $2',
        [nuevo, viejo]
      );
      detalleCambiados += r.rowCount;
    }
    console.log(`Filas de detalle_venta actualizadas: ${detalleCambiados}`);

    // 3. Capitalizar categorías también
    const { rows: cats } = await client.query("SELECT DISTINCT categoria FROM productos WHERE categoria IS NOT NULL");
    let catsCambiadas = 0;
    for (const c of cats) {
      const nuevaCat = capitalizarNombre(c.categoria);
      if (nuevaCat !== c.categoria) {
        await client.query('UPDATE productos SET categoria = $1 WHERE categoria = $2', [nuevaCat, c.categoria]);
        catsCambiadas++;
      }
    }
    console.log(`Categorías actualizadas: ${catsCambiadas}`);

    await client.query('COMMIT');
    console.log('\n✅ Capitalización completada');

    // Muestra ejemplos
    const { rows: samples } = await pool.query('SELECT id, nombre, categoria FROM productos ORDER BY id LIMIT 10');
    console.log('\nPrimeros 10 productos:');
    samples.forEach(r => console.log(`  ${r.id}. ${r.nombre}  [${r.categoria}]`));

  } catch (err) {
    await client.query('ROLLBACK');
    console.error('❌ ERROR:', err.message);
    throw err;
  } finally {
    client.release();
  }
}

main()
  .then(() => { pool.end(); process.exit(0); })
  .catch(err => { console.error(err); pool.end(); process.exit(1); });
