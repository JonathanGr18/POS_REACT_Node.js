// Helpers centralizados de formato es-MX

const LOCALE = 'es-MX';

const currencyFormatter = new Intl.NumberFormat(LOCALE, {
  style: 'currency',
  currency: 'MXN',
  minimumFractionDigits: 2,
  maximumFractionDigits: 2,
});

const currencyFormatterSinDecimales = new Intl.NumberFormat(LOCALE, {
  style: 'currency',
  currency: 'MXN',
  minimumFractionDigits: 0,
  maximumFractionDigits: 0,
});

const numberFormatter = new Intl.NumberFormat(LOCALE);

/**
 * Formatea un numero como moneda mexicana ($1,234.50)
 */
export const formatCurrency = (value) => {
  const num = Number(value);
  if (!Number.isFinite(num)) return '$0.00';
  return currencyFormatter.format(num);
};

/**
 * Formatea moneda sin decimales ($1,234)
 */
export const formatCurrencyShort = (value) => {
  const num = Number(value);
  if (!Number.isFinite(num)) return '$0';
  return currencyFormatterSinDecimales.format(num);
};

/**
 * Formatea un numero con separadores de miles (1,234)
 */
export const formatNumber = (value) => {
  const num = Number(value);
  if (!Number.isFinite(num)) return '0';
  return numberFormatter.format(num);
};

/**
 * Formatea una fecha en es-MX
 */
export const formatDate = (value, opts = { day: '2-digit', month: 'short', year: 'numeric' }) => {
  const d = value instanceof Date ? value : new Date(value);
  if (isNaN(d.getTime())) return '—';
  return d.toLocaleDateString(LOCALE, opts);
};

/**
 * Formatea hora HH:MM en 24h
 */
export const formatTime = (value) => {
  const d = value instanceof Date ? value : new Date(value);
  if (isNaN(d.getTime())) return '—';
  return d.toLocaleTimeString(LOCALE, { hour: '2-digit', minute: '2-digit', hour12: false });
};

/**
 * Pluraliza singular/plural en espanol
 */
export const plural = (count, singular, pluralStr = null) => {
  const n = Number(count);
  const suffix = pluralStr || `${singular}s`;
  return n === 1 ? singular : suffix;
};
