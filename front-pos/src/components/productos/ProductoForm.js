import './ProductoForm.css';
import React, { useState, useEffect } from 'react';
import { FaPlus, FaSave } from 'react-icons/fa';
import { useToast } from '../ui/Toast';

const ProductoForm = ({ onSubmit, productoSeleccionado, productos = [] }) => {
  const { addToast } = useToast();
  const [form, setForm] = useState({ nombre: '', precio: '', descripcion: '', codigo: '', stock: '', status: true });
  const [modoEdicion, setModoEdicion] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);

  useEffect(() => {
    if (productoSeleccionado) {
      setForm(productoSeleccionado);
      setModoEdicion(true);
    } else {
      const codigosExistentes = productos.map(p => parseInt(p.codigo)).filter(c => !isNaN(c));
      let nuevoCodigo = 1;
      while (codigosExistentes.includes(nuevoCodigo)) {
        nuevoCodigo++;
      }
      setForm({ nombre: '', precio: '', descripcion: '', codigo: nuevoCodigo.toString(), stock: '', status: true });
      setModoEdicion(false);
    }
  }, [productoSeleccionado, productos]);

  const handleChange = (e) => {
    setForm({ ...form, [e.target.name]: e.target.value });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();

    const existeCodigo = productos.some(
      (p) =>
        p.codigo != null &&
        p.codigo.toString().toLowerCase() === form.codigo.toString().toLowerCase() &&
        p.id !== form.id
    );

    if (existeCodigo) {
      addToast('Ya existe un producto con ese código.', 'aviso');
      return;
    }

    if (form.precio === '' || isNaN(parseFloat(form.precio)) || parseFloat(form.precio) < 0) {
      addToast('El precio debe ser un número mayor o igual a cero', 'aviso');
      return;
    }

    if (form.stock === '' || isNaN(parseInt(form.stock)) || parseInt(form.stock) < 0) {
      addToast('El stock debe ser un número mayor o igual a cero', 'aviso');
      return;
    }

    const formData = {
      ...form,
      descripcion: form.descripcion.trim() === '' ? 'Sin descripcion' : form.descripcion,
      precio: parseFloat(form.precio),
      stock: parseInt(form.stock),
    };

    setIsSubmitting(true);
    try {
      await onSubmit(formData);
    } catch {
      // El error ya es manejado por el padre (crearOActualizar)
    } finally {
      setIsSubmitting(false);
    }
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
            disabled={modoEdicion}
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
            max="99999999.99"
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

      <button className="btn-formulario" type="submit" disabled={isSubmitting}>
        {modoEdicion ? <FaSave /> : <FaPlus />}
        {isSubmitting ? 'Procesando...' : (modoEdicion ? 'Actualizar' : 'Agregar')}
      </button>
    </form>
  );
};

export default ProductoForm;
