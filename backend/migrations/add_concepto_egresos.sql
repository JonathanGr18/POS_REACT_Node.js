-- Agregar campo concepto a la tabla egresos para describir el gasto
ALTER TABLE public.egresos ADD COLUMN IF NOT EXISTS concepto text;
