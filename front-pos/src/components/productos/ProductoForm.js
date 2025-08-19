import './ProductoForm.css';
import React, { useState, useEffect } from 'react';
import { FaPlus, FaSave } from 'react-icons/fa';

const ProductoForm = ({ onSubmit, productoSeleccionado, productos = [] }) => {
  const [form, setForm] = useState({ nombre: '', precio: '', descripcion: '', codigo: '', stock: '' });
  const [modoEdicion, setModoEdicion] = useState(false);

  useEffect(() => {
    if (productoSeleccionado) {
      setForm(productoSeleccionado);
      setModoEdicion(true);
    } else {
      // Generar nuevo código automático basado en el número de productos existentes
      const codigosExistentes = productos.map(p => parseInt(p.codigo)).filter(c => !isNaN(c));
      let nuevoCodigo = 1;
      while (codigosExistentes.includes(nuevoCodigo)) {
        nuevoCodigo++;
      }
      setForm({ nombre: '', precio: '', descripcion: '', codigo: nuevoCodigo.toString(), stock: '' });
      setModoEdicion(false);
    }
  }, [productoSeleccionado, productos]);

  const handleChange = (e) => {
    setForm({ ...form, [e.target.name]: e.target.value });
  };

  const handleSubmit = (e) => {
    e.preventDefault();

    const existeCodigo = productos.some(
      (p) =>
        p.codigo.toLowerCase() === form.codigo.toLowerCase() &&
        p.id !== form.id
    );

    if (existeCodigo) {
      alert('Ya existe un producto con ese código.');
      return;
    }

    const formData = {
      ...form,
      descripcion: form.descripcion.trim() === '' ? 'Sin descripcion' : form.descripcion,
      precio: parseFloat(form.precio),
      stock: parseInt(form.stock),
    };

    onSubmit(formData);
    setForm({ nombre: '', precio: '', descripcion: '', codigo: '', stock: '' });
  };

  return (
    <form onSubmit={handleSubmit} className="form-container">
      <div className="form-grid">
        <div className="form-group">
          <input
            className="floating-input"
            name="codigo"
            value={form.codigo}
            onChange={handleChange}
            placeholder=" "
            required
            disabled={modoEdicion} // deshabilita el código al editar
          />
          <label className="floating-label">Código</label>
        </div>

        <div className="form-group">
          <input
            className="floating-input"
            name="nombre"
            value={form.nombre}
            onChange={handleChange}
            placeholder=" "
            required
          />
          <label className="floating-label">Nombre</label>
        </div>

        <div className="form-group">
          <input
            className="floating-input"
            name="precio"
            value={form.precio}
            onChange={handleChange}
            placeholder=" "
            type="number"
            min="0"
            step="0.01"
            required
          />
          <label className="floating-label">Precio</label>
        </div>

        <div className="form-group">
          <input
            className="floating-input"
            name="stock"
            value={form.stock}
            onChange={handleChange}
            placeholder=" "
            type="number"
            min="0"
            required
          />
          <label className="floating-label">Cantidad</label>
        </div>

        <div className="form-group descripcion-full">
          <textarea
            className="floating-input"
            name="descripcion"
            value={form.descripcion}
            onChange={handleChange}
            placeholder=" "
            rows={3}
          />
          <label className="floating-label">Descripción</label>
        </div>
      </div>

      <button className="btn-formulario" type="submit">
        {modoEdicion ? <FaSave /> : <FaPlus />}
        {modoEdicion ? 'Actualizar' : 'Agregar'}
      </button>
    </form>
  );
};

export default ProductoForm;
