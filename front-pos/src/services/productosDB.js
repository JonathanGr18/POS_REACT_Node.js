/**
 * IndexedDB wrapper para catálogo de productos.
 *
 * Estrategia: stale-while-revalidate
 *   1. getProductos() → devuelve lo que haya en IDB al instante (sin esperar red)
 *   2. En paralelo, revalida contra el servidor y actualiza IDB
 *   3. Emite evento "productos:actualizados" para que el UI re-render con datos frescos
 *
 * Beneficios para un POS con miles de productos:
 *   - Arranque instantáneo (no espera network en cold start)
 *   - Tolerancia a red lenta/caída (usa el último snapshot)
 *   - Sobrevive a recargas de pestaña
 */
import { openDB } from 'idb';
import api from './api';

const DB_NAME = 'pos-pape';
const DB_VERSION = 1;
const STORE = 'productos';
const META_STORE = 'meta';

let dbPromise = null;
let revalidatePromise = null;

const getDB = () => {
  if (!dbPromise) {
    dbPromise = openDB(DB_NAME, DB_VERSION, {
      upgrade(db) {
        if (!db.objectStoreNames.contains(STORE)) {
          db.createObjectStore(STORE, { keyPath: 'id' });
        }
        if (!db.objectStoreNames.contains(META_STORE)) {
          db.createObjectStore(META_STORE);
        }
      },
    });
  }
  return dbPromise;
};

// ── Lectura ──────────────────────────────────────────────
const leerTodosIDB = async () => {
  try {
    const db = await getDB();
    return await db.getAll(STORE);
  } catch {
    return [];
  }
};

const leerMeta = async (key) => {
  try {
    const db = await getDB();
    return await db.get(META_STORE, key);
  } catch {
    return undefined;
  }
};

// ── Escritura ────────────────────────────────────────────
const guardarTodosIDB = async (productos) => {
  try {
    const db = await getDB();
    const tx = db.transaction([STORE, META_STORE], 'readwrite');
    await tx.objectStore(STORE).clear();
    for (const p of productos) {
      await tx.objectStore(STORE).put(p);
    }
    await tx.objectStore(META_STORE).put(Date.now(), 'updatedAt');
    await tx.done;
  } catch (err) {
    console.warn('[productosDB] Error guardando:', err?.message);
  }
};

// ── Revalidación contra API ──────────────────────────────
const revalidar = async () => {
  if (revalidatePromise) return revalidatePromise;
  revalidatePromise = api.get('/productos')
    .then(async (res) => {
      const productos = res.data || [];
      await guardarTodosIDB(productos);
      // Notificar a los listeners (hooks, contextos)
      window.dispatchEvent(new CustomEvent('productos:actualizados', { detail: productos }));
      revalidatePromise = null;
      return productos;
    })
    .catch(err => {
      revalidatePromise = null;
      throw err;
    });
  return revalidatePromise;
};

/**
 * API pública: devuelve productos con estrategia stale-while-revalidate.
 *
 * @param {Object} opts
 * @param {boolean} opts.force  - si true, ignora IDB y fuerza red
 * @returns {Promise<Array>} productos (puede ser stale)
 */
export const getProductos = async ({ force = false } = {}) => {
  if (force) return revalidar();

  const stored = await leerTodosIDB();
  if (stored.length > 0) {
    // Dispara revalidación en segundo plano (no await)
    revalidar().catch(() => {});
    return stored;
  }
  // IDB vacío → primera carga, esperar red
  return revalidar();
};

/**
 * Invalida el cache. Útil cuando sabemos que cambió stock
 * (ventas, resurtir, edición de productos).
 */
export const invalidarProductos = async () => {
  try {
    const db = await getDB();
    await db.clear(STORE);
  } catch {}
};

/**
 * Refresca forzando fetch contra el servidor.
 */
export const refrescarProductos = () => revalidar();

/**
 * Suscribirse a actualizaciones. Callback recibe el array de productos.
 * Devuelve función para desuscribir.
 */
export const onProductosActualizados = (callback) => {
  const handler = (e) => callback(e.detail);
  window.addEventListener('productos:actualizados', handler);
  return () => window.removeEventListener('productos:actualizados', handler);
};

/**
 * Timestamp de la última sincronización con el servidor.
 * Útil para mostrar "última actualización hace X".
 */
export const getUltimaActualizacion = () => leerMeta('updatedAt');
