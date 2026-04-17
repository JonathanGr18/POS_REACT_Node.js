import React, { useEffect, useState } from 'react';
import { FaTimes } from 'react-icons/fa';
import api from '../../services/api';
import { useToast } from '../ui/Toast';
import '../productos/ProductoDrawer.css';

const hoyISO = () => {
  const d = new Date();
  const offset = d.getTimezoneOffset();
  const local = new Date(d.getTime() - offset * 60000);
  return local.toISOString().slice(0, 10);
};

const EgresoDrawer = ({ visible, onCerrar, onRegistrado }) => {
  const { addToast } = useToast();
  const [monto, setMonto] = useState('');
  const [concepto, setConcepto] = useState('');
  const [fecha, setFecha] = useState(hoyISO());
  const [cargando, setCargando] = useState(false);

  useEffect(() => {
    if (!visible) return;
    const onKey = (e) => { if (e.key === 'Escape') onCerrar(); };
    window.addEventListener('keydown', onKey);
    const prev = document.body.style.overflow;
    document.body.style.overflow = 'hidden';
    return () => {
      window.removeEventListener('keydown', onKey);
      document.body.style.overflow = prev;
    };
  }, [visible, onCerrar]);

  useEffect(() => {
    if (visible) {
      setMonto('');
      setConcepto('');
      setFecha(hoyISO());
    }
  }, [visible]);

  const handleSubmit = async (e) => {
    e.preventDefault();
    const montoNum = parseFloat(monto);
    if (!monto || isNaN(montoNum) || montoNum <= 0) {
      addToast('Ingresa un monto válido mayor a cero', 'aviso');
      return;
    }
    if (montoNum > 999999.99) {
      addToast('El monto es demasiado alto', 'aviso');
      return;
    }

    setCargando(true);
    try {
      await api.post('/egresos', {
        monto: montoNum,
        concepto: concepto.trim() || null,
        fecha: fecha || null,
      });
      addToast('Egreso registrado correctamente', 'exito');
      onRegistrado?.();
      onCerrar();
    } catch (err) {
      addToast(err?.response?.data?.error || 'Error al registrar egreso', 'error');
    } finally {
      setCargando(false);
    }
  };

  if (!visible) return null;

  return (
    <>
      <div className="drawer-overlay" onClick={onCerrar} aria-hidden="true" />
      <div
        className="drawer-panel"
        role="dialog"
        aria-modal="true"
        aria-labelledby="egreso-drawer-title"
      >
        <div className="drawer-header">
          <h2 id="egreso-drawer-title">Registrar Egreso</h2>
          <button className="drawer-close" onClick={onCerrar} aria-label="Cerrar"><FaTimes /></button>
        </div>
        <div className="drawer-body">
          <form onSubmit={handleSubmit} className="formulario-producto egreso-form">
            <div className="egreso-campo">
              <label htmlFor="egreso-monto">Monto</label>
              <input
                id="egreso-monto"
                type="number"
                className="input"
                placeholder="0.00"
                value={monto}
                onChange={e => setMonto(e.target.value)}
                min="0"
                step="0.01"
                autoFocus
              />
            </div>

            <div className="egreso-campo">
              <label htmlFor="egreso-fecha">Fecha</label>
              <input
                id="egreso-fecha"
                type="date"
                className="input"
                value={fecha}
                onChange={e => setFecha(e.target.value)}
                max={hoyISO()}
              />
            </div>

            <div className="egreso-campo">
              <label htmlFor="egreso-concepto">Concepto <span className="egreso-opcional">(opcional)</span></label>
              <input
                id="egreso-concepto"
                type="text"
                className="input"
                placeholder="Ej: renta, proveedor, servicios..."
                value={concepto}
                onChange={e => setConcepto(e.target.value)}
                maxLength={200}
              />
            </div>

            <button type="submit" className="btn btn-danger" disabled={cargando}>
              {cargando ? 'Registrando...' : '➖ Registrar Egreso'}
            </button>
          </form>
        </div>
      </div>
    </>
  );
};

export default EgresoDrawer;
