import React, { useState } from 'react';
import InputBusqueda from '../ui/InputBusqueda';
import api from '../../services/api';
import { useToast } from '../ui/Toast';

const ResurtirProductoForm = ({ productos = [], onResurtir }) => {
  const { addToast } = useToast();
  const [busqueda, setBusqueda] = useState('');
  const [cantidad, setCantidad] = useState('');
  const [productoSeleccionado, setProductoSeleccionado] = useState(null);
  const [cargando, setCargando] = useState(false);

  const handleBuscar = (e) => {
    setBusqueda(e.target.value);
    const valor = e.target.value.toLowerCase();
    // Primero busca coincidencia exacta; si no hay, limpia la selección
    // (la selección final se hace siempre mediante onSeleccionar en el dropdown)
    const exacto = productos.find(p =>
      p?.codigo?.toString().toLowerCase() === valor ||
      p?.nombre?.toLowerCase() === valor
    );
    setProductoSeleccionado(exacto || null);
  };

  const handleSubmit = async (e) => {
    e.preventDefault();

    if (!productoSeleccionado) {
      addToast('Selecciona un producto válido', 'aviso');
      return;
    }

    if (!cantidad || parseInt(cantidad) <= 0) {
      addToast('La cantidad debe ser mayor a cero', 'aviso');
      return;
    }

    setCargando(true);
    try {
      await api.put(`/productos/resurtir/${productoSeleccionado.id}`, {
        cantidad: parseInt(cantidad)
      });

      addToast(`"${productoSeleccionado.nombre}" resurtido correctamente (+${cantidad})`, 'exito');
      onResurtir();
    } catch (err) {
      console.error('Error al resurtir producto:', err);
      addToast('Error al resurtir producto', 'error');
    } finally {
      setCargando(false);
      setBusqueda('');
      setCantidad('');
      setProductoSeleccionado(null);
    }
  };

  const sugerencias = productos.filter(p =>
    p?.nombre?.toLowerCase().includes(busqueda.toLowerCase()) ||
    (p?.codigo || '').toString().toLowerCase().includes(busqueda.toLowerCase())
  ).slice(0, 5);

  return (
    <div className="form-section">
      <h2>Resurtir Producto</h2>
      <form onSubmit={handleSubmit} className="formulario-producto">
        <InputBusqueda
          value={busqueda}
          onChange={handleBuscar}
          sugerencias={sugerencias}
          onSeleccionar={(p) => {
            setBusqueda(`${p.codigo} - ${p.nombre}`);
            setProductoSeleccionado(p);
          }}
        />

        <input
          type="number"
          placeholder="Cantidad a agregar"
          className="input"
          value={cantidad}
          onChange={e => setCantidad(e.target.value)}
          min="1"
        />

        <button type="submit" className="btn btn-success" disabled={cargando}>
          {cargando ? 'Resurtiendo...' : '✔️ Resurtir'}
        </button>
      </form>
    </div>
  );
};

export default ResurtirProductoForm;
