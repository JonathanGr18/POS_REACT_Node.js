# Guía de migración — PapeAmistad POS

Esta guía explica cómo llevar el sistema completo a una nueva computadora (punto de venta).

---

## 📋 Requisitos previos en la PC destino

1. **Node.js** v18 o superior → https://nodejs.org
2. **PostgreSQL 18** (o 16+) → https://www.postgresql.org/download/windows/
3. **Git** (opcional, si usas repo) → https://git-scm.com/

---

## 🚀 Pasos de migración

### 1. Copiar el proyecto

Copia la carpeta `Pos_Pape` completa (o clónala con git) al nuevo equipo.

**NO** copies estas carpetas — son pesadas y se regeneran:
- `front-pos/node_modules/`
- `backend/node_modules/`
- `front-pos/build/`

Sí copia:
- `front-pos/src/`, `front-pos/public/`, `package.json`, `package-lock.json`
- `backend/` (todo excepto `node_modules`)
- `backend/backups/papepos_full.sql` (dump de la BD)
- `backend/uploads/productos/` (imágenes de productos, si existen)

### 2. Instalar PostgreSQL y crear la BD

```bash
# Abrir psql como superusuario (postgres)
psql -U postgres

# Crear la base de datos
CREATE DATABASE papepos;

# Salir
\q
```

### 3. Restaurar el dump

```bash
# Desde la raíz del proyecto
cd backend/backups

# Importar dump completo (estructura + datos + secuencias)
psql -U postgres -d papepos -f papepos_full.sql
```

Esto restaurará:
- Tablas: `productos`, `ventas`, `detalle_venta`, `egresos`, `tiendas`, `tienda_productos`, `lista_compras`
- Índices, secuencias, constraints
- Todos los datos actuales

### 4. Configurar variables de entorno

**Backend** (`backend/.env`):
```env
DB_USER=postgres
DB_PASSWORD=tu_contraseña_de_postgres
HOST=127.0.0.1
DATABASE=papepos
PORT=5432

SERVER_PORT=5000
CORS_ORIGIN=http://localhost:3000

ACCESS_PASSWORD=admin

DEEPSEEK_API_KEY=tu_api_key_si_la_usas
```

**Frontend** (`front-pos/.env`):
```env
REACT_APP_API_URL=http://localhost:5000/api
SKIP_PREFLIGHT_CHECK=true
```

Copia desde `.env.example` en cada carpeta y modifica las credenciales.

### 5. Instalar dependencias

```bash
# Backend
cd backend
npm install

# Frontend (en otra terminal)
cd front-pos
npm install
```

### 6. Iniciar el sistema

#### Opción A — Desarrollo (manual, 2 terminales)

**Terminal 1 — Backend:**
```bash
cd backend
node server.js
```
Deberías ver: `Servidor en puerto 5000`

**Terminal 2 — Frontend:**
```bash
cd front-pos
npm start
```
Deberías ver: `Compiled successfully!` y se abrirá http://localhost:3000

#### Opción B — Producción con PM2 (daemon, recomendado)

PM2 mantiene el backend corriendo 24/7, lo reinicia si crashea, y arranca automáticamente al prender la PC.

**Instalar PM2 globalmente** (solo una vez):
```bash
npm install -g pm2
npm install -g pm2-windows-startup
```

**Compilar el frontend para producción** (sirve con `serve`):
```bash
cd front-pos
npm install -g serve
npm run build
```

**Arrancar con PM2** (desde la raíz `Pos_Pape/`):
```bash
pm2 start ecosystem.config.js
pm2 save
```

**Auto-arranque al encender la PC (Windows):**
```bash
pm2-startup install
pm2 save
```

**Comandos útiles:**
```bash
pm2 status              # ver estado
pm2 logs                # ver logs en vivo
pm2 logs pos-backend    # logs solo del backend
pm2 restart all         # reiniciar todo
pm2 stop all            # parar todo
pm2 delete all          # quitar de PM2
pm2 monit               # monitor interactivo
```

