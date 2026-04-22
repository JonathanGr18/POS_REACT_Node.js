-- Índices extra para búsqueda y paginación de ventas

-- Búsqueda rápida de productos por nombre (prefix match con B-tree)
CREATE INDEX IF NOT EXISTS idx_productos_nombre ON productos (LOWER(nombre) varchar_pattern_ops);

-- Composite para detalle_venta (reportes top-productos por período)
CREATE INDEX IF NOT EXISTS idx_detalle_venta_venta_nombre ON detalle_venta (venta_id, nombre);

-- Index DESC en fecha para paginación eficiente del historial
CREATE INDEX IF NOT EXISTS idx_ventas_fecha_desc ON ventas (fecha DESC);
