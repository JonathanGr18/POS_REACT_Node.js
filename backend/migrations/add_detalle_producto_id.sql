-- Agrega producto_id a detalle_venta para identificar productos con nombre duplicado
-- y hacer ajustes de stock precisos al editar ventas.
ALTER TABLE public.detalle_venta
  ADD COLUMN IF NOT EXISTS producto_id INTEGER;

-- Backfill best-effort: matchea por nombre. Si hay duplicados, toma el primero por id.
UPDATE public.detalle_venta dv
   SET producto_id = p.id
  FROM (
    SELECT DISTINCT ON (nombre) id, nombre
      FROM public.productos
      ORDER BY nombre, id
  ) p
 WHERE dv.nombre = p.nombre
   AND dv.producto_id IS NULL;

CREATE INDEX IF NOT EXISTS idx_detalle_venta_producto_id ON public.detalle_venta (producto_id);
