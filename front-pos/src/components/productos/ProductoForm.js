import './ProductoForm.css';
import React, { useState, useEffect } from 'react';
import { FaPlus, FaSave } from 'react-icons/fa';
import { useToast } from '../ui/Toast';

const ProductoForm = ({ onSubmit, productoSeleccionado, productos = [], categorias = [] }) => {
  const { addToast } = useToast();
  const [form, setForm] = useState({ nombre: '', precio: '', precio_costo: '', descripcion: '', codigo: '', stock: '', stock_minimo: '15', status: true, categoria: 'General' });
  const [modoEdicion, setModoEdicion] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [nuevaCategoria, setNuevaCategoria] = useState(false);

  useEffect(() => {
    if (productoSeleccionado) {
      setForm({
        id: productoSeleccionado.id,
        nombre: productoSeleccionado.nombre || '',
        precio: productoSeleccionado.precio ?? '',
        precio_costo: productoSeleccionado.precio_costo || '',
        descripcion: productoSeleccionado.descripcion || '',
        codigo: productoSeleccionado.codigo || '',
        stock: productoSeleccionado.stock ?? '',
        stock_minimo: productoSeleccionado.stock_minimo || '15',
        status: productoSeleccionado.status ?? true,
        categoria: productoSeleccionado.categoria || 'General',
      });
      setModoEdicion(true);
      setNuevaCategoria(false);
    } else {
      // Autogen codigo usando Set para O(n) en lugar de includes O(n^2)
      const codigosSet = new Set(productos.map(p => String(p.codigo)));
      let nuevoCodigo = 1;
      while (codigosSet.has(String(nuevoCodigo))) nuevoCodigo++;
      setForm({ nombre: '', precio: '', precio_costo: '', descripcion: '', codigo: nuevoCodigo.toString(), stock: '', stock_minimo: '15', status: true, categoria: 'General' });
      setModoEdicion(false);
      setNuevaCategoria(false);
    }
  // Solo reacciona al cambio de producto seleccionado (no al array productos completo)
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [productoSeleccionado?.id]);

  const handleChange = (e) => {
    const { name, value } = e.target;
    // Usar updater funcional para evitar stale closures con tipeo rapido
    setForm(prev => ({ ...prev, [name]: value }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();

    // Validar nombre no vacio despues de trim
    if (!form.nombre || !form.nombre.trim()) {
      addToast('El nombre es requerido', 'aviso');
      return;
    }
    if (!form.codigo || !form.codigo.toString().trim()) {
      addToast('El código es requerido', 'aviso');
      return;
    }

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

    // Warn si margen es negativo (precio_costo > precio)
    const pv = parseFloat(form.precio);
    const pc = parseFloat(form.precio_costo);
    if (!isNaN(pv) && !isNaN(pc) && pc > 0 && pc > pv) {
      // eslint-disable-next-line no-alert
      if (!window.confirm(`El precio de costo ($${pc.toFixed(2)}) es mayor al precio de venta ($${pv.toFixed(2)}). Se venderá con pérdida. ¿Continuar?`)) {
        return;
      }
    }

    if (form.precio === '' || isNaN(parseFloat(form.precio)) || parseFloat(form.precio) < 0) {
      addToast('El precio debe ser un número mayor o igual a cero', 'aviso');
      return;
    }

    if (form.stock === '' || isNaN(parseInt(form.stock)) || parseInt(form.stock) < 0) {
      addToast('El stock debe ser un número mayor o igual a cero', 'aviso');
      return;
    }

    if (form.precio_costo !== '' && (isNaN(parseFloat(form.precio_costo)) || parseFloat(form.precio_costo) < 0)) {
      addToast('El precio de costo debe ser un número mayor o igual a cero', 'aviso');
      return;
    }

    // Whitelist: solo campos permitidos (evita enviar campos no controlados al backend)
    const formData = {
      id: form.id,
      nombre: form.nombre.trim(),
      codigo: form.codigo.toString().trim(),
      descripcion: form.descripcion.trim() === '' ? 'Sin descripcion' : form.descripcion.trim(),
      precio: parseFloat(form.precio),
      precio_costo: parseFloat(form.precio_costo) || 0,
      stock: parseInt(form.stock),
      stock_minimo: parseInt(form.stock_minimo) || 15,
      status: form.status ?? true,
      categoria: form.categoria?.trim() || 'General',
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
            id="prod-codigo"
            className="floating-input"
            name="codigo"
            value={form.codigo}
            onChange={handleChange}
            placeholder=" "
            required
            disabled={modoEdicion}
          />
          <label htmlFor="prod-codigo" className="floating-label">Código</label>
        </div>

        <div className="form-group">
          <input
            id="prod-nombre"
            className="floating-input"
            name="nombre"
            value={form.nombre}
            onChange={handleChange}
            placeholder=" "
            required
          />
          <label htmlFor="prod-nombre" className="floating-label">Nombre</label>
        </div>

        <div className="form-group">
          <input
            id="prod-precio"
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
          <label htmlFor="prod-precio" className="floating-label">Precio</label>
        </div>

        <div className="form-group">
          <input
            id="prod-precio-costo"
            className="floating-input"
            name="precio_costo"
            value={form.precio_costo}
            onChange={handleChange}
            placeholder=" "
            type="number"
            min="0"
            max="99999999.99"
            step="0.01"
          />
          <label htmlFor="prod-precio-costo" className="floating-label">Precio Costo</label>
        </div>

        <div className="form-group">
          <input
            id="prod-stock"
            className="floating-input"
            name="stock"
            value={form.stock}
            onChange={handleChange}
            placeholder=" "
            type="number"
            min="0"
            required
          />
          <label htmlFor="prod-stock" className="floating-label">Cantidad</label>
        </div>

        <div className="form-group">
          <input
            id="prod-stock-min"
            className="floating-input"
            name="stock_minimo"
            value={form.stock_minimo}
            onChange={handleChange}
            placeholder=" "
            type="number"
            min="1"
          />
          <label htmlFor="prod-stock-min" className="floating-label">Stock Mínimo</label>
        </div>

        <div className="form-group">
          {nuevaCategoria ? (
            <>
              <input
                className="floating-input"
                name="categoria"
                value={form.categoria}
                onChange={handleChange}
                placeholder=" "
              />
              <label className="floating-label">Nueva Categoría</label>
              <button type="button" className="btn-cat-toggle" onClick={() => setNuevaCategoria(false)}>
                Existente
              </button>
            </>
          ) : (
            <>
              <select
                className="floating-input"
                name="categoria"
                value={form.categoria}
                onChange={handleChange}
              >
                <option value="General">General</option>
                {categorias.filter(c => c !== 'General').map(cat => (
                  <option key={cat} value={cat}>{cat}</option>
                ))}
              </select>
              <label className="floating-label floating-label--select">Categoría</label>
              <button type="button" className="btn-cat-toggle" onClick={() => { setNuevaCategoria(true); setForm(f => ({ ...f, categoria: '' })); }}>
                + Nueva
              </button>
            </>
          )}
        </div>

        <div className="form-group descripcion-full">
          <textarea
            id="prod-descripcion"
            className="floating-input"
            name="descripcion"
            value={form.descripcion}
            onChange={handleChange}
            placeholder=" "
            rows={3}
          />
          <label htmlFor="prod-descripcion" className="floating-label">Descripción</label>
        </div>

        {/* Margen de ganancia calculado */}
        {form.precio && form.precio_costo && parseFloat(form.precio_costo) > 0 && (
          <div className="margen-info descripcion-full">
            <span className="margen-label">Margen de ganancia:</span>
            <span className={`margen-valor ${((parseFloat(form.precio) - parseFloat(form.precio_costo)) / parseFloat(form.precio_costo) * 100) < 0 ? 'margen-negativo' : 'margen-positivo'}`}>
              ${(parseFloat(form.precio) - parseFloat(form.precio_costo)).toFixed(2)} ({((parseFloat(form.precio) - parseFloat(form.precio_costo)) / parseFloat(form.precio_costo) * 100).toFixed(1)}%)
            </span>
          </div>
        )}
      </div>

      <button className="btn-formulario" type="submit" disabled={isSubmitting}>
        {modoEdicion ? <FaSave /> : <FaPlus />}
        {isSubmitting ? 'Procesando...' : (modoEdicion ? 'Actualizar' : 'Agregar')}
      </button>
    </form>
  );
};

export default ProductoForm;
