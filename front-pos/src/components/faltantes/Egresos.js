import React, { useState } from 'react';
import api from '../../services/api';
import { useToast } from '../ui/Toast';

const AgregarEgresoForm = () => {
  const { addToast } = useToast();
  const [monto, setMonto] = useState('');
  const [concepto, setConcepto] = useState('');
  const [cargando, setCargando] = useState(false);

  const handleSubmit = async (e) => {
    e.preventDefault();

    if (!monto || isNaN(monto) || parseFloat(monto) <= 0) {
      addToast('Ingresa un monto válido mayor a cero', 'aviso');
      return;
    }

    setCargando(true);
    try {
      await api.post('/productos/egresos', { monto, concepto: concepto.trim() || null });
      addToast('Egreso registrado correctamente', 'exito');
      setMonto('');
      setConcepto('');
    } catch (err) {
      console.error('Error al registrar egreso:', err);
      addToast('Error al registrar egreso', 'error');
    } finally {
      setCargando(false);
    }
  };

  return (
    <div className="form-section">
      <h2>Registrar Egreso</h2>
      <form onSubmit={handleSubmit} className="formulario-producto">
        <input
          type="number"
          placeholder="Monto del egreso"
          className="input"
          value={monto}
          onChange={e => setMonto(e.target.value)}
        />
        <input
          type="text"
          placeholder="Concepto (ej: renta, proveedor...)"
          className="input"
          value={concepto}
          onChange={e => setConcepto(e.target.value)}
          maxLength={200}
        />
        <button type="submit" className="btn btn-danger" disabled={cargando}>
          {cargando ? 'Registrando...' : '➖ Registrar Egreso'}
        </button>
      </form>
    </div>
  );
};

export default AgregarEgresoForm;
