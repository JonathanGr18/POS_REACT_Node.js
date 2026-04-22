/**
 * Migración: convierte todas las imágenes existentes a WebP (full + thumb)
 * y actualiza imagen_url en la BD.
 *
 * Uso:
 *   node scripts/optimizar_imagenes.js              procesa solo imágenes no-webp
 *   node scripts/optimizar_imagenes.js --dry        muestra qué haría, sin modificar
 *   node scripts/optimizar_imagenes.js --reprocesar reprocesa también las .webp existentes
 */
const path = require('path');
const fs = require('fs');
const sharp = require('sharp');
const pool = require('../config/db');

const UPLOADS_DIR = path.join(__dirname, '..', 'uploads', 'productos');
const DRY = process.argv.includes('--dry');
const REPROCESAR = process.argv.includes('--reprocesar');

// Mismos valores que routes/productos.js
const FULL_SIZE = 600;
const FULL_QUALITY = 75;
const THUMB_SIZE = 150;
const THUMB_QUALITY = 65;

const procesar = async (origenPath) => {
  const base = path.basename(origenPath, path.extname(origenPath))
    // Quitar sufijo .thumb si por accidente venía con él
    .replace(/\.thumb$/, '');
  const fullName = `${base}.webp`;
  const thumbName = `${base}.thumb.webp`;
  const fullDest = path.join(UPLOADS_DIR, fullName);
  const thumbDest = path.join(UPLOADS_DIR, thumbName);

  // Lee el origen a buffer ANTES de empezar a escribir, para evitar corrupción
  // cuando origenPath y fullDest coinciden (caso reprocesamiento de .webp).
  const buf = fs.readFileSync(origenPath);

  await sharp(buf)
    .rotate()
    .resize(FULL_SIZE, FULL_SIZE, { fit: 'inside', withoutEnlargement: true })
    .webp({ quality: FULL_QUALITY })
    .toFile(fullDest);

  await sharp(buf)
    .rotate()
    .resize(THUMB_SIZE, THUMB_SIZE, { fit: 'cover' })
    .webp({ quality: THUMB_QUALITY })
    .toFile(thumbDest);

  return { fullUrl: `/uploads/productos/${fullName}`, fullDest, thumbDest };
};

const tamano = (p) => {
  try { return fs.statSync(p).size; } catch { return 0; }
};

const fmt = (bytes) => (bytes / 1024).toFixed(1) + ' KB';

(async () => {
  try {
    const filtroWebp = REPROCESAR ? '' : "AND imagen_url NOT LIKE '%.webp'";
    const { rows } = await pool.query(
      `SELECT id, nombre, imagen_url FROM productos
       WHERE imagen_url IS NOT NULL ${filtroWebp}`
    );

    console.log(`Encontrados ${rows.length} productos con imagen${REPROCESAR ? '' : ' sin optimizar'}.`);
    console.log(`Config: full ${FULL_SIZE}px q${FULL_QUALITY} | thumb ${THUMB_SIZE}px q${THUMB_QUALITY}`);
    if (DRY) console.log('[DRY RUN] No se modificará nada.\n');

    let totalAntes = 0, totalDespues = 0, ok = 0, fallos = 0;

    for (const prod of rows) {
      const origenPath = path.join(__dirname, '..', prod.imagen_url);
      if (!fs.existsSync(origenPath)) {
        console.log(`  [skip] ${prod.id} ${prod.nombre}: archivo no existe (${prod.imagen_url})`);
        fallos++;
        continue;
      }

      // Tamaño antes = full + thumb (si existe)
      const baseName = path.basename(origenPath, path.extname(origenPath));
      const thumbAntes = path.join(UPLOADS_DIR, `${baseName}.thumb.webp`);
      const tamOrig = tamano(origenPath) + (fs.existsSync(thumbAntes) ? tamano(thumbAntes) : 0);
      totalAntes += tamOrig;

      if (DRY) {
        console.log(`  [dry] ${prod.id} ${prod.nombre}: ${prod.imagen_url} (${fmt(tamOrig)})`);
        continue;
      }

      try {
        const { fullUrl, fullDest, thumbDest } = await procesar(origenPath);
        const tamNew = tamano(fullDest) + tamano(thumbDest);
        totalDespues += tamNew;

        // Solo actualizar BD si la URL cambió (caso no-webp → webp)
        if (fullUrl !== prod.imagen_url) {
          await pool.query('UPDATE productos SET imagen_url = $1 WHERE id = $2', [fullUrl, prod.id]);
          // Borrar original solo si era distinto archivo
          if (origenPath !== fullDest) fs.unlinkSync(origenPath);
        }

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
