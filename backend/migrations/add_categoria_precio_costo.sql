-- Migración: Agregar categoria, precio_costo y stock_minimo a productos
-- Fecha: 2026-04-03

-- Categoría del producto (ej: Papelería, Mochilas, Tecnología, etc.)
ALTER TABLE productos ADD COLUMN IF NOT EXISTS categoria VARCHAR(100) DEFAULT 'General';

-- Precio de costo (lo que cuesta al negocio)
ALTER TABLE productos ADD COLUMN IF NOT EXISTS precio_costo DECIMAL(10,2) DEFAULT 0;

-- Stock mínimo personalizado por producto (umbral de alerta)
ALTER TABLE productos ADD COLUMN IF NOT EXISTS stock_minimo INTEGER DEFAULT 15;
