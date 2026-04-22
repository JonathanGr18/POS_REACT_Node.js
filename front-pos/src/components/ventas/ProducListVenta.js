import React, { useState, useMemo, useRef, useEffect, useCallback } from 'react';
import useDebounce from '../../hooks/useDebounce';
import { getImageThumb } from '../../services/api';
import './ProducListVen.css';

const POR_PAGINA = 30;

const ProductoListVenta = ({ productos = [], onSelect, itemsEnCarrito = [], categorias = [] }) => {
  const [searchTerm, setSearchTerm] = useState('');
  const searchTermDebounced = useDebounce(searchTerm, 400);
  const [orden, setOrden] = useState('nombre');
  const [categoriaFiltro, setCategoriaFiltro] = useState('todas');
  const [vistaLista, setVistaLista] = useState(false);
  const [buscarPor, setBuscarPor] = useState('todo'); // 'todo' | 'codigo' | 'nombre' | 'descripcion' | 'precio'
  const [selIndex, setSelIndex] = useState(0);
  const [pagina, setPagina] = useState(1);
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
    const tokens = valor.split(/\s+/).filter(Boolean);

    const filtrados = productos
      .filter(p => Number(p.stock) > 0)
      .filter(p => {
        if (categoriaFiltro !== 'todas' && (p.categoria || 'General') !== categoriaFiltro) return false;
        if (!valor) return true;
        const codigoStr = String(p.codigo ?? '').toLowerCase();
        const nombre = (p.nombre || '').toLowerCase();
        const desc = (p.descripcion || '').toLowerCase();
        const nombreDesc = `${nombre} ${desc}`;

        switch (buscarPor) {
          case 'codigo':
            return Number(p.codigo) === Number(valor) || codigoStr.startsWith(valor) || codigoStr.includes(valor);
          case 'nombre':
            return tokens.every(t => nombre.includes(t));
          case 'descripcion':
            return tokens.every(t => desc.includes(t));
          case 'precio':
            return String(Number(p.precio).toFixed(2)).includes(valor) || String(Number(p.precio)).startsWith(valor);
          default: // 'todo': busca cada palabra en nombre+descripción+código (permite "cartulina verde")
            if (esNumero && tokens.length === 1) {
              return Number(p.codigo) === Number(valor) || codigoStr.startsWith(valor);
            }
            const full = `${nombreDesc} ${codigoStr}`;
            return tokens.every(t => full.includes(t));
        }
      });

    // Cuando hay búsqueda, ranking: nombre primero > descripción después
    const score = (p) => {
      if (!tokens.length) return 0;
      const n = (p.nombre || '').toLowerCase();
      const d = (p.descripcion || '').toLowerCase();
      let s = 0;
      if (tokens[0] && n.startsWith(tokens[0])) s += 1000;
      tokens.forEach(t => {
        if (n.includes(t)) s += 100;
        if (d.includes(t)) s += 10;
      });
      return s;
    };

    return [...filtrados].sort((a, b) => {
      // Si hay búsqueda, el score domina (siempre prioriza nombre > desc)
      if (valor && buscarPor !== 'codigo' && buscarPor !== 'precio') {
        const sb = score(b) - score(a);
        if (sb !== 0) return sb;
      }
      if (orden === 'nombre')      return (a.nombre || '').localeCompare(b.nombre || '');
      if (orden === 'precio_asc')  return Number(a.precio) - Number(b.precio);
      if (orden === 'precio_desc') return Number(b.precio) - Number(a.precio);
      return 0;
    });
  }, [productos, searchTermDebounced, orden, categoriaFiltro, buscarPor]);

  // Paginación
  const totalPaginas = Math.max(1, Math.ceil(productosFiltrados.length / POR_PAGINA));
  const inicio = (pagina - 1) * POR_PAGINA;
  const paginados = productosFiltrados.slice(inicio, inicio + POR_PAGINA);

  // Resetear página y selección al cambiar búsqueda/filtros/orden
  useEffect(() => { setPagina(1); setSelIndex(0); }, [searchTermDebounced, categoriaFiltro, buscarPor, orden]);

  // Clampar página si cambia el total
  useEffect(() => {
    if (pagina > totalPaginas) setPagina(totalPaginas);
  }, [totalPaginas, pagina]);

  // Resetear selección al cambiar búsqueda
  useEffect(() => { setSelIndex(0); }, [searchTermDebounced]);

  // Mover selección clampeada al rango válido (dentro de la página actual)
  const mover = useCallback((delta) => {
    setSelIndex(i => Math.max(0, Math.min(i + delta, paginados.length - 1)));
  }, [paginados.length]);

  const handleKeyDown = (e) => {
    // Escape: limpiar búsqueda y quitar focus
    if (e.key === 'Escape') {
      e.preventDefault();
      setSearchTerm('');
      setSelIndex(0);
      e.target.blur();
      return;
    }

    // Ctrl+Enter → dejar pasar al handler global (cobrar)
    if (e.ctrlKey && e.key === 'Enter') {
      return; // No consumir, el global de VentaForm lo captura
    }

    // Enter solo (sin Ctrl): agregar producto seleccionado
    if (e.key === 'Enter') {
      const valor = searchTerm.trim().toLowerCase();
      if (valor) {
        // Usar el item seleccionado actualmente en la lista filtrada
        const match = paginados[selIndex] || paginados[0] || productosFiltrados[0];
        if (match) {
          const stockDisponible = Number(match.stock) - (carritoMap[match.id] || 0);
          if (stockDisponible > 0) {
            onSelect?.(match);
            // Si buscó por código exacto (scanner), limpiar input
            const fueScanner = buscarPor === 'codigo' ||
              String(match.codigo ?? '').toLowerCase() === valor;
            if (fueScanner) {
              setSearchTerm('');
              setSelIndex(0);
            }
          }
        }
      }
      return;
    }

    const total = paginados.length;
    if (total === 0) return;

    // En vista lista: flechas arriba/abajo mueven de 1 en 1
    // En vista grid: flechas mueven por columnas
    const step = vistaLista ? 1 : numCols;

    if (e.key === 'ArrowDown') {
      e.preventDefault();
      mover(+step);
      scrollToSelected(selIndex + step);
    } else if (e.key === 'ArrowUp') {
      e.preventDefault();
      mover(-step);
      scrollToSelected(selIndex - step);
    } else if (!vistaLista && e.key === 'ArrowRight') {
      e.preventDefault();
      mover(+1);
      scrollToSelected(selIndex + 1);
    } else if (!vistaLista && e.key === 'ArrowLeft') {
      e.preventDefault();
      mover(-1);
      scrollToSelected(selIndex - 1);
    }
  };

  // Auto-scroll al item seleccionado con flechas
  const scrollToSelected = (idx) => {
    const clamped = Math.max(0, Math.min(idx, paginados.length - 1));
    setTimeout(() => {
      const el = gridRef.current?.querySelector(`[data-idx="${clamped}"]`);
      if (el) el.scrollIntoView({ block: 'nearest', behavior: 'smooth' });
    }, 0);
  };

  return (
    <div className="producto-list-venta">
      <div className="plv-filtros">
        <input
          className="plv-busqueda"
          type="text"
          placeholder={buscarPor === 'codigo' ? '🔍 Buscar por código...' :
                       buscarPor === 'nombre' ? '🔍 Buscar por nombre...' :
                       buscarPor === 'descripcion' ? '🔍 Buscar por descripción...' :
                       buscarPor === 'precio' ? '🔍 Buscar por precio...' :
                       '🔍 Buscar producto... (F2)'}
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
          onKeyDown={handleKeyDown}
          id="plv-busqueda-input"
        />
        <select className="plv-buscar-por" value={buscarPor} onChange={(e) => setBuscarPor(e.target.value)} aria-label="Buscar por">
          <option value="todo">Todo</option>
          <option value="codigo">Código</option>
          <option value="nombre">Nombre</option>
          <option value="descripcion">Descripción</option>
          <option value="precio">Precio</option>
        </select>
        <select className="plv-orden" value={orden} onChange={(e) => setOrden(e.target.value)} aria-label="Ordenar por">
          <option value="nombre">A–Z</option>
          <option value="precio_asc">Precio ↑</option>
          <option value="precio_desc">Precio ↓</option>
        </select>
        <button
          className="plv-vista-toggle"
          onClick={() => setVistaLista(v => !v)}
          title={vistaLista ? 'Vista cuadrícula' : 'Vista lista'}
          aria-label={vistaLista ? 'Cambiar a vista cuadrícula' : 'Cambiar a vista lista'}
        >
          {vistaLista ? '▦' : '☰'}
        </button>
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

      {/* ── Vista GRID (cards) ── */}
      {!vistaLista && (
        <div className="plv-grid" ref={gridRef}>
          {paginados.length > 0 ? (
            paginados.map((producto, idx) => {
              const qty = carritoMap[producto.id] || 0;
              const stockVisual = producto.stock - qty;
              const agotado = stockVisual <= 0;
              const activo = idx === selIndex;
              return (
                <div
                  key={producto.id}
                  data-idx={idx}
                  className={`plv-card${agotado ? ' plv-card--agotado' : ''}${activo ? ' plv-card--activo' : ''}`}
                  onClick={() => { setSelIndex(idx); !agotado && onSelect?.(producto); }}
                >
                  {qty > 0 && <span className="plv-qty-badge">{qty}</span>}
                  {producto.imagen_url
                    ? <img src={getImageThumb(producto.imagen_url)} alt="" className="plv-card-img" loading="lazy" decoding="async" />
                    : <div className="plv-card-img-placeholder" aria-hidden="true">📦</div>
                  }
                  <p className="plv-nombre">{producto.nombre}</p>
                  {producto.descripcion && producto.descripcion !== 'Sin descripcion' && (
                    <p className="plv-desc">{producto.descripcion}</p>
                  )}
                  <p className="plv-precio">${Number(producto.precio).toFixed(2)}</p>
                  <p className="plv-codigo">#{producto.codigo}</p>
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
      )}

      {/* ── Vista LISTA (tabla) ── */}
      {vistaLista && (
        <div className="plv-tabla-wrap" ref={gridRef}>
          <table className="plv-tabla">
            <thead>
              <tr>
                <th>ID</th>
                <th></th>
                <th>Nombre</th>
                <th>Descripción</th>
                <th>Stock</th>
                <th>Precio</th>
              </tr>
            </thead>
            <tbody>
              {paginados.length > 0 ? (
                paginados.map((producto, idx) => {
                  const qty = carritoMap[producto.id] || 0;
                  const stockVisual = producto.stock - qty;
                  const agotado = stockVisual <= 0;
                  const activo = idx === selIndex;
                  return (
                    <tr
                      key={producto.id}
                      data-idx={idx}
                      className={`plv-fila${agotado ? ' plv-fila--agotado' : ''}${activo ? ' plv-fila--activo' : ''}`}
                      onClick={() => { setSelIndex(idx); !agotado && onSelect?.(producto); }}
                    >
                      <td className="plv-td-id">{producto.codigo}</td>
                      <td className="plv-td-img">
                        {producto.imagen_url
                          ? <img src={getImageThumb(producto.imagen_url)} alt="" className="plv-mini-img" loading="lazy" />
                          : <span className="plv-mini-placeholder">📦</span>
                        }
                        {qty > 0 && <span className="plv-fila-badge">{qty}</span>}
                      </td>
                      <td className="plv-td-nombre">{producto.nombre}</td>
                      <td className="plv-td-desc">{producto.descripcion && producto.descripcion !== 'Sin descripcion' ? producto.descripcion : '—'}</td>
                      <td className={`plv-td-stock ${stockVisual < 15 ? 'plv-stock--bajo' : 'plv-stock--ok'}`}>{stockVisual}</td>
                      <td className="plv-td-precio">${Number(producto.precio).toFixed(2)}</td>
                    </tr>
                  );
                })
              ) : (
                <tr><td colSpan="6" className="plv-empty">No se encontraron productos</td></tr>
              )}
            </tbody>
          </table>
        </div>
      )}

      {/* ── Paginación ── */}
      {totalPaginas > 1 && (
        <div className="plv-paginacion">
          <button
            type="button"
            className="plv-pag-btn"
            disabled={pagina === 1}
            onClick={() => setPagina(p => Math.max(1, p - 1))}
          >‹</button>
          <span className="plv-pag-info">
            {pagina} / {totalPaginas}
            <span className="plv-pag-total"> · {productosFiltrados.length} prod.</span>
          </span>
          <button
            type="button"
            className="plv-pag-btn"
            disabled={pagina === totalPaginas}
            onClick={() => setPagina(p => Math.min(totalPaginas, p + 1))}
          >›</button>
        </div>
      )}
    </div>
  );
};

export default React.memo(ProductoListVenta);
