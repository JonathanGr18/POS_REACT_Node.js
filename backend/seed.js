const { Pool } = require('pg');
require('dotenv').config({ path: 'C:/Users/jona1/Desktop/Pos_Pape/Pos_Pape/backend/.env' });

const pool = new Pool({
  user: process.env.DB_USER,
  host: process.env.HOST,
  database: process.env.DATABASE,
  password: process.env.DB_PASSWORD,
  port: process.env.PORT,
});

async function seed() {
  const client = await pool.connect();
  try {
    // Productos
    await client.query(`
      INSERT INTO productos (codigo, nombre, descripcion, precio, stock, stock_minimo) VALUES
        ('001', 'Cuaderno Profesional 100 Hojas', 'Cuaderno cuadrícula pasta dura', 35.00, 50, 10),
        ('002', 'Lápiz #2 HB', 'Lápiz de madera hexagonal', 5.00, 120, 20),
        ('003', 'Bolígrafo Azul', 'Bolígrafo tinta azul punta fina', 8.00, 80, 15),
        ('004', 'Bolígrafo Negro', 'Bolígrafo tinta negra punta fina', 8.00, 60, 15),
        ('005', 'Goma de Borrar', 'Goma blanca suave', 4.00, 90, 20),
        ('006', 'Tijeras Escolares', 'Tijeras punta redonda 13cm', 25.00, 30, 5),
        ('007', 'Regla 30cm', 'Regla de plástico transparente', 12.00, 45, 10),
        ('008', 'Compás Escolar', 'Compás metálico con lápiz', 45.00, 20, 5),
        ('009', 'Pegamento en Barra', 'Pegamento UHU 21g', 18.00, 55, 10),
        ('010', 'Carpeta de Argollas', 'Carpeta 3 argollas tamaño carta', 65.00, 25, 5),
        ('011', 'Papel Construcción', 'Block 20 hojas colores variados', 22.00, 40, 8),
        ('012', 'Marcadores de Colores', 'Set 12 marcadores lavables', 55.00, 15, 5),
        ('013', 'Mochila Escolar', 'Mochila resistente con porta laptop', 350.00, 8, 3),
        ('014', 'Sacapuntas Doble', 'Sacapuntas metal doble orificio', 10.00, 70, 15),
        ('015', 'Post-it 3x3', 'Bloc adhesivo 100 hojas amarillo', 28.00, 35, 8),
        ('016', 'Folder Manila', 'Folder tamaño carta (paquete 100)', 45.00, 20, 5),
        ('017', 'Plumones Permanentes', 'Set 4 plumones negros punta gruesa', 35.00, 0, 10),
        ('018', 'Corrector Líquido', 'Corrector de secado rápido 20ml', 15.00, 3, 10),
        ('019', 'Calculadora Básica', 'Calculadora solar 12 dígitos', 120.00, 12, 5),
        ('020', 'Engrapadora', 'Engrapadora metálica capacidad 20 hojas', 85.00, 10, 3)
      ON CONFLICT (codigo) DO NOTHING
    `);
    console.log('✅ Productos insertados');

    // Ventas pasadas (últimos 7 días)
    const hoy = new Date();
    for (let i = 6; i >= 0; i--) {
      const fecha = new Date(hoy);
      fecha.setDate(hoy.getDate() - i);
      const fechaStr = fecha.toISOString();

      // 2-4 ventas por día
      const numVentas = 2 + Math.floor(Math.random() * 3);
      for (let v = 0; v < numVentas; v++) {
        const ventaRes = await client.query(
          `INSERT INTO ventas (total, fecha) VALUES ($1, $2) RETURNING id`,
          [(Math.random() * 200 + 50).toFixed(2), fechaStr]
        );
        const ventaId = ventaRes.rows[0].id;

        // 1-3 productos por venta
        const items = [
          { prod_id: null, nombre: 'Cuaderno Profesional 100 Hojas', cantidad: 2, precio: 35.00 },
          { prod_id: null, nombre: 'Bolígrafo Azul', cantidad: 5, precio: 8.00 },
          { prod_id: null, nombre: 'Lápiz #2 HB', cantidad: 3, precio: 5.00 },
          { prod_id: null, nombre: 'Goma de Borrar', cantidad: 4, precio: 4.00 },
        ];
        const item = items[Math.floor(Math.random() * items.length)];
        await client.query(
          `INSERT INTO detalle_venta (venta_id, nombre_producto, cantidad, precio_unitario) VALUES ($1, $2, $3, $4)`,
          [ventaId, item.nombre, item.cantidad, item.precio]
        );
      }
    }
    console.log('✅ Ventas insertadas');

    // Egresos (faltantes)
    await client.query(`
      INSERT INTO egresos (producto_id, nombre_producto, motivo, cantidad, fecha)
      SELECT id, nombre, 'Dañado', 1, NOW() - INTERVAL '2 days'
      FROM productos WHERE codigo = '006'
      UNION ALL
      SELECT id, nombre, 'Merma', 2, NOW() - INTERVAL '1 day'
      FROM productos WHERE codigo = '012'
      UNION ALL
      SELECT id, nombre, 'Dañado', 1, NOW()
      FROM productos WHERE codigo = '018'
    `);
    console.log('✅ Egresos insertados');

    // Tiendas
    const t1 = await client.query(`
      INSERT INTO tiendas (nombre, direccion, telefono, notas)
      VALUES ('Papelería Central', 'Calle Morelos #45, Centro', '555-1234', 'Mayorista, buen precio en cuadernos')
      RETURNING id
    `);
    const t2 = await client.query(`
      INSERT INTO tiendas (nombre, direccion, telefono, notas)
      VALUES ('Distribuidora El Estudiante', 'Av. Universidad #120', '555-5678', 'Especialidad en útiles escolares')
      RETURNING id
    `);
    const t3 = await client.query(`
      INSERT INTO tiendas (nombre, direccion, telefono, notas)
      VALUES ('OFFICEMAX Sucursal Norte', 'Plaza Comercial Norte Local 5', '555-9012', 'Artículos de oficina y papelería premium')
      RETURNING id
    `);
    console.log('✅ Tiendas insertadas');

    const tid1 = t1.rows[0].id;
    const tid2 = t2.rows[0].id;
    const tid3 = t3.rows[0].id;

    // Productos por tienda
    await client.query(`
      INSERT INTO tienda_productos (tienda_id, nombre, precio, notas) VALUES
        ($1, 'Cuaderno 100 Hojas', 28.00, 'Mayoreo 10+ piezas'),
        ($1, 'Lápiz #2 HB (caja 12)', 45.00, 'Por caja'),
        ($1, 'Bolígrafo Azul (caja 12)', 75.00, 'Varios colores'),
        ($1, 'Papel Bond 75g Resma', 95.00, 'Resma 500 hojas'),
        ($2, 'Cuaderno Profesional', 32.00, 'Buena calidad'),
        ($2, 'Tijeras Escolares', 20.00, 'Punta redonda'),
        ($2, 'Compás Escolar', 38.00, 'Con estuche'),
        ($2, 'Regla 30cm', 10.00, 'Plástico grueso'),
        ($2, 'Marcadores x12', 48.00, 'Varios colores'),
        ($3, 'Post-it 3x3 x100', 25.00, 'Amarillo'),
        ($3, 'Engrapadora Profesional', 180.00, 'Capacidad 50 hojas'),
        ($3, 'Calculadora Científica', 320.00, 'Casio FX-570'),
        ($3, 'Folder Manila x100', 40.00, 'Tamaño carta')
    `, [tid1, tid2, tid3]);
    console.log('✅ Productos de tiendas insertados');

    // Lista de compras
    await client.query(`
      INSERT INTO lista_compras (tienda_id, nombre_producto, cantidad, precio_ref, notas, completado) VALUES
        ($1, 'Cuaderno 100 Hojas', 20, 28.00, 'Para resurtir stock', false),
        ($1, 'Lápiz #2 HB (caja 12)', 5, 45.00, null, false),
        ($2, 'Marcadores x12', 10, 48.00, 'Urgente, stock agotado', false),
        ($2, 'Tijeras Escolares', 15, 20.00, null, true),
        ($3, 'Post-it 3x3 x100', 8, 25.00, 'Clientas lo piden mucho', false),
        (null, 'Plumones Permanentes', 12, null, 'Buscar precio', false)
    `, [tid1, tid2, tid3]);
    console.log('✅ Lista de compras insertada');

    console.log('\n🎉 Seed completado exitosamente');
  } catch (err) {
    console.error('❌ Error en seed:', err.message);
  } finally {
    client.release();
    await pool.end();
  }
}

seed();
