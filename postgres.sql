-- TABLA DE PRODUCTOS
CREATE TABLE IF NOT EXISTS public.productos (
    id          SERIAL PRIMARY KEY,
    nombre      VARCHAR(255),
    precio      NUMERIC(5,2),
    descripcion TEXT,
    codigo      VARCHAR(50),
    stock       INTEGER,
    status      BOOLEAN DEFAULT TRUE
);

-- TABLA DE VENTAS
CREATE TABLE IF NOT EXISTS public.ventas (
    id     SERIAL PRIMARY KEY,
    fecha  TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    total  NUMERIC NOT NULL
);

-- DETALLE DE CADA VENTA
CREATE TABLE IF NOT EXISTS public.detalle_venta (
    id         SERIAL PRIMARY KEY,
    venta_id   INTEGER NOT NULL REFERENCES public.ventas(id),
    nombre     TEXT    NOT NULL,
    cantidad   INTEGER NOT NULL,
    precio     NUMERIC NOT NULL
);

-- TABLA DE REPORTES (GUARDA JSON DE PRODUCTOS VENDIDOS)
CREATE TABLE IF NOT EXISTS public.reportes (
    id        SERIAL PRIMARY KEY,
    productos JSONB NOT NULL,
    total     NUMERIC NOT NULL,
    fecha     TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- TABLA DE EGRESOS
CREATE TABLE IF NOT EXISTS public.egresos (
    id     SERIAL PRIMARY KEY,
    monto  NUMERIC(10,2) NOT NULL,
    fecha  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
