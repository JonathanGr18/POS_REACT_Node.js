# 📦 PapeAmistad POS — Sistema de Punto de Venta

Sistema de Punto de Venta (POS) desarrollado con **React + Node.js + PostgreSQL**, orientado a papelerías y negocios minoristas. Gestiona productos, ventas, inventario, reportes, lista de compras y asistente IA.

---

## 🤖 INSTRUCCIONES PARA CLAUDE CODE (migración automática)

> **Si eres Claude Code leyendo este README en una PC nueva:**
> Este proyecto fue desarrollado conmigo en otra computadora. Necesito migrarlo completo a esta PC.
> Tu tarea es realizar la migración siguiendo las secciones de abajo **en orden**.
>
> **Tu plan:**
> 1. Verifica prerequisitos (Node.js, PostgreSQL instalados)
> 2. Ejecuta los pasos de **instalación** (sección abajo)
> 3. Restaura la base de datos desde `backend/backups/papepos_full.sql`
> 4. Crea los archivos `.env` en `backend/` y `front-pos/` basándote en los `.env.example`
> 5. Instala dependencias (`npm install` en cada carpeta)
> 6. Compila el frontend (`npm run build`)
> 7. Configura PM2 con `ecosystem.config.js` para arranque como daemon
> 8. Verifica que todo corre bien (backend en 5000, frontend en 3000)
> 9. Configura auto-arranque al reiniciar PC (pm2-startup)
>
> **Contexto importante del proyecto:**
> - Usa `America/Mexico_City` como timezone en todas las queries de BD
> - Backend valida estrictamente tipos y longitudes (ver `backend/controllers/productosCon.js`)
> - Los nombres de productos se guardan en **Title Case** (ver helper `capitalizarNombre`)
> - El POS tiene autenticación por contraseña para acceder a `/productos` (default: `admin`)
> - Rate limiting configurado en `server.js` (ajustar si hace falta para la red local)
> - Dump SQL actual en `backend/backups/papepos_full.sql` — contiene 1374 productos, 3373 ventas
> - IDs se mantienen del dump original (secuencias ajustadas automáticamente)
>
> Lee `MIGRACION.md` si necesitas detalles técnicos adicionales.
> Pregunta antes de hacer cosas destructivas (DROP, wipe, etc).

---

## 🛠️ Stack tecnológico

**Frontend:** React 19 · React Router · Axios · jsPDF · qrcode.react · jsbarcode
**Backend:** Node.js + Express 5 · PostgreSQL · bcrypt · JWT · multer · helmet · express-rate-limit
**Proceso:** PM2 (daemon) · serve (frontend prod)

---

## ⚙️ Funcionalidades

- **Productos** — CRUD completo, imágenes, categorías, precio costo/venta, stock mínimo por producto, códigos de barras/QR
- **Ventas (POS)** — Catálogo visual, carrito, descuentos %/monto, billetero MXN, atajos de teclado (F2 búsqueda, F4 exacto, Ctrl+Enter cobrar), scanner compatible, órdenes pausadas
- **Faltantes** — KPIs de inventario crítico, sugerencias de resurtido, exportar PDF/WhatsApp
- **Reportes** — KPIs con comparativa, gráficas (día, hora, mes, heatmap anual), métodos de pago, top productos, PDF detallado
- **Dashboard** — Resumen del día, ingresos, stock crítico, últimas ventas
- **Lista de compras** — Integración con faltantes, asignación por tienda/proveedor
- **Tiendas** — Gestión de proveedores con catálogo
- **Asistente IA** — Chat con DeepSeek usando contexto real del negocio
- **Recordatorios** — Tareas programadas (diarias, semanales, fecha específica)
- **Multi-dispositivo** — Dark mode, responsive, accesibilidad WCAG

---

# 🚀 Guía de instalación y migración

## 📋 Requisitos previos en la PC destino

1. **Node.js** v18 o superior → https://nodejs.org
2. **PostgreSQL 16+** → https://www.postgresql.org/download/windows/
3. **Git** (opcional)

---

## Paso 1 — Copiar el proyecto

Copia la carpeta `Pos_Pape/` completa al nuevo equipo.

**NO copies** (se regeneran):
- `front-pos/node_modules/`
- `backend/node_modules/`
- `front-pos/build/`

