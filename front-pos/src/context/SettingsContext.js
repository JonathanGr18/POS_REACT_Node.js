import React, { createContext, useContext, useState, useCallback } from 'react';

const STORAGE_KEY = 'pos_settings';

const DEFAULTS = {
  // Negocio
  nombre: 'Papeleria Amistad',
  direccion: 'Calle De la amistad #1414',
  colonia: 'Col. VillasPerisur, Zapopan, Jal.',
  whatsapp: 'WhatsApp. 33-4514-4736',
  rfc: '',
  // Ticket
  ticketFooter: '¡Gracias por su compra!',
  ticketTamano: '80mm',
  // Inventario
  stockUmbral: 10,
  // Notificaciones
  notifRecordatorios: true,
  notifStockCritico: true,
  notifVentaExitosa: true,
};

const SettingsContext = createContext(null);

export const SettingsProvider = ({ children }) => {
  const [settings, setSettings] = useState(() => {
    try {
      const saved = localStorage.getItem(STORAGE_KEY);
      return saved ? { ...DEFAULTS, ...JSON.parse(saved) } : DEFAULTS;
    } catch {
      return DEFAULTS;
    }
  });

  const updateSettings = useCallback((partial) => {
    setSettings(prev => {
      const next = { ...prev, ...partial };
      localStorage.setItem(STORAGE_KEY, JSON.stringify(next));
      return next;
    });
  }, []);

  const resetSettings = useCallback(() => {
    localStorage.removeItem(STORAGE_KEY);
    setSettings(DEFAULTS);
  }, []);

  return (
    <SettingsContext.Provider value={{ settings, updateSettings, resetSettings }}>
      {children}
    </SettingsContext.Provider>
  );
};

export const useSettings = () => {
  const ctx = useContext(SettingsContext);
  if (!ctx) throw new Error('useSettings must be used within SettingsProvider');
  return ctx;
};
