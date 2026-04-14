import React, { createContext, useContext, useState, useMemo, useCallback } from 'react';

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

  // Memo: evita recalculo innecesario en cada render
  const pendientes = useMemo(
    () => recordatorios.filter(r => esDueHoy(r) && !descartados.has(r.id)),
    [recordatorios, descartados]
  );

  // Persistencia centralizada (acepta lista directa, usa updater cuando es posible)
  const persistir = (lista) => {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(lista));
    return lista;
  };

  // Usa setRecordatorios(prev => ...) para evitar closures stale en batch updates
  const agregar = useCallback((datos) => {
    setRecordatorios(prev => persistir([
      ...prev,
      { ...datos, id: Date.now().toString() + Math.random().toString(36).slice(2, 6), activo: true }
    ]));
  }, []);

  const actualizar = useCallback((id, datos) => {
    setRecordatorios(prev => persistir(prev.map(r => r.id === id ? { ...r, ...datos } : r)));
  }, []);

  const eliminar = useCallback((id) => {
    setRecordatorios(prev => persistir(prev.filter(r => r.id !== id)));
  }, []);

  const descartar = useCallback((id) => {
    setDescartados(prev => {
      const nuevo = new Set(prev);
      nuevo.add(id);
      return nuevo;
    });
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
