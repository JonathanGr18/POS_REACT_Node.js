const { Pool } = require('pg');
require('dotenv').config({ path: __dirname + '/.env' });

const pool = new Pool({
  user: process.env.DB_USER,
  host: process.env.HOST,
  database: process.env.DATABASE,
  password: process.env.DB_PASSWORD,
  port: parseInt(process.env.PORT),
});

const productos = [
  { codigo: 'P001', nombre: 'Cuaderno Profesional 100 Hojas', descripcion: 'Cuaderno cuadrícula pasta dura', precio: 35.00, stock: 50, stock_minimo: 10 },
  { codigo: 'P002', nombre: 'Lápiz #2 HB', descripcion: 'Lápiz de madera hexagonal', precio: 5.00, stock: 120, stock_minimo: 20 },
  { codigo: 'P003', nombre: 'Bolígrafo Azul', descripcion: 'Bolígrafo tinta azul punta fina', precio: 8.00, stock: 80, stock_minimo: 15 },
  { codigo: 'P004', nombre: 'Bolígrafo Negro', descripcion: 'Bolígrafo tinta negra punta fina', precio: 8.00, stock: 60, stock_minimo: 15 },
  { codigo: 'P005', nombre: 'Goma de Borrar', descripcion: 'Goma blanca suave', precio: 4.00, stock: 3, stock_minimo: 20 },
  { codigo: 'P006', nombre: 'Tijeras Escolares', descripcion: 'Tijeras punta redonda 13cm', precio: 25.00, stock: 30, stock_minimo: 5 },
  { codigo: 'P007', nombre: 'Regla 30cm', descripcion: 'Regla de plástico transparente', precio: 12.00, stock: 45, stock_minimo: 10 },
  { codigo: 'P008', nombre: 'Compás Escolar', descripcion: 'Compás metálico con lápiz', precio: 45.00, stock: 4, stock_minimo: 5 },
  { codigo: 'P009', nombre: 'Pegamento en Barra', descripcion: 'Pegamento UHU 21g', precio: 18.00, stock: 55, stock_minimo: 10 },
  { codigo: 'P010', nombre: 'Carpeta de Argollas', descripcion: 'Carpeta 3 argollas tamaño carta', precio: 65.00, stock: 25, stock_minimo: 5 },
  { codigo: 'P011', nombre: 'Papel Construcción', descripcion: 'Block 20 hojas colores variados', precio: 22.00, stock: 40, stock_minimo: 8 },
  { codigo: 'P012', nombre: 'Marcadores de Colores', descripcion: 'Set 12 marcadores lavables', precio: 55.00, stock: 2, stock_minimo: 5 },
  { codigo: 'P013', nombre: 'Mochila Escolar', descripcion: 'Mochila resistente con porta laptop', precio: 350.00, stock: 8, stock_minimo: 3 },
  { codigo: 'P014', nombre: 'Sacapuntas Doble', descripcion: 'Sacapuntas metal doble orificio', precio: 10.00, stock: 70, stock_minimo: 15 },
  { codigo: 'P015', nombre: 'Post-it 3x3', descripcion: 'Bloc adhesivo 100 hojas amarillo', precio: 28.00, stock: 35, stock_minimo: 8 },
  { codigo: 'P016', nombre: 'Folder Manila', descripcion: 'Folder tamaño carta (paquete 100)', precio: 45.00, stock: 20, stock_minimo: 5 },
  { codigo: 'P017', nombre: 'Plumones Permanentes', descripcion: 'Set 4 plumones negros punta gruesa', precio: 35.00, stock: 0, stock_minimo: 10 },
  { codigo: 'P018', nombre: 'Corrector Líquido', descripcion: 'Corrector de secado rápido 20ml', precio: 15.00, stock: 3, stock_minimo: 10 },
  { codigo: 'P019', nombre: 'Calculadora Básica', descripcion: 'Calculadora solar 12 dígitos', precio: 120.00, stock: 12, stock_minimo: 5 },
  { codigo: 'P020', nombre: 'Engrapadora', descripcion: 'Engrapadora metálica 20 hojas', precio: 85.00, stock: 10, stock_minimo: 3 },
];

const nombresProductos = productos.map(p => p.nombre);

function rand(min, max) {
  return Math.floor(Math.random() * (max - min + 1)) + min;
}

