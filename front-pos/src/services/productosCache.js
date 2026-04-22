/**
 * Fachada del cache de productos.
 * Delega al storage persistente (IndexedDB) con estrategia stale-while-revalidate.
 * Mantiene la API original para evitar refactor masivo.
 */
import {
  getProductos,
  invalidarProductos,
  refrescarProductos,
  onProductosActualizados,
  getUltimaActualizacion,
} from './productosDB';

export const getProductosCache = ({ force = false } = {}) => getProductos({ force });

export const invalidarProductosCache = () => invalidarProductos();

// Re-exports para componentes que quieran subscribirse a actualizaciones en vivo
export { onProductosActualizados, refrescarProductos, getUltimaActualizacion };
