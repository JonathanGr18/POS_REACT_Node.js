import React, { useState, useMemo, useRef, useEffect, useCallback } from 'react';
import useDebounce from '../../hooks/useDebounce';
import { IMAGE_BASE_URL } from '../../services/api';
import './ProducListVen.css';

const ProductoListVenta = ({ productos = [], onSelect, itemsEnCarrito = [], categorias = [] }) => {
  const [searchTerm, setSearchTerm] = useState('');
  const searchTermDebounced = useDebounce(searchTerm, 400);
  const [orden, setOrden] = useState('nombre');
  const [categoriaFiltro, setCategoriaFiltro] = useState('todas');
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

  // Mapa de cantidades en carrito para calcular stock visual
  const carritoMap = useMemo(() => {
    const map = {};
    itemsEnCarrito.forEach(i => { map[i.id] = i.cantidad; });
    return map;
  }, [itemsEnCarrito]);

  const productosFiltrados = useMemo(() => {
    const valor = searchTermDebounced.trim().toLowerCase();
    const esNumero = valor !== '' && !isNaN(Number(valor));

    const filtrados = productos
      .filter(p => Number(p.stock) > 0)
      .filter(p => {
        if (categoriaFiltro !== 'todas' && (p.categoria || 'General') !== categoriaFiltro) return false;
        if (!valor) return true;
        const codigoStr = String(p.codigo ?? '');
        if (esNumero) {
          return Number(p.codigo) === Number(valor) || codigoStr.startsWith(valor);
        }
        return (
          (p.nombre || '').toLowerCase().includes(valor) ||
          (p.descripcion || '').toLowerCase().includes(valor)
        );
      });

    return [...filtrados].sort((a, b) => {
      if (orden === 'nombre')      return (a.nombre || '').localeCompare(b.nombre || '');
      if (orden === 'precio_asc')  return Number(a.precio) - Number(b.precio);
      if (orden === 'precio_desc') return Number(b.precio) - Number(a.precio);
      return 0;
    });
  }, [productos, searchTermDebounced, orden, categoriaFiltro]);

  // Resetear selección al cambiar búsqueda
  useEffect(() => { setSelIndex(0); }, [searchTermDebounced]);

  // Mover selección clampeada al rango válido
  const mover = useCallback((delta) => {
    setSelIndex(i => Math.max(0, Math.min(i + delta, productosFiltrados.length - 1)));
  }, [productosFiltrados.length]);

  const handleKeyDown = (e) => {
    // Escape: limpiar búsqueda y quitar focus
    if (e.key === 'Escape') {
      e.preventDefault();
      setSearchTerm('');
      setSelIndex(0);
      e.target.blur();
      return;
    }

    // Enter: bypass debounce (importante para lectores de código de barras)
    if (e.key === 'Enter') {
      const valor = searchTerm.trim().toLowerCase();
      // Busqueda inmediata sin esperar debounce
      if (valor) {
        const esNum = !isNaN(Number(valor));
        // Match exacto por codigo primero (scanner)
        let match = productos.find(p =>
          Number(p.stock) > 0 && String(p.codigo ?? '').toLowerCase() === valor
        );
        if (!match && esNum) {
          match = productos.find(p => Number(p.stock) > 0 && Number(p.codigo) === Number(valor));
        }
        // Si no hay exacto, usar el seleccionado del filtrado actual
        if (!match) {
          match = productosFiltrados[selIndex] || productosFiltrados[0];
        }
        if (match) {
          const stockDisponible = Number(match.stock) - (carritoMap[match.id] || 0);
          if (stockDisponible > 0) {
            onSelect?.(match);
            setSearchTerm('');
            setSelIndex(0);
          }
        }
      }
      return;
    }

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
    }
  };

  return (
    <div className="producto-list-venta">
      <div className="plv-filtros">
        <input
          className="plv-busqueda"
          type="text"
          placeholder="🔍 Buscar y Enter para agregar... (F2)"
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
          onKeyDown={handleKeyDown}
          id="plv-busqueda-input"
        />
        <select className="plv-orden" value={orden} onChange={(e) => setOrden(e.target.value)}>
          <option value="nombre">A–Z</option>
          <option value="precio_asc">Precio ↑</option>
          <option value="precio_desc">Precio ↓</option>
        </select>
      </div>

      {categorias.length > 0 && (
        <div className="plv-categorias">
          <button
            className={`plv-cat-btn${categoriaFiltro === 'todas' ? ' plv-cat-btn--activo' : ''}`}
            onClick={() => setCategoriaFiltro('todas')}
          >Todas</button>
          {categorias.map(cat => (
            <button
              key={cat}
              className={`plv-cat-btn${categoriaFiltro === cat ? ' plv-cat-btn--activo' : ''}`}
              onClick={() => setCategoriaFiltro(cat)}
            >{cat}</button>
          ))}
        </div>
      )}

      <div className="plv-grid" ref={gridRef}>
        {productosFiltrados.length > 0 ? (
          productosFiltrados.map((producto, idx) => {
            const qty = carritoMap[producto.id] || 0;
            const stockVisual = producto.stock - qty;
            const agotado = stockVisual <= 0;
            const activo = idx === selIndex;
            return (
              <div
                key={producto.id}
                className={`plv-card${agotado ? ' plv-card--agotado' : ''}${activo ? ' plv-card--activo' : ''}`}
                onClick={() => { setSelIndex(idx); !agotado && onSelect?.(producto); }}
              >
                {qty > 0 && <span className="plv-qty-badge">{qty}</span>}
                {producto.imagen_url
                  ? <img
                      src={`${IMAGE_BASE_URL}${producto.imagen_url}`}
                      alt=""
                      className="plv-card-img"
                      loading="lazy"
                      decoding="async"
                    />
                  : <div className="plv-card-img-placeholder" aria-hidden="true">📦</div>
                }
                <p className="plv-nombre">{producto.nombre}</p>
                <p className="plv-precio">${Number(producto.precio).toFixed(2)}</p>
                <p className={`plv-stock plv-stock--${stockVisual < 15 ? 'bajo' : 'ok'}`}>
                  Stock: {stockVisual}
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

export default React.memo(ProductoListVenta);
