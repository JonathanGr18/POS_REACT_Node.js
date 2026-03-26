-- Tiendas (proveedores manuales)
CREATE TABLE IF NOT EXISTS tiendas (
  id SERIAL PRIMARY KEY,
  nombre VARCHAR(200) NOT NULL,
  direccion TEXT,
  telefono VARCHAR(50),
  notas TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Productos disponibles en cada tienda
CREATE TABLE IF NOT EXISTS tienda_productos (
  id SERIAL PRIMARY KEY,
  tienda_id INTEGER NOT NULL REFERENCES tiendas(id) ON DELETE CASCADE,
  nombre VARCHAR(200) NOT NULL,
  precio DECIMAL(10,2),
  notas TEXT,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Lista de compras para resurtido
CREATE TABLE IF NOT EXISTS lista_compras (
  id SERIAL PRIMARY KEY,
  tienda_id INTEGER REFERENCES tiendas(id) ON DELETE SET NULL,
  nombre_producto VARCHAR(200) NOT NULL,
  cantidad INTEGER NOT NULL DEFAULT 1,
  precio_ref DECIMAL(10,2),
  notas TEXT,
  completado BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
