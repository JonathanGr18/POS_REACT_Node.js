import React, { useState } from 'react';
import { useReminders } from '../../context/RemindersContext';
import './RecordatoriosDrawer.css';

const DIAS = ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb'];

const FORM_VACIO = {
  titulo: '',
  descripcion: '',
  tipo: 'diario',
  fecha: '',
  hora: '',
  diasSemana: [],
};

const FormRecordatorio = ({ inicial, onGuardar, onCancelar }) => {
  const [form, setForm] = useState(inicial || FORM_VACIO);

  const set = (key, val) => setForm(prev => ({ ...prev, [key]: val }));

  const toggleDia = (d) => {
    set('diasSemana', form.diasSemana.includes(d)
      ? form.diasSemana.filter(x => x !== d)
      : [...form.diasSemana, d]);
  };

  const handleGuardar = () => {
    if (!form.titulo.trim()) return;
    if (form.tipo === 'fecha' && !form.fecha) return;
    if (form.tipo === 'semanal' && form.diasSemana.length === 0) return;
    onGuardar(form);
  };

  return (
    <div className="rec-form">
      <input
        className="rec-input"
        placeholder="Título del recordatorio *"
        value={form.titulo}
        onChange={e => set('titulo', e.target.value)}
        autoFocus
      />
      <textarea
        className="rec-input rec-textarea"
        placeholder="Descripción (opcional)"
        value={form.descripcion}
        onChange={e => set('descripcion', e.target.value)}
        rows={2}
      />

      <div className="rec-tipo-row">
        {[
          { v: 'diario',   l: '📅 Diario'   },
          { v: 'semanal',  l: '📆 Semanal'  },
          { v: 'fecha',    l: '📌 Fecha fija' },
        ].map(t => (
          <button
            key={t.v}
            type="button"
            className={`rec-tipo-btn${form.tipo === t.v ? ' activo' : ''}`}
            onClick={() => set('tipo', t.v)}
          >{t.l}</button>
        ))}
      </div>

      {form.tipo === 'fecha' && (
        <input
          type="date"
          className="rec-input"
          value={form.fecha}
          onChange={e => set('fecha', e.target.value)}
          min={new Date().toISOString().slice(0, 10)}
        />
      )}

      {form.tipo === 'semanal' && (
        <div className="rec-dias">
          {DIAS.map((d, i) => (
            <button
              key={i}
              type="button"
              className={`rec-dia-btn${form.diasSemana.includes(i) ? ' activo' : ''}`}
              onClick={() => toggleDia(i)}
            >{d}</button>
          ))}
        </div>
      )}

      <input
        type="time"
        className="rec-input"
        value={form.hora}
        onChange={e => set('hora', e.target.value)}
        placeholder="Hora (opcional)"
      />

      <div className="rec-form-actions">
        <button type="button" className="rec-btn-secundario" onClick={onCancelar}>Cancelar</button>
        <button type="button" className="rec-btn-primario" onClick={handleGuardar}>
          {inicial ? 'Actualizar' : 'Agregar'}
        </button>
      </div>
    </div>
  );
};

const RecordatoriosDrawer = () => {
  const { recordatorios, agregar, actualizar, eliminar, cerrarDrawer } = useReminders();
  const [mostrando, setMostrando] = useState('lista'); // 'lista' | 'nuevo' | id (editar)

  const handleGuardarNuevo = (datos) => {
    agregar(datos);
    setMostrando('lista');
  };

  const handleGuardarEdicion = (id, datos) => {
    actualizar(id, datos);
    setMostrando('lista');
  };

  const descripcionTipo = (r) => {
    if (r.tipo === 'diario') return `Diario${r.hora ? ` · ${r.hora}` : ''}`;
    if (r.tipo === 'semanal') {
      const dias = (r.diasSemana || []).map(d => DIAS[d]).join(', ');
      return `${dias}${r.hora ? ` · ${r.hora}` : ''}`;
    }
    if (r.tipo === 'fecha') return `${r.fecha}${r.hora ? ` · ${r.hora}` : ''}`;
    return '';
  };

  return (
    <div className="rec-overlay" onClick={cerrarDrawer}>
      <div className="rec-drawer" onClick={e => e.stopPropagation()}>

        <div className="rec-drawer-header">
          <h3 className="rec-drawer-titulo">🔔 Recordatorios</h3>
          <button className="rec-cerrar" onClick={cerrarDrawer}>✕</button>
        </div>

        {mostrando === 'lista' && (
          <>
            <button
              className="rec-btn-nuevo"
              onClick={() => setMostrando('nuevo')}
            >+ Nuevo recordatorio</button>

            <div className="rec-lista">
              {recordatorios.length === 0 ? (
                <p className="rec-empty">Sin recordatorios. ¡Crea uno!</p>
              ) : (
                recordatorios.map(r => (
                  <div key={r.id} className={`rec-item${!r.activo ? ' rec-item--inactivo' : ''}`}>
                    <div className="rec-item-info">
                      <p className="rec-item-titulo">{r.titulo}</p>
                      {r.descripcion && <p className="rec-item-desc">{r.descripcion}</p>}
                      <p className="rec-item-tipo">{descripcionTipo(r)}</p>
                    </div>
                    <div className="rec-item-actions">
                      <button
                        className={`rec-toggle${r.activo ? ' activo' : ''}`}
                        onClick={() => actualizar(r.id, { activo: !r.activo })}
                        title={r.activo ? 'Desactivar' : 'Activar'}
                      >
                        <span className="rec-toggle-knob" />
                      </button>
                      <button
                        className="rec-item-btn"
                        onClick={() => setMostrando(r.id)}
                        title="Editar"
                      >✏️</button>
                      <button
                        className="rec-item-btn rec-item-btn--del"
                        onClick={() => eliminar(r.id)}
                        title="Eliminar"
                      >🗑️</button>
                    </div>
                  </div>
                ))
              )}
            </div>
          </>
        )}

        {mostrando === 'nuevo' && (
          <FormRecordatorio
            onGuardar={handleGuardarNuevo}
            onCancelar={() => setMostrando('lista')}
          />
        )}

        {mostrando !== 'lista' && mostrando !== 'nuevo' && (() => {
          const r = recordatorios.find(x => x.id === mostrando);
          if (!r) return null;
          return (
            <FormRecordatorio
              inicial={r}
              onGuardar={(datos) => handleGuardarEdicion(r.id, datos)}
              onCancelar={() => setMostrando('lista')}
            />
          );
        })()}

      </div>
    </div>
  );
};

export default RecordatoriosDrawer;
