import { useState, useEffect, useRef } from 'react';

/**
 * useState persistido en localStorage.
 *
 * @template T
 * @param {string} key              clave en localStorage
 * @param {T} defaultValue          valor inicial si no existe
 * @returns {[T, (value: T | ((prev: T) => T)) => void]}
 */
export default function useLocalStorageState(key, defaultValue) {
  const [value, setValue] = useState(() => {
    try {
      const raw = localStorage.getItem(key);
      if (raw === null) return defaultValue;
      return JSON.parse(raw);
    } catch {
      return defaultValue;
    }
  });

  // Evita escribir al mount inicial (el valor ya viene de localStorage)
  const firstRender = useRef(true);
  useEffect(() => {
    if (firstRender.current) {
      firstRender.current = false;
      return;
    }
    try {
      localStorage.setItem(key, JSON.stringify(value));
    } catch {
      // localStorage puede fallar por quota o modo privado; silenciar
    }
  }, [key, value]);

  return [value, setValue];
}
