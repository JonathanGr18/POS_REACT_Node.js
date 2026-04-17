import React, { useState, useEffect } from 'react';
import { useSettings } from '../context/SettingsContext';
import { useReminders } from '../context/RemindersContext';
import { useToast } from '../components/ui/Toast';
import useDarkMode from '../hooks/useDarkMode';
import './Settings.css';

const Section = ({ titulo, children }) => (
  <div className="settings-section">
    <h3 className="settings-section-titulo">{titulo}</h3>
    <div className="settings-section-body">{children}</div>
  </div>
);

const Field = ({ label, hint, children }) => (
  <div className="settings-field">
    <label className="settings-field-label">{label}</label>
    {hint && <p className="settings-field-hint">{hint}</p>}
    {children}
  </div>
);

const ToggleField = ({ label, hint, value, onChange }) => (
  <div className="settings-toggle-field">
    <div className="settings-toggle-info">
      <span className="settings-field-label">{label}</span>
      {hint && <p className="settings-field-hint">{hint}</p>}
    </div>
    <button
      type="button"
      className={`settings-toggle${value ? ' activo' : ''}`}
      onClick={() => onChange(!value)}
      aria-label={label}
    >
      <span className="settings-toggle-knob" />
    </button>
  </div>
);

const DIAS = ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb'];

const descripcionRec = (r) => {
  if (r.tipo === 'diario')  return `Diario${r.hora ? ` · ${r.hora}` : ''}`;
  if (r.tipo === 'semanal') {
    const dias = (r.diasSemana || []).map(d => DIAS[d]).join(', ');
    return `${dias}${r.hora ? ` · ${r.hora}` : ''}`;
  }
  if (r.tipo === 'fecha')   return `${r.fecha}${r.hora ? ` · ${r.hora}` : ''}`;
  return '';
};

