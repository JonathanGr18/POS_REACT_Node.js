import React from 'react';
import { FaEdit, FaBoxOpen, FaBarcode } from 'react-icons/fa';
import { getImageThumb } from '../../services/api';
import './ProductoGrid.css';

const ProductoGrid = ({ productos, onEdit, onBarcode, onResurtir }) => {
  const getStatusClass = (stock, stock_minimo = 15) => {
    if (stock === 0) return 'grid-status--rojo';
    if (stock < stock_minimo) return 'grid-status--naranja';
    return 'grid-status--verde';
  };

  const getStatusText = (stock, stock_minimo = 15) => {
    if (stock === 0) return 'Sin existencia';
    if (stock < stock_minimo) return 'Por terminar';
    return 'Disponible';
  };

  const getMargen = (precio, precio_costo) => {
    if (!precio_costo || precio_costo <= 0) return null;
    return ((precio - precio_costo) / precio_costo * 100).toFixed(1);
  };

  if (!productos.length) {
    return <p className="grid-empty">No hay productos para mostrar</p>;
  }

  return (
    <div className="producto-grid">
      {productos.map(p => {
        const stockMin = p.stock_minimo > 0 ? p.stock_minimo : 15;
        const margen = getMargen(p.precio, p.precio_costo);
        return (
          <div key={p.id} className={`grid-card ${getStatusClass(p.stock, stockMin)}`}>
            <div className="grid-card-img-wrap">
              {p.imagen_url ? (
                <img src={getImageThumb(p.imagen_url)} alt={p.nombre} className="grid-card-img" loading="lazy" />
              ) : (
                <div className="grid-card-img-placeholder">📦</div>
              )}
              <span className="grid-card-categoria">{p.categoria || 'General'}</span>
            </div>

            <div className="grid-card-body">
              <h4 className="grid-card-nombre">{p.nombre}</h4>
              {p.descripcion && p.descripcion !== 'Sin descripcion' && (
                <p className="grid-card-desc">{p.descripcion}</p>
              )}
              {p.codigo && <span className="grid-card-codigo">#{p.codigo}</span>}

              <div className="grid-card-precios">
                <span className="grid-card-precio">${Number(p.precio).toFixed(2)}</span>
                {margen !== null && (
                  <span className={`grid-card-margen ${Number(margen) >= 0 ? 'margen-pos' : 'margen-neg'}`}>
                    {margen}%
                  </span>
                )}
              </div>

              <div className="grid-card-stock-row">
                <span className={`grid-card-status ${getStatusClass(p.stock, stockMin)}`}>
                  {getStatusText(p.stock, stockMin)}
                </span>
                <span className="grid-card-stock">{p.stock} uds</span>
              </div>
            </div>

            <div className="grid-card-actions">
              <button className="grid-btn grid-btn-edit" onClick={() => onEdit(p)} title="Editar">
                <FaEdit />
              </button>
              <button className="grid-btn grid-btn-resurtir" onClick={() => onResurtir?.(p.id, 1)} title="Resurtir +1">
                <FaBoxOpen />
              </button>
              <button className="grid-btn grid-btn-barcode" onClick={() => onBarcode?.(p)} title="Código de barras">
                <FaBarcode />
              </button>
            </div>
          </div>
        );
      })}
    </div>
  );
};

export default ProductoGrid;