**SÍ copia**:
- Todo el código fuente (`src/`, `public/`, `package.json`, etc.)
- `backend/backups/papepos_full.sql` ← **CRÍTICO** (datos actuales)
- `backend/uploads/productos/` (imágenes, si hay)
- `ecosystem.config.js` (config PM2)
- `.env.example` de ambas carpetas (no `.env`)

---

## Paso 2 — Crear y restaurar base de datos

```bash
# Abrir psql como superusuario
psql -U postgres

# Crear la BD
CREATE DATABASE papepos;
\q

# Restaurar dump completo
psql -U postgres -d papepos -f backend/backups/papepos_full.sql
```

Esto restaurará 1374 productos, 3373 ventas, 7336 registros de detalle_venta, 30 egresos, con estructura completa (índices, secuencias, triggers).

---

## Paso 3 — Configurar variables de entorno

**`backend/.env`** (copiar desde `backend/.env.example`):
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

**`front-pos/.env`** (copiar desde `front-pos/.env.example`):
```env
REACT_APP_API_URL=http://localhost:5000/api
SKIP_PREFLIGHT_CHECK=true
```

---

## Paso 4 — Instalar dependencias

```bash
cd backend
npm install

cd ../front-pos
npm install
```

---

## Paso 5 — Compilar frontend para producción

```bash
cd front-pos
npm run build
```

Esto crea `front-pos/build/` con el frontend estático optimizado.

---

## Paso 6 — Configurar PM2 (daemon)

PM2 mantiene el backend corriendo 24/7, lo reinicia si crashea, y arranca solo al prender la PC.

**Instalar PM2** (si no lo tienes):
```bash
npm install -g pm2
npm install -g pm2-windows-startup
npm install -g serve
```

**Arrancar con PM2** (desde la raíz `Pos_Pape/`):
```bash
pm2 start ecosystem.config.js
pm2 save
```

**Auto-arranque al boot de Windows:**
```bash
pm2-startup install
pm2 save
```

**Verificar que corre:**
```bash
pm2 status
# Deberías ver: pos-backend (online) y pos-frontend (online)

pm2 logs
# Ver logs en vivo. Ctrl+C para salir.
```

---

## Paso 7 — Verificar en el navegador

Abre: **http://localhost:3000**

- ✅ Dashboard carga
- ✅ Productos → accede con contraseña `admin`
- ✅ Ventas → puedes cobrar
- ✅ Reportes → gráficas se renderizan
- ✅ Faltantes → lista de stock bajo

---

## 📊 Comandos PM2 útiles

```bash
pm2 status              # ver estado de todos los procesos
pm2 logs                # logs en vivo (de todos)
pm2 logs pos-backend    # logs solo del backend
pm2 restart all         # reiniciar todo
pm2 restart pos-backend # reiniciar solo backend
pm2 stop all            # parar todo
pm2 delete all          # quitar de PM2
pm2 monit               # monitor interactivo (CPU/RAM)
pm2 flush               # limpiar logs
```

---

## 🔄 Sincronizar datos entre dos PCs

Si usas el POS en 2 equipos y quieres llevar los datos de una a otra:

**En la PC origen** (con datos nuevos):
```bash
cd backend
node scripts/exportar_para_migrar.js
# Genera backups/papepos_full.sql actualizado
```

Copia `backend/backups/papepos_full.sql` a la PC destino (USB, red, cloud).

**En la PC destino** (primero parar PM2 para evitar writes durante el restore):
```bash
pm2 stop pos-backend
psql -U postgres -d papepos -f backend/backups/papepos_full.sql
pm2 restart pos-backend
```

---

## 📦 Scripts útiles (`backend/scripts/`)

- **`importar_respaldo.js`** — Importa datos desde un dump viejo (`respaldo_total_pos.sql`) al esquema actual
- **`capitalizar_productos.js`** — Convierte nombres de productos a Title Case
- **`exportar_para_migrar.js`** — Genera `papepos_full.sql` con estado actual

Uso:
```bash
cd backend
node scripts/<nombre_del_script>.js
```

---

## 🤖 Instalar Claude Code (asistente)

Claude Code te permite tener un asistente de IA dentro de la terminal para ayudarte con el código y la operación del POS.

### Instalación

```bash
npm install -g @anthropic-ai/claude-code
```

