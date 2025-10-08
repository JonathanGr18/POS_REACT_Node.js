// components/ResurtirForm.js
import React, { useState } from 'react';
import InputBusqueda from '../ui/InputBusqueda';
import api from '../../services/api';

const ResurtirProductoForm = ({ productos = [], onResurtir }) => {
  const [busqueda, setBusqueda] = useState('');
  const [cantidad, setCantidad] = useState('');
  const [productoSeleccionado, setProductoSeleccionado] = useState(null);

  const handleBuscar = (e) => {
    setBusqueda(e.target.value);
    const resultado = productos.find(p =>
      p.codigo.toLowerCase() === e.target.value.toLowerCase() ||
      p.nombre.toLowerCase() === e.target.value.toLowerCase()
    );
    setProductoSeleccionado(resultado || null);
  };

  const handleSubmit = async (e) => {
    e.preventDefault();

    if (!productoSeleccionado) {
      alert('Selecciona un producto válido');
      return;
    }

    if (cantidad <= 0) {
      alert('La cantidad debe ser mayor a cero');
      return;
    }

    try {
      await api.put(`/productos/resurtir/${productoSeleccionado.id}`, {
        cantidad: parseInt(cantidad)
      });

      alert('Producto resurtido correctamente');

      // Limpia y actualiza
      onResurtir(); // Actualiza lista de productos
      setBusqueda('');
      setCantidad('');
      setProductoSeleccionado(null);

    } catch (err) {
      console.error('Error al resurtir producto:', err);
      alert('Error al resurtir producto');
    }
  };


  const sugerencias = productos.filter(p =>
    p.nombre.toLowerCase().includes(busqueda.toLowerCase()) ||
    p.codigo.toLowerCase().includes(busqueda.toLowerCase())
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

        <button type="submit" className="btn btn-success">✔️ Resurtir</button>
      </form>
    </div>
  );
};

export default ResurtirProductoForm;
