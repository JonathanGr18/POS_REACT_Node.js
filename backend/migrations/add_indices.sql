-- Migración: Índices críticos para performance de queries
-- Fecha: 2026-04-13

-- Filtros por fecha (reportes, ventas del día/anteriores)
CREATE INDEX IF NOT EXISTS idx_ventas_fecha ON ventas(fecha);

-- JOINs detalle_venta ↔ ventas
CREATE INDEX IF NOT EXISTS idx_detalle_venta_venta_id ON detalle_venta(venta_id);

-- Lookups por nombre en detalle_venta (usado por faltantes y top-productos)
CREATE INDEX IF NOT EXISTS idx_detalle_venta_nombre ON detalle_venta(nombre);

-- Filtros de productos por categoría
CREATE INDEX IF NOT EXISTS idx_productos_categoria ON productos(categoria);

-- Lookup de productos por código (ya debería ser unique, pero por si acaso)
CREATE INDEX IF NOT EXISTS idx_productos_codigo ON productos(codigo);

-- Filtros de faltantes (stock <= stock_minimo)
CREATE INDEX IF NOT EXISTS idx_productos_stock ON productos(stock);

-- Egresos por fecha (reportes mensuales)
CREATE INDEX IF NOT EXISTS idx_egresos_fecha ON egresos(fecha);

-- Agrupaciones por método de pago
CREATE INDEX IF NOT EXISTS idx_ventas_metodo_pago ON ventas(metodo_pago);

-- Lista de compras por tienda (FK lookup)
CREATE INDEX IF NOT EXISTS idx_lista_compras_tienda_id ON lista_compras(tienda_id);

-- Productos de una tienda (FK lookup)
CREATE INDEX IF NOT EXISTS idx_tienda_productos_tienda_id ON tienda_productos(tienda_id);