### Primer uso

```bash
cd ruta\al\Pos_Pape
claude
```

La primera vez se abrirá el navegador para login con tu cuenta de Anthropic. Una vez autenticado, Claude tiene acceso a los archivos del proyecto.

### Comandos básicos

```bash
claude                  # iniciar en la carpeta actual
claude --version        # ver versión
claude --help           # ver opciones
```

Dentro de Claude:
- Solo escribe lo que necesitas en lenguaje natural
- `/exit` — salir
- `/help` — ver comandos internos
- `/clear` — limpiar contexto

### Tip para que Claude tome el control de la migración

Cuando abras Claude por primera vez en la nueva PC, pégale esto:

> "Lee el README.md de este proyecto. Es un POS que estoy migrando desde otra computadora. Ejecuta los pasos de la sección 'INSTRUCCIONES PARA CLAUDE CODE (migración automática)' en orden. Pídeme confirmación antes de cualquier acción destructiva."

Claude leerá este mismo README y ejecutará todos los pasos por ti.

---

## 🆘 Problemas comunes

### `FATAL: la autentificación password falló`
Verifica `DB_PASSWORD` en `backend/.env`. Prueba conectarte manualmente:
```bash
psql -U postgres -h 127.0.0.1
```

### `no existe la base de datos "papepos"`
```bash
psql -U postgres -c "CREATE DATABASE papepos;"
```

### `EADDRINUSE :::5000` (puerto ocupado)
```bash
netstat -ano | findstr :5000
taskkill /F /PID <PID>
```

### Frontend no conecta con backend (CORS)
- `CORS_ORIGIN` en `backend/.env` debe incluir el origen del frontend
- `REACT_APP_API_URL` en `front-pos/.env` debe apuntar al backend

### Imágenes de productos no aparecen
Las imágenes se guardan en `backend/uploads/productos/`. Si no copiaste esa carpeta, se pierden (los productos siguen funcionando sin imagen).

### PM2 no arranca en el boot
```bash
pm2-startup uninstall
pm2-startup install
pm2 save
```

---

## 🔐 Seguridad en producción

Antes de usar en producción real:

1. **Cambiar contraseña de acceso** — no uses `admin`. Genera un hash bcrypt:
   ```bash
   node -e "console.log(require('bcrypt').hashSync('tu_pass_real', 10))"
   ```
   Pégalo en `.env` como `ACCESS_PASSWORD_HASH=...`

2. **`NODE_ENV=production`** en `backend/.env` oculta detalles de errores al cliente

3. **HTTPS** con reverse proxy (nginx + certificado SSL)

4. **Backups automáticos** de la BD:
   ```bash
   # Programar con Task Scheduler de Windows:
   node C:\ruta\Pos_Pape\backend\scripts\exportar_para_migrar.js
   ```

5. **Firewall**: restringir puerto 5432 (Postgres) solo a localhost

---

## 📂 Estructura del proyecto

```
Pos_Pape/
├── backend/
│   ├── controllers/        # Lógica de negocio
│   ├── routes/             # Endpoints REST
│   ├── migrations/         # Migraciones SQL
│   ├── config/db.js        # Conexión Postgres
│   ├── scripts/            # Scripts de utilidad
│   ├── backups/            # Dumps SQL
│   ├── uploads/productos/  # Imágenes subidas
│   ├── logs/               # Logs de PM2
│   ├── server.js           # Entry point
│   └── .env                # Variables (NO se versiona)
├── front-pos/
│   ├── src/
│   │   ├── pages/          # Páginas principales
│   │   ├── components/     # Componentes reutilizables
│   │   ├── context/        # React contexts
│   │   ├── hooks/          # Custom hooks
│   │   ├── services/api.js # Cliente Axios
│   │   ├── utils/format.js # Helpers de formato (es-MX)
│   │   └── styles/         # CSS global
│   ├── public/
│   ├── build/              # Generado con npm run build
│   ├── logs/               # Logs de PM2
│   └── .env                # Variables (NO se versiona)
├── ecosystem.config.js     # Config PM2
├── MIGRACION.md            # Guía detallada de migración
└── README.md               # Este archivo
```

---

## 📝 Licencia

Proyecto personal desarrollado para Papelería Amistad. Uso interno.
