/**
 * Migración: convierte todas las imágenes existentes a WebP (full + thumb)
 * y actualiza imagen_url en la BD.
 *
 * Uso: node scripts/optimizar_imagenes.js [--dry]
 *   --dry  solo muestra qué haría, sin modificar
 */
const path = require('path');
const fs = require('fs');
const sharp = require('sharp');
const pool = require('../config/db');

const UPLOADS_DIR = path.join(__dirname, '..', 'uploads', 'productos');
const DRY = process.argv.includes('--dry');

const procesar = async (origenPath) => {
  const base = path.basename(origenPath, path.extname(origenPath));
  const fullName = `${base}.webp`;
  const thumbName = `${base}.thumb.webp`;
  const fullDest = path.join(UPLOADS_DIR, fullName);
  const thumbDest = path.join(UPLOADS_DIR, thumbName);

  await sharp(origenPath)
    .rotate()
    .resize(800, 800, { fit: 'inside', withoutEnlargement: true })
    .webp({ quality: 82 })
    .toFile(fullDest);

  await sharp(origenPath)
    .rotate()
    .resize(200, 200, { fit: 'cover' })
    .webp({ quality: 75 })
    .toFile(thumbDest);

  return { fullUrl: `/uploads/productos/${fullName}`, fullDest, thumbDest };
};

const tamano = (p) => {
  try { return fs.statSync(p).size; } catch { return 0; }
};

const fmt = (bytes) => (bytes / 1024).toFixed(1) + ' KB';

(async () => {
  try {
    const { rows } = await pool.query(
      `SELECT id, nombre, imagen_url FROM productos
       WHERE imagen_url IS NOT NULL
       AND imagen_url NOT LIKE '%.webp'`
    );

    console.log(`Encontrados ${rows.length} productos con imagen sin optimizar.`);
    if (DRY) console.log('[DRY RUN] No se modificará nada.\n');

    let totalAntes = 0, totalDespues = 0, ok = 0, fallos = 0;

    for (const prod of rows) {
      const origenPath = path.join(__dirname, '..', prod.imagen_url);
      if (!fs.existsSync(origenPath)) {
        console.log(`  [skip] ${prod.id} ${prod.nombre}: archivo no existe (${prod.imagen_url})`);
        fallos++;
        continue;
      }

      const tamOrig = tamano(origenPath);
      totalAntes += tamOrig;

      if (DRY) {
        console.log(`  [dry] ${prod.id} ${prod.nombre}: ${prod.imagen_url} (${fmt(tamOrig)})`);
        continue;
      }

      try {
        const { fullUrl, fullDest, thumbDest } = await procesar(origenPath);
        const tamNew = tamano(fullDest) + tamano(thumbDest);
        totalDespues += tamNew;

        await pool.query('UPDATE productos SET imagen_url = $1 WHERE id = $2', [fullUrl, prod.id]);
        // Borrar original
        fs.unlinkSync(origenPath);

        console.log(`  [ok] ${prod.id} ${prod.nombre}: ${fmt(tamOrig)} → ${fmt(tamNew)} (ahorro ${fmt(tamOrig - tamNew)})`);
        ok++;
      } catch (err) {
        console.error(`  [err] ${prod.id} ${prod.nombre}: ${err.message}`);
        fallos++;
      }
    }

    console.log('\n─── Resumen ───');
    console.log(`Procesados: ${ok}  Fallos: ${fallos}`);
    if (!DRY && ok > 0) {
      console.log(`Tamaño total antes:   ${fmt(totalAntes)}`);
      console.log(`Tamaño total después: ${fmt(totalDespues)}`);
      console.log(`Ahorro:               ${fmt(totalAntes - totalDespues)} (${((1 - totalDespues / totalAntes) * 100).toFixed(1)}%)`);
    }

    await pool.end();
    process.exit(0);
  } catch (err) {
    console.error('Error fatal:', err);
    await pool.end();
    process.exit(1);
  }
})();
