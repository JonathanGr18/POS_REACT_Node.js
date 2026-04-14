import axios from 'axios';

const BASE = process.env.REACT_APP_API_URL || 'http://localhost:5000/api';

const api = axios.create({
  baseURL: BASE,
  timeout: 15000, // 15 segundos para evitar requests colgados
  headers: {
    'Content-Type': 'application/json',
  },
});

// Interceptor de errores: log + retry 1 vez en errores de red (GET idempotentes)
api.interceptors.response.use(
  (res) => res,
  async (err) => {
    const cfg = err.config || {};
    const esGet = (cfg.method || 'get').toLowerCase() === 'get';
    // Solo reintentar en ERR_NETWORK (red caida), NO en timeouts
    // (los timeouts suelen ser endpoints lentos y reintentar duplica carga)
    const esErrorRed = err.code === 'ERR_NETWORK';

    if (esGet && esErrorRed && !cfg.__retried) {
      cfg.__retried = true;
      await new Promise(r => setTimeout(r, 500));
      return api.request(cfg);
    }

    // No spamear console con errores cancelados (AbortController)
    if (err.code !== 'ERR_CANCELED') {
      console.warn('[API]', cfg.method?.toUpperCase(), cfg.url, '→', err.message);
    }
    return Promise.reject(err);
  }
);

export const IMAGE_BASE_URL = BASE.replace(/\/api$/, '');

export default api;
