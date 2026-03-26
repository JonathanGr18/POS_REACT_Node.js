/**
 * seed_reportes.js
 * Inserta 11 meses de ventas históricas (Abr 2025 – Feb 2026)
 * para visualizar reportes, heatmap y gráfica comparativa.
 */

const { Pool } = require('pg');
require('dotenv').config();

const pool = new Pool({
  user:     process.env.DB_USER,
  host:     process.env.HOST,
  database: process.env.DATABASE,
  password: process.env.DB_PASSWORD,
  port:     process.env.PORT,
});

// Productos con su precio
const PRODUCTOS = [
  { nombre: 'Cuaderno Profesional',  precio: 35  },
  { nombre: 'Lapiz #2 HB',          precio: 5   },
  { nombre: 'Boligrafo Azul',        precio: 8   },
  { nombre: 'Boligrafo Negro',       precio: 8   },
  { nombre: 'Goma de Borrar',        precio: 4   },
  { nombre: 'Tijeras Escolares',     precio: 25  },
  { nombre: 'Regla 30cm',            precio: 12  },
  { nombre: 'Compas Escolar',        precio: 45  },
  { nombre: 'Pegamento en Barra',    precio: 18  },
  { nombre: 'Carpeta de Argollas',   precio: 65  },
  { nombre: 'Papel Construccion',    precio: 22  },
  { nombre: 'Marcadores de Colores', precio: 55  },
  { nombre: 'Mochila Escolar',       precio: 350 },
  { nombre: 'Sacapuntas Doble',      precio: 10  },
  { nombre: 'Post-it 3x3',           precio: 28  },
  { nombre: 'Folder Manila',         precio: 45  },
  { nombre: 'Plumones Permanentes',  precio: 35  },
  { nombre: 'Corrector Liquido',     precio: 15  },
  { nombre: 'Calculadora Basica',    precio: 120 },
  { nombre: 'Engrapadora Metalica',  precio: 85  },
];

// Multiplicador de ventas por mes (estacionalidad)
// Índice 0 = Enero, 11 = Diciembre
const FACTOR_MES = [0.7, 0.65, 1.0, 0.75, 0.8, 0.85, 0.9, 1.4, 1.5, 0.95, 0.85, 0.6];

// Días del mes con ventas (algunos días cerrado = domingo generalmente)
function diasAbiertos(year, mes) {
  const diasEnMes = new Date(year, mes + 1, 0).getDate();
  const dias = [];
  for (let d = 1; d <= diasEnMes; d++) {
    const dow = new Date(year, mes, d).getDay();
    if (dow === 0) continue; // cerrado domingos
    // algunos sábados cerrado (~30%)
    if (dow === 6 && Math.random() < 0.3) continue;
    // algunos días entre semana cerrado (~8%)
    if (Math.random() < 0.08) continue;
    dias.push(d);
  }
  return dias;
}

function randInt(min, max) {
  return min + Math.floor(Math.random() * (max - min + 1));
}

function pick(arr) {
  return arr[Math.floor(Math.random() * arr.length)];
}

async function run() {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    let totalVentas = 0;

    // Abr 2025 (mes 3) → Feb 2026 (mes 1 del año siguiente)
    const meses = [
      { year: 2025, mes: 3  }, // Abril
      { year: 2025, mes: 4  }, // Mayo
      { year: 2025, mes: 5  }, // Junio
      { year: 2025, mes: 6  }, // Julio
      { year: 2025, mes: 7  }, // Agosto
      { year: 2025, mes: 8  }, // Septiembre
      { year: 2025, mes: 9  }, // Octubre
      { year: 2025, mes: 10 }, // Noviembre
      { year: 2025, mes: 11 }, // Diciembre
      { year: 2026, mes: 0  }, // Enero
      { year: 2026, mes: 1  }, // Febrero
    ];

    for (const { year, mes } of meses) {
      const factor = FACTOR_MES[mes];
      const dias = diasAbiertos(year, mes);

      for (const dia of dias) {
        const numVentas = Math.round((randInt(3, 8)) * factor);
        const hora = randInt(9, 20);

        for (let v = 0; v < Math.max(numVentas, 1); v++) {
          const fechaDt = new Date(year, mes, dia, hora - randInt(0, 4), randInt(0, 59));

          // Generar 1-4 items por venta
          const numItems = randInt(1, 4);
          const items = [];
          let total = 0;

          for (let k = 0; k < numItems; k++) {
            // En agosto/septiembre meter más útiles escolares caros
            let prod;
            if (mes === 7 || mes === 8) {
              prod = Math.random() < 0.5
                ? pick(PRODUCTOS.slice(0, 13))  // más probable útiles básicos
                : pick(PRODUCTOS);
            } else {
              prod = pick(PRODUCTOS);
            }
            const cant = randInt(1, 5);
            items.push({ nombre: prod.nombre, precio: prod.precio, cant });
            total += prod.precio * cant;
          }

          const vRes = await client.query(
            `INSERT INTO ventas (fecha, total) VALUES ($1, $2) RETURNING id`,
            [fechaDt.toISOString(), total.toFixed(2)]
          );
          const vid = vRes.rows[0].id;

          for (const it of items) {
            await client.query(
              `INSERT INTO detalle_venta (venta_id, nombre, cantidad, precio) VALUES ($1, $2, $3, $4)`,
              [vid, it.nombre, it.cant, it.precio]
            );
          }
          totalVentas++;
        }
      }

      // Egresos del mes (resurtido de inventario)
      const numEgresos = randInt(2, 5);
      for (let e = 0; e < numEgresos; e++) {
        const diaEgreso = pick(dias);
        const montoEgreso = (randInt(80, 600) * factor).toFixed(2);
        const fechaEgreso = new Date(year, mes, diaEgreso, 10, 0);
        await client.query(
          `INSERT INTO egresos (monto, fecha) VALUES ($1, $2)`,
          [montoEgreso, fechaEgreso.toISOString()]
        );
      }

      const nombreMes = new Date(year, mes, 1).toLocaleDateString('es-MX', { month: 'long', year: 'numeric' });
      console.log(`✅ ${nombreMes}: ${dias.length} días, ~${totalVentas} ventas acumuladas`);
    }

    await client.query('COMMIT');
    console.log(`\n🎉 Seed completado: ${totalVentas} ventas insertadas en 11 meses`);
  } catch (err) {
    await client.query('ROLLBACK');
    console.error('❌ Error:', err.message);
  } finally {
    client.release();
    await pool.end();
  }
}

run();
