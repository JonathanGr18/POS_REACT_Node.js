import React, { useState, useMemo, useRef, useEffect, useCallback } from 'react';
import useDebounce from '../../hooks/useDebounce';
import { IMAGE_BASE_URL } from '../../services/api';
import './ProducListVen.css';

const ProductoListVenta = ({ productos = [], onSelect, itemsEnCarrito = [] }) => {
  const [searchTerm, setSearchTerm] = useState('');
  const searchTermDebounced = useDebounce(searchTerm, 400);
  const [orden, setOrden] = useState('nombre');
  const [selIndex, setSelIndex] = useState(0);
  const gridRef = useRef(null);
  const [numCols, setNumCols] = useState(1);

  // Calcular número de columnas reales del grid con ResizeObserver
  useEffect(() => {
    const el = gridRef.current;
    if (!el) return;
    const update = () => {
      const cols = window.getComputedStyle(el)
        .getPropertyValue('grid-template-columns')
        .split(' ').length;
      setNumCols(cols || 1);
    };
    update();
    const ro = new ResizeObserver(update);
    ro.observe(el);
    return () => ro.disconnect();
  }, []);

  const productosFiltrados = useMemo(() => {
    const valor = searchTermDebounced.trim().toLowerCase();
    const esNumero = valor !== '' && !isNaN(Number(valor));

    const filtrados = productos
      .filter(p => p.stock > 0)
      .filter(p => {
        if (!valor) return true;
        if (esNumero) {
          return Number(p.codigo) === Number(valor) || p.codigo.toString().startsWith(valor);
        }
        return (
          p.nombre.toLowerCase().includes(valor) ||
          p.descripcion?.toLowerCase().includes(valor)
        );
      });

    return [...filtrados].sort((a, b) => {
      if (orden === 'nombre')      return a.nombre.localeCompare(b.nombre);
      if (orden === 'precio_asc')  return Number(a.precio) - Number(b.precio);
      if (orden === 'precio_desc') return Number(b.precio) - Number(a.precio);
      return 0;
    });
  }, [productos, searchTermDebounced, orden]);

  // Resetear selección al cambiar búsqueda
  useEffect(() => { setSelIndex(0); }, [searchTermDebounced]);

  // Mover selección clampeada al rango válido
  const mover = useCallback((delta) => {
    setSelIndex(i => Math.max(0, Math.min(i + delta, productosFiltrados.length - 1)));
  }, [productosFiltrados.length]);

  const handleKeyDown = (e) => {
    const total = productosFiltrados.length;
    if (total === 0) return;

    if (e.key === 'ArrowRight') {
      e.preventDefault();
      mover(+1);
    } else if (e.key === 'ArrowLeft') {
      e.preventDefault();
      mover(-1);
    } else if (e.key === 'ArrowDown') {
      e.preventDefault();
      mover(+numCols);
    } else if (e.key === 'ArrowUp') {
      e.preventDefault();
      mover(-numCols);
    } else if (e.key === 'Enter') {
      const target = productosFiltrados[selIndex] || productosFiltrados[0];
      if (target && target.stock > 0) {
        onSelect?.(target);
        setSearchTerm('');
        setSelIndex(0);
      }
    }
  };

  const cantidadEnCarrito = (id) => {
    const item = itemsEnCarrito.find(i => i.id === id);
    return item ? item.cantidad : 0;
  };

  return (
    <div className="producto-list-venta">
      <div className="plv-filtros">
        <input
          className="plv-busqueda"
          type="text"
          placeholder="🔍 Buscar y Enter para agregar..."
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
          onKeyDown={handleKeyDown}
        />
        <select className="plv-orden" value={orden} onChange={(e) => setOrden(e.target.value)}>
          <option value="nombre">A–Z</option>
          <option value="precio_asc">Precio ↑</option>
          <option value="precio_desc">Precio ↓</option>
        </select>
      </div>

      <div className="plv-grid" ref={gridRef}>
        {productosFiltrados.length > 0 ? (
          productosFiltrados.map((producto, idx) => {
            const qty = cantidadEnCarrito(producto.id);
            const agotado = producto.stock <= 0 || qty >= producto.stock;
            const activo = idx === selIndex;
            return (
              <div
                key={producto.id}
                className={`plv-card${agotado ? ' plv-card--agotado' : ''}${activo ? ' plv-card--activo' : ''}`}
                onClick={() => { setSelIndex(idx); !agotado && onSelect?.(producto); }}
              >
                {qty > 0 && <span className="plv-qty-badge">{qty}</span>}
                {producto.imagen_url
                  ? <img src={`${IMAGE_BASE_URL}${producto.imagen_url}`} alt={producto.nombre} className="plv-card-img" />
                  : <div className="plv-card-img-placeholder">📦</div>
                }
                <p className="plv-nombre">{producto.nombre}</p>
                <p className="plv-precio">${Number(producto.precio).toFixed(2)}</p>
                <p className={`plv-stock plv-stock--${producto.stock < 15 ? 'bajo' : 'ok'}`}>
                  Stock: {producto.stock}
                </p>
              </div>
            );
          })
        ) : (
          <p className="plv-empty">No se encontraron productos</p>
        )}
      </div>
    </div>
  );
};

export default ProductoListVenta;
