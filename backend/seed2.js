
const { Pool } = require("pg");
require("dotenv").config();
const pool = new Pool({
  user: process.env.DB_USER, host: process.env.HOST,
  database: process.env.DATABASE, password: process.env.DB_PASSWORD, port: process.env.PORT,
});
async function run() {
  const c = await pool.connect();
  try {
    await c.query("BEGIN");
    const ps = [
      ["001","Cuaderno Profesional","Pasta dura 100 hojas",35.00,50],
      ["002","Lapiz #2 HB","Lapiz madera hexagonal",5.00,120],
      ["003","Boligrafo Azul","Tinta azul punta fina",8.00,80],
      ["004","Boligrafo Negro","Tinta negra punta fina",8.00,60],
      ["005","Goma de Borrar","Goma blanca suave",4.00,90],
      ["006","Tijeras Escolares","Punta redonda 13cm",25.00,30],
      ["007","Regla 30cm","Plastico transparente",12.00,45],
      ["008","Compas Escolar","Metalico con lapiz",45.00,20],
      ["009","Pegamento en Barra","UHU 21g",18.00,55],
      ["010","Carpeta de Argollas","3 argollas carta",65.00,25],
      ["011","Papel Construccion","Block 20 hojas",22.00,40],
      ["012","Marcadores de Colores","Set 12 lavables",55.00,15],
      ["013","Mochila Escolar","Con porta laptop",350.00,8],
      ["014","Sacapuntas Doble","Metal doble orificio",10.00,70],
      ["015","Post-it 3x3","100 hojas amarillo",28.00,35],
      ["016","Folder Manila","Carta paquete 100",45.00,20],
      ["017","Plumones Permanentes","Set 4 punta gruesa",35.00,0],
      ["018","Corrector Liquido","Secado rapido 20ml",15.00,3],
      ["019","Calculadora Basica","Solar 12 digitos",120.00,12],
      ["020","Engrapadora Metalica","Capacidad 20 hojas",85.00,10],
    ];
    for (const p of ps) await c.query("INSERT INTO productos (codigo,nombre,descripcion,precio,stock,status) VALUES ($1,$2,$3,$4,$5,true) ON CONFLICT (codigo) DO NOTHING", p);
    console.log("OK productos (20)");
    const nombres=["Cuaderno Profesional","Boligrafo Azul","Lapiz #2 HB","Goma de Borrar","Tijeras Escolares","Regla 30cm","Pegamento en Barra","Marcadores de Colores"];
    const precios=[35,8,5,4,25,12,18,55];
    const hoy=new Date(); let tv=0;
    for(let i=6;i>=0;i--){const f=new Date(hoy);f.setDate(hoy.getDate()-i);const nv=3+Math.floor(Math.random()*4);for(let v=0;v<nv;v++){const ni=1+Math.floor(Math.random()*3);let tot=0;const items=[];for(let k=0;k<ni;k++){const idx=Math.floor(Math.random()*nombres.length);const cant=1+Math.floor(Math.random()*4);items.push([nombres[idx],cant,precios[idx]]);tot+=precios[idx]*cant;}const vr=await c.query("INSERT INTO ventas (fecha,total) VALUES ($1,$2) RETURNING id",[f.toISOString(),tot.toFixed(2)]);const vid=vr.rows[0].id;for(const it of items)await c.query("INSERT INTO detalle_venta (venta_id,nombre,cantidad,precio) VALUES ($1,$2,$3,$4)",[vid,it[0],it[1],it[2]]);tv++;}}
    console.log("OK ventas ("+tv+")");
    await c.query("INSERT INTO egresos (monto,fecha) VALUES (150,NOW()-INTERVAL '6 days'),(85.50,NOW()-INTERVAL '5 days'),(200,NOW()-INTERVAL '4 days'),(45,NOW()-INTERVAL '3 days'),(320,NOW()-INTERVAL '2 days'),(75,NOW()-INTERVAL '1 day'),(55,NOW())");
    console.log("OK egresos");
    const r1=await c.query("INSERT INTO tiendas (nombre,direccion,telefono,notas) VALUES ($1,$2,$3,$4) RETURNING id",["Papeleria Central","Calle Morelos #45","555-1234","Mayorista cuadernos"]);
    const r2=await c.query("INSERT INTO tiendas (nombre,direccion,telefono,notas) VALUES ($1,$2,$3,$4) RETURNING id",["Distribuidora El Estudiante","Av Universidad #120","555-5678","Utiles escolares"]);
    const r3=await c.query("INSERT INTO tiendas (nombre,direccion,telefono,notas) VALUES ($1,$2,$3,$4) RETURNING id",["OFFICEMAX Norte","Plaza Comercial Norte L5","555-9012","Articulos premium"]);
    const[id1,id2,id3]=[r1.rows[0].id,r2.rows[0].id,r3.rows[0].id];
    console.log("OK tiendas");
    const tps=[[id1,"Cuaderno 100 Hojas",28,"Mayoreo"],[id1,"Lapiz caja 12",45,"12 unidades"],[id1,"Boligrafo caja 12",75,"Azul y negro"],[id1,"Papel Bond Resma",95,"500 hojas"],[id2,"Cuaderno Profesional",32,"Pasta dura"],[id2,"Tijeras Escolares",20,"Punta redonda"],[id2,"Compas Escolar",38,"Con estuche"],[id2,"Regla 30cm",10,"Plastico"],[id2,"Marcadores x12",48,"Lavables"],[id2,"Sacapuntas Metalico",8,"Doble orificio"],[id3,"Post-it 3x3 x100",25,"Varios colores"],[id3,"Engrapadora Pro",180,"50 hojas"],[id3,"Calculadora Cientifica",320,"Casio FX-570"],[id3,"Folder Manila x100",40,"Carta"],[id3,"Corrector Liquido 20ml",12,"Secado rapido"]];
    for(const tp of tps) await c.query("INSERT INTO tienda_productos (tienda_id,nombre,precio,notas) VALUES ($1,$2,$3,$4)",tp);
    console.log("OK tienda_productos ("+tps.length+")");
    const lcs=[[id1,"Cuaderno 100 Hojas",20,28,"Resurtir stock",false],[id1,"Lapiz caja 12",5,45,null,false],[id1,"Papel Bond Resma",3,95,"Solicitar factura",false],[id2,"Marcadores x12",10,48,"URGENTE",false],[id2,"Tijeras Escolares",15,20,null,true],[id2,"Compas Escolar",8,38,null,false],[id3,"Post-it 3x3 x100",8,25,"Muy pedido",false],[id3,"Corrector Liquido 20ml",12,12,null,true],[null,"Plumones Permanentes",12,null,"Buscar proveedor",false]];
    for(const lc of lcs) await c.query("INSERT INTO lista_compras (tienda_id,nombre_producto,cantidad,precio_ref,notas,completado) VALUES ($1,$2,$3,$4,$5,$6)",lc);
    console.log("OK lista_compras ("+lcs.length+")");
    await c.query("COMMIT");
    console.log("SEED COMPLETO");
  } catch(e) { await c.query("ROLLBACK"); console.error("ERROR:",e.message); }
  finally { c.release(); await pool.end(); }
}
run();