const Settings = () => {
  const { settings, updateSettings, resetSettings } = useSettings();
  const { recordatorios, abrirDrawer } = useReminders();
  const { addToast } = useToast();
  const { darkMode, toggle } = useDarkMode();

  const [form, setForm] = useState({ ...settings });
  const [guardado, setGuardado] = useState(false);

  useEffect(() => { setForm({ ...settings }); }, [settings]);

  // Guardado diferido para campos de texto (evita escribir a localStorage en cada tecla)
  useEffect(() => {
    const t = setTimeout(() => {
      // Solo guardar si hay cambios reales respecto a settings
      const cambios = Object.keys(form).some(k => form[k] !== settings[k]);
      if (cambios) updateSettings(form);
    }, 500);
    return () => clearTimeout(t);
  }, [form, settings, updateSettings]);

  const set = (key) => (e) => {
    const value = e.target.type === 'number' ? Number(e.target.value) : e.target.value;
    setForm(prev => ({ ...prev, [key]: value }));
  };

  // Toggles y número: guardado inmediato (sin esperar debounce)
  const setToggle = (key) => (val) => {
    setForm(prev => ({ ...prev, [key]: val }));
    updateSettings({ [key]: val });
  };

  const handleGuardar = () => {
    updateSettings(form);
    setGuardado(true);
    addToast('Configuración guardada', 'exito');
    setTimeout(() => setGuardado(false), 2000);
  };

  const handleReset = () => {
    if (!window.confirm('¿Restaurar todos los valores por defecto?')) return;
    resetSettings();
    addToast('Configuración restaurada', 'aviso');
  };

  return (
    <div className="settings-page">
      <div className="settings-header">
        <h2 className="settings-titulo">⚙️ Configuración</h2>
        <div className="settings-header-actions">
          <button className="btn-settings-reset" onClick={handleReset}>Restaurar valores</button>
          <button
            className={`btn-settings-guardar${guardado ? ' guardado' : ''}`}
            onClick={handleGuardar}
          >
            {guardado ? '✓ Guardado' : 'Guardar cambios'}
          </button>
        </div>
      </div>

      {/* ── Negocio ── */}
      <Section titulo="🏪 Información del negocio">
        <Field label="Nombre del negocio">
          <input className="settings-input" type="text" value={form.nombre} onChange={set('nombre')} placeholder="Ej. Papelería Amistad" />
        </Field>
        <Field label="Dirección">
          <input className="settings-input" type="text" value={form.direccion} onChange={set('direccion')} placeholder="Calle y número" />
        </Field>
        <Field label="Colonia / Ciudad">
          <input className="settings-input" type="text" value={form.colonia} onChange={set('colonia')} placeholder="Col. Nombre, Ciudad, Estado" />
        </Field>
        <Field label="Teléfono / WhatsApp">
          <input className="settings-input" type="text" value={form.whatsapp} onChange={set('whatsapp')} placeholder="Ej. WhatsApp. 33-1234-5678" />
        </Field>
        <Field label="RFC" hint="Opcional. Aparece al pie del ticket.">
          <input className="settings-input settings-input--sm" type="text" value={form.rfc} onChange={set('rfc')} placeholder="XAXX010101000" style={{ textTransform: 'uppercase' }} />
        </Field>
      </Section>

      {/* ── Ticket ── */}
      <Section titulo="🧾 Ticket / Comprobante">
        <Field label="Mensaje de pie de ticket">
          <input className="settings-input" type="text" value={form.ticketFooter} onChange={set('ticketFooter')} placeholder="¡Gracias por su compra!" />
        </Field>
        <Field label="Tamaño de papel predeterminado">
          <div className="settings-radio-row">
            {['58mm', '80mm'].map(t => (
              <label key={t} className={`settings-radio-btn${form.ticketTamano === t ? ' activo' : ''}`}>
                <input type="radio" name="ticketTamano" value={t} checked={form.ticketTamano === t} onChange={set('ticketTamano')} />
                {t}
              </label>
            ))}
          </div>
        </Field>
      </Section>

      {/* ── Inventario ── */}
      <Section titulo="📦 Inventario">
        <Field label="Umbral de stock crítico" hint="Productos con esta cantidad o menos aparecen en la alerta del menú y en Faltantes.">
          <input className="settings-input settings-input--sm" type="number" value={form.stockUmbral} onChange={set('stockUmbral')} min="1" max="200" />
        </Field>
      </Section>

      {/* ── Notificaciones ── */}
      <Section titulo="🔔 Notificaciones">
        <ToggleField
          label="Recordatorios al iniciar"
          hint="Muestra un banner con los recordatorios activos del día."
          value={form.notifRecordatorios}
          onChange={setToggle('notifRecordatorios')}
        />
        <ToggleField
          label="Alerta de stock crítico"
          hint="Muestra el badge de alerta en el menú de Faltantes."
          value={form.notifStockCritico}
          onChange={setToggle('notifStockCritico')}
        />
        <ToggleField
          label="Confirmación de venta exitosa"
          hint="Muestra una notificación toast al registrar una venta."
          value={form.notifVentaExitosa}
          onChange={setToggle('notifVentaExitosa')}
        />
      </Section>

      {/* ── Recordatorios ── */}
      <Section titulo="📅 Recordatorios">
        <div className="settings-rec-resumen">
          <div className="settings-rec-stats">
            <span className="settings-rec-num">{recordatorios.length}</span>
            <span className="settings-rec-label">recordatorio{recordatorios.length !== 1 ? 's' : ''} guardado{recordatorios.length !== 1 ? 's' : ''}</span>
            <span className="settings-rec-activos">
              ({recordatorios.filter(r => r.activo).length} activo{recordatorios.filter(r => r.activo).length !== 1 ? 's' : ''})
            </span>
          </div>
          <button className="btn-settings-guardar" onClick={abrirDrawer} style={{ padding: '7px 16px' }}>
            Administrar
          </button>
        </div>

        {recordatorios.length > 0 && (
          <div className="settings-rec-lista">
            {recordatorios.slice(0, 3).map(r => (
              <div key={r.id} className={`settings-rec-item${!r.activo ? ' inactivo' : ''}`}>
                <span className="settings-rec-item-titulo">{r.titulo}</span>
                <span className="settings-rec-item-tipo">{descripcionRec(r)}</span>
              </div>
            ))}
            {recordatorios.length > 3 && (
              <p className="settings-rec-mas" onClick={abrirDrawer}>
                +{recordatorios.length - 3} más → ver todos
              </p>
            )}
          </div>
        )}
      </Section>

      {/* ── Apariencia ── */}
      <Section titulo="🎨 Apariencia">
        <ToggleField
          label={darkMode ? '🌙 Modo oscuro activo' : '☀️ Modo claro activo'}
          value={darkMode}
          onChange={toggle}
        />
      </Section>

      {/* ── Acerca de ── */}
      <Section titulo="ℹ️ Acerca de">
        <div className="settings-about">
          <p className="settings-about-nombre">PapeAmistad POS</p>
          <p className="settings-about-version">Versión 1.0</p>
        </div>
      </Section>
    </div>
  );
};

export default Settings;
