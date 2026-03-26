# Migraciones y Setup de Base de Datos

## Setup desde cero (nueva máquina)

### 1. Crear la base de datos
```bash
psql -U postgres -c "CREATE DATABASE papepos;"
```

### 2. Crear el schema (tablas, índices, etc.)
```bash
psql -U postgres -d papepos -f estructura.sql
```

### 3. (Opcional) Cargar datos reales
Si tienes el archivo `datos_iniciales.sql` (no está en el repo por privacidad):
```bash
psql -U postgres -d papepos -f backend/migrations/datos_iniciales.sql
```

### 4. Configurar variables de entorno
```bash
cp backend/.env.example backend/.env
# Edita backend/.env con tus credenciales
```

---

## Migraciones aplicadas

| Archivo | Descripción |
|---|---|
| `tiendas.sql` | Crea tablas de tiendas y tienda_productos |
| `fix_precio_precision.sql` | Amplía precio de numeric(5,2) a numeric(10,2) |
| `add_concepto_egresos.sql` | Agrega campo concepto a la tabla egresos |

Si tu BD ya existe y solo necesitas aplicar cambios:
```bash
psql -U postgres -d papepos -f backend/migrations/fix_precio_precision.sql
psql -U postgres -d papepos -f backend/migrations/add_concepto_egresos.sql
```

---

## Backup de datos

Para exportar todos los datos actuales:
```bash
pg_dump -U postgres -d papepos --data-only \
  --table=productos \
  --table=ventas \
  --table=detalle_venta \
  --table=egresos \
  --table=tiendas \
  --table=tienda_productos \
  --table=lista_compras \
  --disable-triggers \
  -f datos_iniciales.sql
```

Para backup completo (schema + datos):
```bash
pg_dump -U postgres -d papepos -f papepos_backup_completo.sql
```
