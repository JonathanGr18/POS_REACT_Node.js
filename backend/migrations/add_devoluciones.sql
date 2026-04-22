-- Tabla de devoluciones y modificaciones de ventas
-- Registra anulaciones y ediciones para auditoría y reportes.

CREATE TABLE IF NOT EXISTS public.devoluciones (
  id SERIAL PRIMARY KEY,
  venta_id INTEGER,                         -- ID de la venta original (nullable si la venta fue eliminada)
  tipo VARCHAR(20) NOT NULL DEFAULT 'anulacion',  -- 'anulacion' | 'edicion'
  monto NUMERIC(10, 2) NOT NULL,            -- monto devuelto/modificado
  productos JSONB,                          -- snapshot de productos afectados
  motivo TEXT,                              -- opcional
  fecha TIMESTAMP WITHOUT TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_devoluciones_fecha ON public.devoluciones (fecha);
CREATE INDEX IF NOT EXISTS idx_devoluciones_tipo  ON public.devoluciones (tipo);
