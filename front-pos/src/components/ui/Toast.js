import React, { createContext, useContext, useState, useCallback, useRef, useEffect } from 'react';
import './Toast.css';

const ToastContext = createContext(null);

export const useToast = () => useContext(ToastContext);

const MAX_TOASTS = 5;

export const ToastProvider = ({ children }) => {
  const [toasts, setToasts] = useState([]);
  const idCounterRef = useRef(0);
  const timeoutsRef = useRef(new Map());

  const removeToast = useCallback((id) => {
    const timeoutId = timeoutsRef.current.get(id);
    if (timeoutId) {
      clearTimeout(timeoutId);
      timeoutsRef.current.delete(id);
    }
    setToasts(prev => prev.filter(t => t.id !== id));
  }, []);

  const addToast = useCallback((mensaje, tipo = 'info') => {
    const id = ++idCounterRef.current;
    setToasts(prev => {
      const nuevo = [...prev, { id, mensaje, tipo }];
      // Limitar cola (descartar mas antiguos y limpiar sus timeouts)
      if (nuevo.length > MAX_TOASTS) {
        const descartados = nuevo.slice(0, nuevo.length - MAX_TOASTS);
        descartados.forEach(t => {
          const tid = timeoutsRef.current.get(t.id);
          if (tid) { clearTimeout(tid); timeoutsRef.current.delete(t.id); }
        });
        return nuevo.slice(-MAX_TOASTS);
      }
      return nuevo;
    });
    const timeoutId = setTimeout(() => {
      timeoutsRef.current.delete(id);
      setToasts(prev => prev.filter(t => t.id !== id));
    }, 3500);
    timeoutsRef.current.set(id, timeoutId);
  }, []);

  // Cleanup al desmontar el provider
  useEffect(() => {
    const timeouts = timeoutsRef.current;
    return () => {
      timeouts.forEach(tid => clearTimeout(tid));
      timeouts.clear();
    };
  }, []);

  // Separar por severidad para aria-live correcto
  const errorToasts = toasts.filter(t => t.tipo === 'error');
  const otherToasts = toasts.filter(t => t.tipo !== 'error');

  return (
    <ToastContext.Provider value={{ addToast }}>
      {children}
      {/* Errores = assertive (interrumpe al lector de pantalla) */}
      <div
        className="toast-container"
        role="alert"
        aria-live="assertive"
        aria-atomic="true"
      >
        {errorToasts.map(t => (
          <div key={t.id} className={`toast toast-${t.tipo}`}>
            <span className="toast-msg">{t.mensaje}</span>
            <button
              className="toast-close"
              onClick={() => removeToast(t.id)}
              aria-label="Cerrar notificación"
            >×</button>
          </div>
        ))}
      </div>
      {/* Info/exito/aviso = polite (no interrumpe) */}
      <div
        className="toast-container"
        role="status"
        aria-live="polite"
        aria-atomic="true"
      >
        {otherToasts.map(t => (
          <div key={t.id} className={`toast toast-${t.tipo}`}>
            <span className="toast-msg">{t.mensaje}</span>
            <button
              className="toast-close"
              onClick={() => removeToast(t.id)}
              aria-label="Cerrar notificación"
            >×</button>
          </div>
        ))}
      </div>
    </ToastContext.Provider>
  );
};
