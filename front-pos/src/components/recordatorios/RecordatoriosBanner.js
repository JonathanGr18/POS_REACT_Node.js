import React from 'react';
import { useReminders } from '../../context/RemindersContext';
import { useSettings } from '../../context/SettingsContext';
import './RecordatoriosDrawer.css';

const RecordatoriosBanner = () => {
  const { pendientes, descartar } = useReminders();
  const { settings } = useSettings();

  if (!settings.notifRecordatorios || pendientes.length === 0) return null;

  return (
    <div className="rec-banner">
      <span style={{ fontSize: '1.2rem' }}>🔔</span>
      <div className="rec-banner-items">
        {pendientes.map(r => (
          <div key={r.id} className="rec-banner-item">
            <span className="rec-banner-titulo">{r.titulo}</span>
            {r.hora && <span className="rec-banner-hora">· {r.hora}</span>}
            {r.descripcion && <span className="rec-banner-hora">— {r.descripcion}</span>}
            <button className="rec-banner-close" onClick={() => descartar(r.id)}>✕</button>
          </div>
        ))}
      </div>
    </div>
  );
};

export default RecordatoriosBanner;
