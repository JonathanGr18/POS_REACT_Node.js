import React, { useEffect, useMemo, useRef, useState } from 'react';
import { FaTimes, FaSearch, FaTrash, FaTrashAlt } from 'react-icons/fa';
import api from '../../services/api';
import { useToast } from '../ui/Toast';
import './ProductoDrawer.css';
import './ResurtirMasivoDrawer.css';

const ResurtirMasivoDrawer = ({ visible, onCerrar, productos = [], onResurtido }) => {
  const { addToast } = useToast();
  const [busqueda, setBusqueda] = useState('');
  const [buscarPor, setBuscarPor] = useState('todo'); // 'todo' | 'nombre' | 'precio' | 'stock'
  const [orden, setOrden] = useState('nombre'); // 'nombre' | 'precio_asc' | 'precio_desc' | 'stock_asc' | 'stock_desc'
  const [cantidades, setCantidades] = useState({}); // { [id]: string }
  const [cargando, setCargando] = useState(false);
  const [resaltadoId, setResaltadoId] = useState(null);
  const bodyRef = useRef(null);

  // Bloquear scroll + cerrar con Escape
  useEffect(() => {
    if (!visible) return;
    const onKey = (e) => { if (e.key === 'Escape') onCerrar(); };
    window.addEventListener('keydown', onKey);
    const prev = document.body.style.overflow;
    document.body.style.overflow = 'hidden';
    return () => {
      window.removeEventListener('keydown', onKey);
      document.body.style.overflow = prev;
    };
  }, [visible, onCerrar]);

  // Limpiar al abrir
  useEffect(() => {
    if (visible) {
      setBusqueda('');
      setCantidades({});
      setBuscarPor('todo');
      setOrden('nombre');
    }
  }, [visible]);

  const filtrados = useMemo(() => {
    const v = busqueda.trim().toLowerCase();
    const esNum = v !== '' && !isNaN(Number(v));

    let lista = productos.filter(p => {
      if (!v) return true;
      const cod = String(p.codigo ?? '').toLowerCase();
      const nom = (p.nombre || '').toLowerCase();
      const precio = Number(p.precio) || 0;
      const stock = Number(p.stock) || 0;

      switch (buscarPor) {
        case 'nombre':
          return nom.includes(v);
        case 'precio':
          if (!esNum) return false;
          return String(precio.toFixed(2)).includes(v) || String(precio).startsWith(v);
        case 'stock':
          if (!esNum) return false;
          return stock === Number(v) || String(stock).startsWith(v);
        default: // 'todo': código, nombre
          if (esNum) return Number(p.codigo) === Number(v) || cod.startsWith(v);
          return nom.includes(v) || cod.includes(v);
      }
    });

    return [...lista].sort((a, b) => {
      if (orden === 'nombre')       return (a.nombre || '').localeCompare(b.nombre || '');
      if (orden === 'precio_asc')   return Number(a.precio) - Number(b.precio);
      if (orden === 'precio_desc')  return Number(b.precio) - Number(a.precio);
      if (orden === 'stock_asc')    return Number(a.stock) - Number(b.stock);
      if (orden === 'stock_desc')   return Number(b.stock) - Number(a.stock);
      return 0;
    });
  }, [productos, busqueda, buscarPor, orden]);

  const setCantidad = (id, valor) => {
    setCantidades(prev => {
      const nuevo = { ...prev };
      if (valor === '' || valor == null) {
        delete nuevo[id];
      } else {
        nuevo[id] = String(valor);
      }
      return nuevo;
    });
  };

  const incrementar = (id, delta) => {
    const actual = parseInt(cantidades[id] || '0', 10) || 0;
    const nuevo = Math.max(0, actual + delta);
    setCantidad(id, nuevo === 0 ? '' : nuevo);
  };

  const itemsAEnviar = useMemo(() => {
    return Object.entries(cantidades)
      .map(([id, c]) => ({ id: Number(id), cantidad: parseInt(c, 10) }))
      .filter(it => Number.isFinite(it.cantidad) && it.cantidad > 0);
  }, [cantidades]);

  // Productos seleccionados con su info completa para el resumen
  const productosSeleccionados = useMemo(() => {
    const byId = new Map(productos.map(p => [p.id, p]));
    return itemsAEnviar
      .map(it => ({ ...byId.get(it.id), cantidad: it.cantidad }))
      .filter(p => p && p.id);
  }, [itemsAEnviar, productos]);

  const totalUnidades = itemsAEnviar.reduce((a, it) => a + it.cantidad, 0);

  const quitarItem = (id) => setCantidad(id, '');
  const limpiarTodo = () => setCantidades({});

  // Desplazar a un producto en el catálogo y resaltarlo brevemente
  const irAProducto = (id) => {
    const estaEnFiltrados = filtrados.some(p => p.id === id);
    if (!estaEnFiltrados) {
      // Si no está visible por filtros, limpiar para encontrarlo
      setBusqueda('');
      setBuscarPor('todo');
    }
    // Esperar siguiente frame para que se renderice el row
    requestAnimationFrame(() => {
      const fila = bodyRef.current?.querySelector(`tr[data-id="${id}"]`);
      if (fila) {
        fila.scrollIntoView({ block: 'center', behavior: 'smooth' });
      }
      setResaltadoId(id);
      setTimeout(() => setResaltadoId(null), 1400);
    });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (itemsAEnviar.length === 0) {
      addToast('Ingresa cantidades en al menos un producto', 'aviso');
      return;
    }
    setCargando(true);
    try {
      await api.post('/productos/resurtir-masivo', { items: itemsAEnviar });
      addToast(`${itemsAEnviar.length} producto(s) resurtido(s) (+${totalUnidades} unidades)`, 'exito');
      onResurtido?.();
      onCerrar();
    } catch (err) {
      addToast(err?.response?.data?.error || 'Error al resurtir productos', 'error');
    } finally {
      setCargando(false);
    }
  };

  if (!visible) return null;

  return (
    <>
      <div className="drawer-overlay" onClick={onCerrar} aria-hidden="true" />
      <div
        className="drawer-panel drawer-panel--ancho"
        role="dialog"
        aria-modal="true"
        aria-labelledby="surtir-drawer-title"
      >
        <div className="drawer-header">
          <h2 id="surtir-drawer-title">Surtir Productos</h2>
          <button className="drawer-close" onClick={onCerrar} aria-label="Cerrar"><FaTimes /></button>
        </div>

        <div className="surtir-split">
          {/* ── Columna izquierda: catálogo ── */}
          <div className="surtir-col-catalogo">
            <div className="surtir-filtros">
              <div className="surtir-buscar">
                <FaSearch className="surtir-buscar-icon" aria-hidden="true" />
                <input
                  type={buscarPor === 'precio' || buscarPor === 'stock' ? 'number' : 'text'}
                  className="input"
                  placeholder={
                    buscarPor === 'nombre' ? 'Buscar por nombre...' :
                    buscarPor === 'precio' ? 'Buscar por precio...' :
                    buscarPor === 'stock'  ? 'Buscar por stock...' :
                    'Buscar por nombre o código...'
                  }
                  value={busqueda}
                  onChange={e => setBusqueda(e.target.value)}
                  autoFocus
                />
              </div>
              <select
                className="surtir-select"
                value={buscarPor}
                onChange={e => setBuscarPor(e.target.value)}
                aria-label="Buscar por"
              >
                <option value="todo">Todo</option>
                <option value="nombre">Nombre</option>
                <option value="precio">Precio</option>
                <option value="stock">Stock</option>
              </select>
              <select
                className="surtir-select"
                value={orden}
                onChange={e => setOrden(e.target.value)}
                aria-label="Ordenar por"
              >
                <option value="nombre">A–Z</option>
                <option value="precio_asc">Precio ↑</option>
                <option value="precio_desc">Precio ↓</option>
                <option value="stock_asc">Stock ↑</option>
                <option value="stock_desc">Stock ↓</option>
              </select>
            </div>

            <div className="drawer-body surtir-body" ref={bodyRef}>
              {filtrados.length === 0 ? (
                <p className="surtir-vacio">No se encontraron productos</p>
              ) : (
                <table className="surtir-tabla">
              <thead>
                <tr>
                  <th>Código</th>
                  <th>Producto</th>
                  <th className="col-stock">Stock</th>
                  <th className="col-cantidad">Agregar</th>
                </tr>
              </thead>
              <tbody>
                {filtrados.map(p => {
                  const valor = cantidades[p.id] || '';
                  const activo = valor !== '' && parseInt(valor, 10) > 0;
                  return (
                    <tr
                      key={p.id}
                      data-id={p.id}
                      className={`${activo ? 'surtir-fila--activo' : ''}${resaltadoId === p.id ? ' surtir-fila--resaltado' : ''}`}
                    >
                      <td className="td-codigo">{p.codigo}</td>
                      <td className="td-nombre">
                        <span className="surtir-nombre">{p.nombre}</span>
                        {p.descripcion && p.descripcion !== 'Sin descripcion' && (
                          <span className="surtir-desc">{p.descripcion}</span>
                        )}
                      </td>
                      <td className="col-stock">
                        <span className={`surtir-stock ${Number(p.stock) < (p.stock_minimo || 15) ? 'surtir-stock--bajo' : ''}`}>
                          {p.stock}
                        </span>
                      </td>
                      <td className="col-cantidad">
                        <div className="surtir-qty">
                          <button
                            type="button"
                            className="surtir-qty-btn"
                            onClick={() => incrementar(p.id, -1)}
                            disabled={!activo}
                          >−</button>
                          <input
                            type="number"
                            min="0"
                            className="surtir-qty-input"
                            value={valor}
                            onChange={e => setCantidad(p.id, e.target.value.replace(/[^\d]/g, ''))}
                            placeholder="0"
                          />
                          <button
                            type="button"
                            className="surtir-qty-btn"
                            onClick={() => incrementar(p.id, +1)}
                          >+</button>
                        </div>
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          )}
            </div>
          </div>

          {/* ── Columna derecha: productos seleccionados (tarjeta separada) ── */}
          <aside className={`surtir-col-seleccion${productosSeleccionados.length === 0 ? ' surtir-col-seleccion--vacio' : ''}`}>
            <div className="surtir-seleccion-card">
              <div className="surtir-seleccion-header">
                <span className="surtir-seleccion-titulo">
                  🛒 A surtir ({productosSeleccionados.length})
                </span>
                {productosSeleccionados.length > 0 && (
                  <button
                    type="button"
                    className="surtir-limpiar-todo"
                    onClick={limpiarTodo}
                    title="Quitar todos"
                  >
                    <FaTrashAlt /> Vaciar
                  </button>
                )}
              </div>
              {productosSeleccionados.length === 0 ? (
                <div className="surtir-seleccion-placeholder-box">
                  <span className="placeholder-icono" aria-hidden="true">📦</span>
                  <p>Ingresa cantidades en la lista y los productos aparecerán aquí.</p>
                </div>
              ) : (
                <ul className="surtir-seleccion-lista">
                  {productosSeleccionados.map(p => (
                    <li key={p.id} className="surtir-seleccion-item">
                      <button
                        type="button"
                        className="sel-info"
                        onClick={() => irAProducto(p.id)}
                        title="Ir al producto en la lista"
                      >
                        <span className="sel-nombre">{p.nombre}</span>
                        <span className="sel-stock-cambio">
                          Stock: {p.stock} → <strong>{Number(p.stock) + p.cantidad}</strong>
                        </span>
                      </button>
                      <span className="sel-cantidad">+{p.cantidad}</span>
                      <button
                        type="button"
                        className="sel-quitar"
                        onClick={() => quitarItem(p.id)}
                        title="Quitar de la lista"
                        aria-label={`Quitar ${p.nombre}`}
                      >
                        <FaTrash />
                      </button>
                    </li>
                  ))}
                </ul>
              )}
            </div>
          </aside>
        </div>

        <div className="surtir-footer">
          <div className="surtir-resumen">
            <span className="surtir-resumen-items">{itemsAEnviar.length} producto(s)</span>
            <span className="surtir-resumen-unidades">+{totalUnidades} unidades</span>
          </div>
          <button
            type="button"
            className="btn btn-success surtir-btn-enviar"
            onClick={handleSubmit}
            disabled={cargando || itemsAEnviar.length === 0}
          >
            {cargando ? 'Surtiendo...' : '✔ Surtir'}
          </button>
        </div>
      </div>
    </>
  );
};

export default ResurtirMasivoDrawer;