### 7. Verificar

Abre http://localhost:3000 y comprueba:
- ✅ Dashboard carga con ingresos del día
- ✅ Productos → accede con contraseña `admin`
- ✅ Ventas → puedes cobrar
- ✅ Reportes → gráficas se renderizan
- ✅ Faltantes → lista de stock bajo

---

## 🔄 Actualizar datos desde otra PC

Si ya tienes el POS funcionando en dos PCs y quieres sincronizar una con los datos de la otra:

**En la PC origen** (con datos nuevos):
```bash
cd backend
PGPASSWORD=tu_password "C:/Program Files/PostgreSQL/18/bin/pg_dump.exe" \
  -U postgres -h 127.0.0.1 -d papepos \
  --no-owner --no-privileges --clean --if-exists \
  -f backups/papepos_full.sql
```

Copia `backups/papepos_full.sql` a la PC destino.

**En la PC destino:**
```bash
psql -U postgres -d papepos -f backups/papepos_full.sql
```

---

## 🆕 Instalación limpia (SIN datos anteriores)

Si solo quieres la estructura vacía (sin los datos del dump):

```bash
cd backend
node -e "
const pool = require('./config/db');
(async () => {
  const fs = require('fs');
  // Ejecutar migraciones en orden
  const migrations = [
    'migrations/tiendas.sql',
    'migrations/add_categoria_precio_costo.sql',
    'migrations/add_concepto_egresos.sql',
    'migrations/fix_precio_precision.sql',
    'migrations/add_indices.sql',
  ];
  for (const m of migrations) {
    try {
      const sql = fs.readFileSync(m, 'utf8');
      await pool.query(sql);
      console.log('✓', m);
    } catch(e) { console.error('✗', m, e.message); }
  }
  pool.end();
})();
"
```

Esto crea la estructura mínima. Después puedes importar productos manualmente o desde otro dump.

---

## 📦 Scripts útiles (carpeta `backend/scripts/`)

- **`importar_respaldo.js`** — Importa datos desde `respaldo_total_pos.sql` (esquema viejo) a la nueva estructura
- **`capitalizar_productos.js`** — Capitaliza nombres de productos existentes en formato Title Case

Uso:
```bash
cd backend
node scripts/importar_respaldo.js
node scripts/capitalizar_productos.js
```

---

## ⚠️ Problemas comunes

### Error: `FATAL: la autentificación password falló`
- Verifica `DB_PASSWORD` en `backend/.env`
- Prueba conectarte manualmente: `psql -U postgres -h 127.0.0.1`

### Error: `no existe la base de datos "papepos"`
```bash
psql -U postgres -c "CREATE DATABASE papepos;"
```

### Error: `EADDRINUSE :::5000`
Ya hay un proceso en el puerto 5000. Mátalo:
```bash
netstat -ano | findstr :5000
taskkill /F /PID <PID>
```

### Frontend no conecta con backend (CORS)
- Verifica que `CORS_ORIGIN` en `backend/.env` incluya el origen del frontend
- Verifica que `REACT_APP_API_URL` en `front-pos/.env` apunte al backend correcto

### Imagen de productos no aparece
Las imágenes se guardan en `backend/uploads/productos/`. Si copiaste el proyecto sin esa carpeta, las imágenes se pierden (pero los productos siguen funcionando).

---

## 🔐 Seguridad en producción

Antes de poner en producción real:

1. **Cambiar contraseña de acceso**: no uses `admin`. Genera un hash bcrypt:
   ```bash
   node -e "console.log(require('bcrypt').hashSync('tu_pass_real', 10))"
   ```
   Pega el hash en `.env` como `ACCESS_PASSWORD_HASH=...`

2. **NODE_ENV**: `NODE_ENV=production` en `backend/.env` oculta detalles de errores

3. **HTTPS**: usar un reverse proxy (nginx) con certificado SSL

4. **Backups automáticos**: programar pg_dump diario

5. **Firewall**: restringir acceso al puerto de PostgreSQL (5432) solo a localhost
