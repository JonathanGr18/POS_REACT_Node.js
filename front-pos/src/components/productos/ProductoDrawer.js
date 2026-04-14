import React, { useEffect } from 'react';
import { FaTimes } from 'react-icons/fa';
import ProductoForm from './ProductoForm';
import './ProductoDrawer.css';

const ProductoDrawer = ({ visible, onCerrar, productos, categorias, onSubmit, productoSeleccionado }) => {
  // Cerrar con Escape + bloquear scroll del body
  useEffect(() => {
    if (!visible) return;
    const onKey = (e) => { if (e.key === 'Escape') onCerrar(); };
    window.addEventListener('keydown', onKey);
    const prevOverflow = document.body.style.overflow;
    document.body.style.overflow = 'hidden';
    return () => {
      window.removeEventListener('keydown', onKey);
      document.body.style.overflow = prevOverflow;
    };
  }, [visible, onCerrar]);

  if (!visible) return null;

  return (
    <>
      <div className="drawer-overlay" onClick={onCerrar} aria-hidden="true" />
      <div
        className="drawer-panel"
        role="dialog"
        aria-modal="true"
        aria-labelledby="drawer-title"
      >
        <div className="drawer-header">
          <h2 id="drawer-title">{productoSeleccionado ? 'Editar Producto' : 'Nuevo Producto'}</h2>
          <button className="drawer-close" onClick={onCerrar} aria-label="Cerrar"><FaTimes /></button>
        </div>
        <div className="drawer-body">
          <ProductoForm
            productos={productos}
            categorias={categorias}
            onSubmit={(data) => { onSubmit(data); onCerrar(); }}
            productoSeleccionado={productoSeleccionado}
          />
        </div>
      </div>
    </>
  );
};

export default ProductoDrawer;
