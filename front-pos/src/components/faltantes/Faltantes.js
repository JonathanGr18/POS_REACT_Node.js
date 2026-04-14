import React, { useEffect, useState, useMemo } from 'react';
import api, { IMAGE_BASE_URL } from '../../services/api';
import ConfirmModal from '../ui/ConfirmModal';
import Spinner from '../ui/Spinner';
import { useToast } from '../ui/Toast';
import useDebounce from '../../hooks/useDebounce';
import { useSettings } from '../../context/SettingsContext';
import './Faltantes.css';

const ESTADO = (stock, stockMinimo = 15) => {
  const s = Number(stock);
  const umbralMuyBajo = Math.ceil(stockMinimo / 3);
  if (s === 0)                return { label: 'Sin existencia', cls: 'estado--rojo',    icon: '❌' };
  if (s <= umbralMuyBajo)     return { label: 'Muy bajo',       cls: 'estado--naranja', icon: '⚠️' };
  return                             { label: 'Por terminarse', cls: 'estado--amarillo', icon: '📉' };
};

// Filtros ahora se manejan via KPIs clickeables

const Faltantes = () => {
  const { addToast } = useToast();
  const { settings } = useSettings();
  const [productos, setProductos] = useState([]);
  const [cargando, setCargando] = useState(true);
  const [busqueda, setBusqueda] = useState('');
  const busquedaDebounced = useDebounce(busqueda, 400);
  const [filtro, setFiltro] = useState('todos');
  const [modalEliminar, setModalEliminar] = useState({ visible: false, id: null });
  const [eliminando, setEliminando] = useState(null);

  // Resurtir inline
  const [resurtirId, setResurtirId] = useState(null);
  const [resurtirCantidad, setResurtirCantidad] = useState('');
  const [resurtiendo, setResurtiendo] = useState(false);
  const [exportando, setExportando] = useState(false);

  useEffect(() => {
    const controller = new AbortController();
    let cancelado = false;
    setCargando(true);
    api.get(`/productos/faltantes?umbral=${settings.stockUmbral || 15}`, { signal: controller.signal })
      .then(res => { if (!cancelado) setProductos(Array.isArray(res.data) ? res.data : []); })
      .catch(err => {
        if (cancelado || err.code === 'ERR_CANCELED') return;
        addToast('Error al cargar faltantes', 'error');
        setProductos([]);
      })
      .finally(() => { if (!cancelado) setCargando(false); });
    return () => { cancelado = true; controller.abort(); };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [settings.stockUmbral]);

  const cargar = () => {
    // Re-trigger del useEffect via state dummy no es necesario; llamamos directo
    setCargando(true);
    api.get(`/productos/faltantes?umbral=${settings.stockUmbral || 15}`)
      .then(res => setProductos(Array.isArray(res.data) ? res.data : []))
      .catch(() => { addToast('Error al cargar faltantes', 'error'); setProductos([]); })
      .finally(() => setCargando(false));
  };

  // Cantidad sugerida de resurtido
  const getSugerido = (p) => {
    const minimo = (p.stock_minimo > 0 ? p.stock_minimo : 15);
    const vendidos = Number(p.vendidos_mes) || 0;
    const stock = Number(p.stock) || 0;
    return Math.max(Math.max(minimo - stock, vendidos), 1);
  };

  // ── Resurtir producto ──
  const handleResurtir = async (id) => {
    const cantidad = parseInt(resurtirCantidad);
    if (!cantidad || cantidad <= 0) {
      addToast('Ingresa una cantidad válida', 'aviso');
      return;
    }
    setResurtiendo(true);
    try {
      await api.put(`/productos/resurtir/${id}`, { cantidad });
      addToast(`Resurtido +${cantidad} unidades`, 'exito');
      setResurtirId(null);
      setResurtirCantidad('');
      cargar();
    } catch {
      addToast('Error al resurtir', 'error');
    } finally {
      setResurtiendo(false);
    }
  };

  // ── Agregar a lista de compras ──
  const agregarALista = async (producto) => {
    const sugerido = getSugerido(producto);
    const precioRef = (producto.precio_costo != null && Number(producto.precio_costo) > 0)
      ? Number(producto.precio_costo)
      : (producto.precio != null ? Number(producto.precio) : null);
    try {
      // Verificar si ya existe en la lista (evitar duplicados)
      const lista = await api.get('/lista-compras');
      const yaExiste = (lista.data || []).find(
        item => !item.completado &&
                item.nombre_producto?.toLowerCase().trim() === producto.nombre.toLowerCase().trim()
      );
      if (yaExiste) {
        addToast(`"${producto.nombre}" ya está en la lista de compras`, 'aviso');
        return;
      }
      await api.post('/lista-compras', {
        nombre_producto: producto.nombre,
        cantidad: sugerido,
        precio_ref: precioRef,
        notas: `Stock actual: ${producto.stock}`,
      });
      addToast(`"${producto.nombre}" agregado a lista de compras`, 'exito');
    } catch {
      addToast('Error al agregar a lista de compras', 'error');
    }
  };

  const productosFiltrados = useMemo(() => {
    const termino = busquedaDebounced.toLowerCase();
    let lista = productos.filter(p => {
      const nombre = (p.nombre || '').toLowerCase();
      const codigo = String(p.codigo || '').toLowerCase();
      return nombre.includes(termino) || codigo.includes(termino);
    });

    const getUmbral = (p) => (p.stock_minimo > 0 ? p.stock_minimo : 15);

    if (filtro === 'sin_existencia') lista = lista.filter(p => Number(p.stock) === 0);
    else if (filtro === 'muy_bajo')   lista = lista.filter(p => Number(p.stock) > 0 && Number(p.stock) <= Math.ceil(getUmbral(p) / 3));
    else if (filtro === 'por_terminarse') lista = lista.filter(p => Number(p.stock) > Math.ceil(getUmbral(p) / 3));
    else if (filtro === 'mas_vendidos')   lista = [...lista].sort((a, b) => (b.vendidos_mes || 0) - (a.vendidos_mes || 0));

    if (filtro !== 'mas_vendidos') lista = [...lista].sort((a, b) => Number(a.stock) - Number(b.stock));
    return lista;
  }, [productos, busquedaDebounced, filtro]);

  // Recomendaciones: sin stock pero muy vendidos
  const recomendaciones = useMemo(() =>
    productos
      .filter(p => Number(p.stock) === 0 && (p.vendidos_mes || 0) > 0)
      .sort((a, b) => (b.vendidos_mes || 0) - (a.vendidos_mes || 0))
      .slice(0, 3),
    [productos]
  );

  const confirmarEliminar = async () => {
    const id = modalEliminar.id;
    setModalEliminar({ visible: false, id: null });
    setEliminando(id);
    try {
      await api.delete(`/productos/${id}`);
      setProductos(prev => prev.filter(p => p.id !== id));
      addToast('Producto eliminado', 'exito');
    } catch {
      addToast('No se pudo eliminar el producto', 'error');
    } finally {
      setEliminando(null);
    }
  };

  // ── KPIs (single-pass para performance) ──
  const kpis = useMemo(() => {
    let sinStock = 0, muyBajo = 0, porTerminar = 0, masVendidos = 0;
    for (const p of productos) {
      const stock = Number(p.stock);
      const umbral = p.stock_minimo > 0 ? p.stock_minimo : 15;
      const limiteMuyBajo = Math.ceil(umbral / 3);
      if (stock === 0) sinStock++;
      else if (stock <= limiteMuyBajo) muyBajo++;
      else porTerminar++;
      if ((p.vendidos_mes || 0) > 0) masVendidos++;
    }
    return { sinStock, muyBajo, porTerminar, masVendidos, total: productos.length };
  }, [productos]);

  // ── PDF ──
  const exportarPDF = async () => {
    if (exportando) return;
    setExportando(true);
    try {
    const { default: jsPDF } = await import('jspdf');
    const { default: autoTable } = await import('jspdf-autotable');
    const doc = new jsPDF();
    const fecha = new Date().toLocaleDateString('es-MX', { day: '2-digit', month: 'long', year: 'numeric' });
    const nombreNegocio = settings.nombre || 'Mi Negocio';

    doc.setFillColor(153, 103, 206);
    doc.rect(0, 0, 210, 28, 'F');
    doc.setTextColor(255, 255, 255);
    doc.setFontSize(16);
    doc.setFont('helvetica', 'bold');
    doc.text('Reporte de Faltantes', 14, 12);
    doc.setFontSize(9);
    doc.setFont('helvetica', 'normal');
    doc.text(`${nombreNegocio}  ·  ${fecha}`, 14, 22);
    doc.setTextColor(0, 0, 0);

    // Usa productosFiltrados para que coincida con lo que el usuario ve en pantalla
    const fuente = productosFiltrados.length > 0 ? productosFiltrados : productos;
    const getUmbral = (p) => (p.stock_minimo > 0 ? p.stock_minimo : 15);
    const grupos = [
      { label: 'Sin existencia', color: [231, 76,  60],  items: fuente.filter(p => Number(p.stock) === 0) },
      { label: 'Muy bajo',       color: [243, 156, 18],  items: fuente.filter(p => Number(p.stock) > 0 && Number(p.stock) <= Math.ceil(getUmbral(p) / 3)) },
      { label: 'Por terminarse', color: [241, 196, 15],  items: fuente.filter(p => Number(p.stock) > Math.ceil(getUmbral(p) / 3)) },
    ];

    let y = 34;
    const totalPagesExp = '{total_pages_count_string}';
    for (const g of grupos) {
      if (g.items.length === 0) continue;
      doc.setFontSize(11);
      doc.setFont('helvetica', 'bold');
      doc.setTextColor(...g.color);
      doc.text(g.label, 14, y);
      doc.setTextColor(0, 0, 0);
      y += 2;
      autoTable(doc, {
        startY: y,
        head: [['Producto', 'Código', 'Stock', 'Mín.', 'Vendidos (30d)', 'Sugerido']],
        body: g.items.map(p => [
          p.nombre,
          p.codigo || '-',
          Number(p.stock) || 0,
          p.stock_minimo > 0 ? p.stock_minimo : 15,
          Number(p.vendidos_mes) || 0,
          getSugerido(p)
        ]),
        styles: { fontSize: 9, overflow: 'linebreak', cellWidth: 'wrap' },
        columnStyles: { 0: { cellWidth: 60 } },
        headStyles: { fillColor: g.color, textColor: [255, 255, 255] },
        margin: { left: 14, right: 14 },
        didDrawPage: (data) => {
          // Footer con numero de pagina
          doc.setFontSize(8);
          doc.setTextColor(150);
          const pageCount = doc.internal.getNumberOfPages();
          const pageText = typeof doc.putTotalPages === 'function'
            ? `Página ${data.pageNumber} de ${totalPagesExp}`
            : `Página ${pageCount}`;
          doc.text(pageText, 14, 290);
        }
      });
      y = doc.lastAutoTable.finalY + 8;
      // Si queda poco espacio, nueva página
      if (y > 260) { doc.addPage(); y = 20; }
    }

    if (typeof doc.putTotalPages === 'function') doc.putTotalPages(totalPagesExp);

    const fechaArchivo = new Date().toISOString().slice(0, 10);
    const hora = new Date().toISOString().slice(11, 16).replace(':', '');
    doc.save(`faltantes-${fechaArchivo}-${hora}.pdf`);
    addToast('PDF exportado', 'exito');
    } catch (err) {
      console.error('[exportarPDF] Error:', err);
      addToast('Error al generar el PDF', 'error');
    } finally {
      setExportando(false);
    }
  };

  // ── WhatsApp ──
  const compartirWhatsApp = () => {
    const fecha = new Date().toLocaleDateString('es-MX');
    const nombreNegocio = settings.nombre || 'Mi Negocio';
    // Escape caracteres que WhatsApp interpreta como markdown
    const escapeWA = (s) => String(s || '').replace(/([*_~`])/g, '\\$1');

    const lineas = [`*📦 Faltantes - ${escapeWA(nombreNegocio)}*`, `📅 ${fecha}`, ''];

    // Usa productosFiltrados para respetar filtros activos
    const fuente = productosFiltrados.length > 0 ? productosFiltrados : productos;
    const getUmbral = (p) => (p.stock_minimo > 0 ? p.stock_minimo : 15);
    const grupos = [
      { icon: '❌', label: 'SIN EXISTENCIA', items: fuente.filter(p => Number(p.stock) === 0) },
      { icon: '⚠️', label: 'MUY BAJO',       items: fuente.filter(p => Number(p.stock) > 0 && Number(p.stock) <= Math.ceil(getUmbral(p) / 3)) },
      { icon: '📉', label: 'POR TERMINARSE', items: fuente.filter(p => Number(p.stock) > Math.ceil(getUmbral(p) / 3)) },
    ];

    for (const g of grupos) {
      if (g.items.length === 0) continue;
      lineas.push(`${g.icon} *${g.label}:*`);
      g.items.forEach(p => {
        const sugerido = getSugerido(p);
        lineas.push(`  • ${escapeWA(p.nombre)} (${p.stock} uds, pedir ~${sugerido})`);
      });
      lineas.push('');
    }

    // Truncar si excede limite (cortando en salto de linea para no romper multi-byte)
    let mensaje = lineas.join('\n');
    const MAX = 1800;
    if (mensaje.length > MAX) {
      // Cortar en el último \n antes de MAX (evita romper emojis/caracteres UTF-8)
      const cortado = mensaje.slice(0, MAX);
      const ultimoSalto = cortado.lastIndexOf('\n');
      mensaje = (ultimoSalto > 0 ? cortado.slice(0, ultimoSalto) : cortado)
              + '\n\n... (lista truncada, ver PDF completo)';
    }
    window.open(`https://wa.me/?text=${encodeURIComponent(mensaje)}`, '_blank');
  };

  return (
    <div className="falt-page">
      <ConfirmModal
        visible={modalEliminar.visible}
        mensaje="¿Eliminar este producto del inventario?"
        onConfirm={confirmarEliminar}
        onCancel={() => setModalEliminar({ visible: false, id: null })}
      />

      {/* ── Header ── */}
      <div className="falt-header">
        <div>
          <h2 className="falt-titulo">📦 Faltantes</h2>
          <p className="falt-subtitulo">{productos.length} producto{productos.length !== 1 ? 's' : ''} con stock bajo</p>
        </div>
        <div className="falt-acciones">
          <button
            className="falt-btn falt-btn--wa"
            onClick={compartirWhatsApp}
            disabled={productos.length === 0 || exportando}
          >
            💬 WhatsApp
          </button>
          <button
            className="falt-btn falt-btn--pdf"
            onClick={exportarPDF}
            disabled={productos.length === 0 || exportando}
          >
            {exportando ? 'Generando...' : '📄 PDF'}
          </button>
        </div>
      </div>

      {/* ── KPIs (clickeables = filtros) ── */}
      {!cargando && productos.length > 0 && (
        <div className="falt-kpis" role="tablist" aria-label="Filtros de faltantes">
          <button
            type="button"
            role="tab"
            aria-selected={filtro === 'todos'}
            className={`falt-kpi falt-kpi--clickable${filtro === 'todos' ? ' falt-kpi--activo' : ''}`}
            onClick={() => setFiltro('todos')}
          >
            <span className="falt-kpi-valor">{kpis.total}</span>
            <span className="falt-kpi-label">Todos</span>
          </button>
          <button
            type="button"
            role="tab"
            aria-selected={filtro === 'sin_existencia'}
            className={`falt-kpi falt-kpi--rojo falt-kpi--clickable${filtro === 'sin_existencia' ? ' falt-kpi--activo' : ''}`}
            onClick={() => setFiltro('sin_existencia')}
          >
            <span className="falt-kpi-valor">{kpis.sinStock}</span>
            <span className="falt-kpi-label"><span aria-hidden="true">❌</span> Sin existencia</span>
          </button>
          <button
            type="button"
            role="tab"
            aria-selected={filtro === 'muy_bajo'}
            className={`falt-kpi falt-kpi--naranja falt-kpi--clickable${filtro === 'muy_bajo' ? ' falt-kpi--activo' : ''}`}
            onClick={() => setFiltro('muy_bajo')}
          >
            <span className="falt-kpi-valor">{kpis.muyBajo}</span>
            <span className="falt-kpi-label"><span aria-hidden="true">⚠️</span> Muy bajo</span>
          </button>
          <button
            type="button"
            role="tab"
            aria-selected={filtro === 'por_terminarse'}
            className={`falt-kpi falt-kpi--amarillo falt-kpi--clickable${filtro === 'por_terminarse' ? ' falt-kpi--activo' : ''}`}
            onClick={() => setFiltro('por_terminarse')}
          >
            <span className="falt-kpi-valor">{kpis.porTerminar}</span>
            <span className="falt-kpi-label"><span aria-hidden="true">📉</span> Por terminar</span>
          </button>
          <button
            type="button"
            role="tab"
            aria-selected={filtro === 'mas_vendidos'}
            className={`falt-kpi falt-kpi--clickable${filtro === 'mas_vendidos' ? ' falt-kpi--activo' : ''}`}
            onClick={() => setFiltro('mas_vendidos')}
          >
            <span className="falt-kpi-valor">{kpis.masVendidos}</span>
            <span className="falt-kpi-label"><span aria-hidden="true">🔥</span> Más vendidos</span>
          </button>
        </div>
      )}

      {/* ── Recomendaciones ── */}
      {recomendaciones.length > 0 && (
        <div className="falt-recomendaciones">
          <p className="falt-rec-titulo">🔥 Pide con urgencia — sin stock pero muy vendidos:</p>
          <div className="falt-rec-lista">
            {recomendaciones.map(p => (
              <div key={p.id} className="falt-rec-item">
                <span className="falt-rec-nombre">{p.nombre}</span>
                <span className="falt-rec-ventas">{p.vendidos_mes} vendidos (30 días)</span>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* ── Búsqueda ── */}
      <div className="falt-controles">
        <input
          className="falt-busqueda"
          type="text"
          placeholder="🔍 Buscar producto..."
          value={busqueda}
          onChange={e => setBusqueda(e.target.value)}
        />
      </div>

      {/* ── Cards ── */}
      {cargando ? <Spinner /> : (
        productosFiltrados.length === 0 ? (
          <div className="falt-empty">
            <p>🎉 No hay productos en esta categoría</p>
          </div>
        ) : (
          <div className="falt-grid">
            {productosFiltrados.map(p => {
              const umbral = (p.stock_minimo > 0 ? p.stock_minimo : 15);
              const est = ESTADO(p.stock, umbral);
              const sugerido = getSugerido(p);
              return (
                <div key={p.id} className={`falt-card falt-card--${est.cls.split('--')[1]}`}>
                  {/* Imagen o placeholder */}
                  {p.imagen_url
                    ? <img src={`${IMAGE_BASE_URL}${p.imagen_url}`} alt={p.nombre} className="falt-card-img" />
                    : <div className="falt-card-img-placeholder">📦</div>
                  }

                  <div className="falt-card-body">
                    <p className="falt-card-nombre">{p.nombre}</p>
                    {p.codigo && <p className="falt-card-codigo">#{p.codigo}</p>}
                    {p.categoria && p.categoria !== 'General' && (
                      <span className="falt-card-cat">{p.categoria}</span>
                    )}

                    <div className="falt-card-row">
                      <span className={`falt-estado ${est.cls}`}>
                        {est.icon} {est.label}
                      </span>
                      <span className="falt-stock-num">{p.stock}/{umbral}</span>
                    </div>

                    {p.vendidos_mes > 0 && (
                      <p className="falt-vendidos">🔥 {p.vendidos_mes} vendidos (30 días)</p>
                    )}

                    {sugerido > 0 && (
                      <p className="falt-sugerido">💡 Resurtir: ~{sugerido} uds</p>
                    )}
                  </div>

                  {/* Acciones */}
                  <div className="falt-card-acciones">
                    {resurtirId === p.id ? (
                      <div className="falt-resurtir-inline">
                        <input
                          type="number"
                          min="1"
                          placeholder={`${sugerido}`}
                          className="falt-resurtir-input"
                          value={resurtirCantidad}
                          onChange={e => setResurtirCantidad(e.target.value)}
                          onKeyDown={e => e.key === 'Enter' && handleResurtir(p.id)}
                          autoFocus
                        />
                        <button
                          className="falt-btn-accion falt-btn-accion--ok"
                          onClick={() => handleResurtir(p.id)}
                          disabled={resurtiendo}
                        >{resurtiendo ? '...' : '✓'}</button>
                        <button
                          className="falt-btn-accion falt-btn-accion--cancel"
                          onClick={() => { setResurtirId(null); setResurtirCantidad(''); }}
                        >✕</button>
                      </div>
                    ) : (
                      <>
                        <button
                          className="falt-btn-accion falt-btn-accion--resurtir"
                          onClick={() => { setResurtirId(p.id); setResurtirCantidad(String(sugerido)); }}
                          title="Resurtir"
                        >📦 Resurtir</button>
                        <button
                          className="falt-btn-accion falt-btn-accion--lista"
                          onClick={() => agregarALista(p)}
                          title="Agregar a lista de compras"
                        >📋 Lista</button>
                        {Number(p.stock) === 0 && (
                          <button
                            className="falt-btn-accion falt-btn-accion--eliminar"
                            onClick={() => setModalEliminar({ visible: true, id: p.id })}
                            disabled={eliminando === p.id}
                            title="Eliminar producto"
                          >{eliminando === p.id ? '⏳' : '🗑'}</button>
                        )}
                      </>
                    )}
                  </div>
                </div>
              );
            })}
          </div>
        )
      )}
    </div>
  );
};

export default Faltantes;
