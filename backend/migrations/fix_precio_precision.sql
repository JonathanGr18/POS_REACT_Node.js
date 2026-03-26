-- Ampliar precisión del precio de productos de numeric(5,2) a numeric(10,2)
-- numeric(5,2) solo soporta hasta 999.99, causando overflow en precios >= 1000
ALTER TABLE public.productos ALTER COLUMN precio TYPE numeric(10,2);
