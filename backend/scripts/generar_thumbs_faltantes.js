/**
 * Genera el .thumb.webp para imágenes .webp que ya existen como full
 * pero no tienen su versión thumbnail (caso típico tras subir imágenes
 * antes de que existiera la lógica de thumbs).
 *
 * Uso: node scripts/generar_thumbs_faltantes.js
 */
const path = require('path');
const fs = require('fs');
const sharp = require('sharp');
const pool = require('../config/db');

const UPLOADS_DIR = path.join(__dirname, '..', 'uploads', 'productos');

(async () => {
  try {
    const { rows } = await pool.query(
      `SELECT id, nombre, imagen_url FROM productos
       WHERE imagen_url LIKE '%.webp'
         AND imagen_url NOT LIKE '%.thumb.webp'`
    );
    console.log(`Encontrados ${rows.length} productos con .webp full.`);

    let ok = 0, skip = 0, fail = 0;
    for (const prod of rows) {
      const fullPath = path.join(__dirname, '..', prod.imagen_url);
      const base = path.basename(prod.imagen_url, '.webp');
      const thumbPath = path.join(UPLOADS_DIR, `${base}.thumb.webp`);

      if (!fs.existsSync(fullPath)) {
        console.log(`  [skip] ${prod.id} ${prod.nombre}: full no existe`);
        skip++;
        continue;
      }
      if (fs.existsSync(thumbPath)) {
        console.log(`  [ok-existe] ${prod.id} ${prod.nombre}: thumb ya existe`);
        ok++;
        continue;
      }
      try {
        await sharp(fullPath)
          .rotate()
          .resize(200, 200, { fit: 'cover' })
          .webp({ quality: 75 })
          .toFile(thumbPath);
        console.log(`  [ok] ${prod.id} ${prod.nombre}: thumb generado`);
        ok++;
      } catch (err) {
        console.error(`  [err] ${prod.id} ${prod.nombre}: ${err.message}`);
        fail++;
      }
    }
    console.log(`\nResumen: OK ${ok}, skip ${skip}, fail ${fail}`);
    await pool.end();
    process.exit(0);
  } catch (err) {
    console.error('Error fatal:', err);
    await pool.end();
    process.exit(1);
  }
})();
