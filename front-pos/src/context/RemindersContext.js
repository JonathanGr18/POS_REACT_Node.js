import React, { createContext, useContext, useState, useEffect, useCallback } from 'react';

const STORAGE_KEY = 'pos_recordatorios';

const RemindersContext = createContext(null);

const hoyISO = () => new Date().toISOString().slice(0, 10);
const diaSemanaHoy = () => new Date().getDay(); // 0=Dom … 6=Sab

const esDueHoy = (r) => {
  if (!r.activo) return false;
  if (r.tipo === 'fecha')    return r.fecha === hoyISO();
  if (r.tipo === 'diario')   return true;
  if (r.tipo === 'semanal')  return (r.diasSemana || []).includes(diaSemanaHoy());
  return false;
};

export const RemindersProvider = ({ children }) => {
  const [recordatorios, setRecordatorios] = useState(() => {
    try { return JSON.parse(localStorage.getItem(STORAGE_KEY) || '[]'); }
    catch { return []; }
  });

  // Pendientes para hoy (descartados sólo en sesión)
  const [descartados, setDescartados] = useState(new Set());
  const [drawerAbierto, setDrawerAbierto] = useState(false);

  const pendientes = recordatorios.filter(r => esDueHoy(r) && !descartados.has(r.id));

  const save = useCallback((lista) => {
    setRecordatorios(lista);
    localStorage.setItem(STORAGE_KEY, JSON.stringify(lista));
  }, []);

  const agregar = useCallback((datos) => {
    save([...recordatorios, { ...datos, id: Date.now().toString(), activo: true }]);
  }, [recordatorios, save]);

  const actualizar = useCallback((id, datos) => {
    save(recordatorios.map(r => r.id === id ? { ...r, ...datos } : r));
  }, [recordatorios, save]);

  const eliminar = useCallback((id) => {
    save(recordatorios.filter(r => r.id !== id));
  }, [recordatorios, save]);

  const descartar = useCallback((id) => {
    setDescartados(prev => new Set([...prev, id]));
  }, []);

  const abrirDrawer  = useCallback(() => setDrawerAbierto(true),  []);
  const cerrarDrawer = useCallback(() => setDrawerAbierto(false), []);

  return (
    <RemindersContext.Provider value={{
      recordatorios, pendientes,
      agregar, actualizar, eliminar, descartar,
      drawerAbierto, abrirDrawer, cerrarDrawer,
    }}>
      {children}
    </RemindersContext.Provider>
  );
};

export const useReminders = () => {
  const ctx = useContext(RemindersContext);
  if (!ctx) throw new Error('useReminders must be used within RemindersProvider');
  return ctx;
};