function randFloat(min, max) {
  return parseFloat((Math.random() * (max - min) + min).toFixed(2));
}

function fechaHace(diasAtras, horaMin = 8, horaMax = 20) {
  const d = new Date();
  d.setDate(d.getDate() - diasAtras);
  d.setHours(rand(horaMin, horaMax), rand(0, 59), rand(0, 59), 0);
  return d;
}

async function seed() {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    // Limpiar datos existentes
    await client.query('DELETE FROM lista_compras');
    await client.query('DELETE FROM tienda_productos');
    await client.query('DELETE FROM tiendas');
    await client.query('DELETE FROM egresos');
    await client.query('DELETE FROM detalle_venta');
    await client.query('DELETE FROM ventas');
    await client.query('DELETE FROM productos');
    console.log('Tablas limpiadas');

    // Insertar productos
    const prodIds = {};
    for (const p of productos) {
      const r = await client.query(
        `INSERT INTO productos (codigo, nombre, descripcion, precio, stock, stock_minimo, status)
         VALUES ($1,$2,$3,$4,$5,$6,true) RETURNING id`,
        [p.codigo, p.nombre, p.descripcion, p.precio, p.stock, p.stock_minimo]
      );
      prodIds[p.nombre] = r.rows[0].id;
    }
    console.log('Productos insertados:', productos.length);

    // Ventas: últimos 90 días (2-6 ventas por día)
    const metodos = ['efectivo', 'efectivo', 'efectivo', 'tarjeta', 'transferencia'];
    let totalVentas = 0;

    for (let diasAtras = 90; diasAtras >= 0; diasAtras--) {
      // Domingos menos ventas
      const fecha = fechaHace(diasAtras);
      const esDomingo = fecha.getDay() === 0;
      const numVentas = esDomingo ? rand(0, 2) : rand(2, 6);

      for (let v = 0; v < numVentas; v++) {
        const fechaVenta = fechaHace(diasAtras, 9, 20);
        const metodo = metodos[rand(0, metodos.length - 1)];

        // 1-4 productos por venta
        const numItems = rand(1, 4);
        const itemsVenta = [];
        const usados = new Set();

        for (let i = 0; i < numItems; i++) {
          let idx;
          do { idx = rand(0, nombresProductos.length - 1); } while (usados.has(idx));
          usados.add(idx);
          const prod = productos[idx];
          const cantidad = rand(1, 5);
          itemsVenta.push({ nombre: prod.nombre, cantidad, precio: prod.precio, id: prodIds[prod.nombre] });
        }

        const subtotal = itemsVenta.reduce((s, i) => s + i.cantidad * i.precio, 0);
        const descuento = Math.random() < 0.1 ? parseFloat((subtotal * 0.05).toFixed(2)) : 0;
        const total = parseFloat((subtotal - descuento).toFixed(2));
        const montoRecibido = metodo === 'efectivo'
          ? parseFloat((Math.ceil(total / 10) * 10 + rand(0, 2) * 10).toFixed(2))
          : total;

        const ventaRes = await client.query(
          `INSERT INTO ventas (fecha, total, descuento, monto_recibido, metodo_pago)
           VALUES ($1,$2,$3,$4,$5) RETURNING id`,
          [fechaVenta, total, descuento, montoRecibido, metodo]
        );
        const ventaId = ventaRes.rows[0].id;

        for (const item of itemsVenta) {
          await client.query(
            `INSERT INTO detalle_venta (venta_id, nombre, cantidad, precio) VALUES ($1,$2,$3,$4)`,
            [ventaId, item.nombre, item.cantidad, item.precio]
          );
        }
        totalVentas++;
      }
    }
    console.log('Ventas insertadas:', totalVentas);

    // Egresos: últimos 90 días (1-3 por semana)
    const conceptosEgresos = [
      'Compra de material de papelería', 'Pago de renta local', 'Servicios de luz y agua',
      'Compra de bolsas y empaques', 'Mantenimiento de equipo', 'Reposición de caja chica',
      'Gastos de limpieza', 'Pago a proveedor', 'Publicidad y volantes', 'Papelería administrativa',
    ];
    let totalEgresos = 0;
    for (let diasAtras = 90; diasAtras >= 0; diasAtras--) {
      if (rand(1, 7) <= 2) { // aprox 2 egresos por semana
        const monto = randFloat(50, 800);
        const concepto = conceptosEgresos[rand(0, conceptosEgresos.length - 1)];
        const fecha = fechaHace(diasAtras, 9, 17);
        await client.query(
          `INSERT INTO egresos (monto, concepto, fecha) VALUES ($1,$2,$3)`,
          [monto, concepto, fecha]
        );
        totalEgresos++;
      }
    }
    console.log('Egresos insertados:', totalEgresos);

    // Tiendas
    const t1 = await client.query(
      `INSERT INTO tiendas (nombre, direccion, telefono, notas)
       VALUES ('Papelería Central','Calle Morelos #45, Centro','555-1234','Mayorista, buen precio en cuadernos') RETURNING id`
    );
    const t2 = await client.query(
      `INSERT INTO tiendas (nombre, direccion, telefono, notas)
       VALUES ('Distribuidora El Estudiante','Av. Universidad #120','555-5678','Especialidad en útiles escolares') RETURNING id`
    );
    const t3 = await client.query(
      `INSERT INTO tiendas (nombre, direccion, telefono, notas)
       VALUES ('OFFICEMAX Norte','Plaza Comercial Norte Local 5','555-9012','Artículos de oficina premium') RETURNING id`
    );
    const tid1 = t1.rows[0].id, tid2 = t2.rows[0].id, tid3 = t3.rows[0].id;
    console.log('Tiendas insertadas: 3');

    // Productos por tienda
    await client.query(`INSERT INTO tienda_productos (tienda_id, nombre, precio, notas) VALUES
      ($1,'Cuaderno 100 Hojas',28.00,'Mayoreo 10+ piezas'),
      ($1,'Lápiz #2 HB (caja 12)',45.00,'Por caja'),
      ($1,'Bolígrafo Azul (caja 12)',75.00,'Varios colores'),
      ($1,'Papel Bond 75g Resma',95.00,'Resma 500 hojas'),
      ($2,'Cuaderno Profesional',32.00,'Buena calidad'),
      ($2,'Tijeras Escolares',20.00,'Punta redonda'),
      ($2,'Compás Escolar',38.00,'Con estuche'),
      ($2,'Regla 30cm',10.00,'Plástico grueso'),
      ($2,'Marcadores x12',48.00,'Varios colores'),
      ($3,'Post-it 3x3 x100',25.00,'Amarillo'),
      ($3,'Engrapadora Profesional',180.00,'Capacidad 50 hojas'),
      ($3,'Calculadora Científica',320.00,'Casio FX-570'),
      ($3,'Folder Manila x100',40.00,'Tamaño carta')
    `, [tid1, tid2, tid3]);
    console.log('Productos de tiendas insertados: 13');

    // Lista de compras
    await client.query(`INSERT INTO lista_compras (tienda_id, nombre_producto, cantidad, precio_ref, notas, completado) VALUES
      ($1,'Cuaderno 100 Hojas',20,28.00,'Para resurtir stock',false),
      ($1,'Lápiz #2 HB (caja 12)',5,45.00,null,false),
      ($2,'Marcadores x12',10,48.00,'Urgente, stock agotado',false),
      ($2,'Tijeras Escolares',15,20.00,null,true),
      ($3,'Post-it 3x3 x100',8,25.00,'Clientas lo piden mucho',false),
      (null,'Plumones Permanentes',12,null,'Buscar precio',false),
      ($1,'Bolígrafo Azul (caja 12)',6,75.00,'Pedir junto con los cuadernos',false),
      ($3,'Engrapadora Profesional',2,180.00,'Una para mostrador',true),
      ($2,'Goma de Borrar',30,3.50,'Stock muy bajo',false)
    `, [tid1, tid2, tid3]);
    console.log('Lista de compras insertada: 9 items');

    await client.query('COMMIT');
    console.log('\n✅ Seed demo completado exitosamente');
    console.log('   Productos: 20 | Ventas: ~' + totalVentas + ' | Egresos: ~' + totalEgresos);
    console.log('   Tiendas: 3 | Productos tienda: 13 | Lista compras: 9');

  } catch (err) {
    await client.query('ROLLBACK');
    console.error('❌ Error:', err.message);
  } finally {
    client.release();
    await pool.end();
  }
}

seed();
