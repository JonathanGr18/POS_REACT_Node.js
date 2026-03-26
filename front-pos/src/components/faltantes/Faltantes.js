import React, { useEffect, useState, useMemo } from 'react';
import jsPDF from 'jspdf';
import autoTable from 'jspdf-autotable';
import api, { IMAGE_BASE_URL } from '../../services/api';
import ConfirmModal from '../ui/ConfirmModal';
import Spinner from '../ui/Spinner';
import { useToast } from '../ui/Toast';
import useDebounce from '../../hooks/useDebounce';
import { useSettings } from '../../context/SettingsContext';
import './Faltantes.css';

const ESTADO = (stock) => {
  if (Number(stock) === 0)  return { label: 'Sin existencia', cls: 'estado--rojo',    icon: '❌' };
  if (Number(stock) <= 5)  return { label: 'Muy bajo',        cls: 'estado--naranja', icon: '⚠️' };
  return                           { label: 'Por terminarse', cls: 'estado--amarillo', icon: '📉' };
};

const FILTROS = [
  { key: 'todos',          label: 'Todos'          },
  { key: 'sin_existencia', label: '❌ Sin existencia' },
  { key: 'muy_bajo',       label: '⚠️ Muy bajo'       },
  { key: 'por_terminarse', label: '📉 Por terminarse' },
  { key: 'mas_vendidos',   label: '🔥 Más vendidos'   },
];

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

  const cargar = () => {
    setCargando(true);
    api.get(`/productos/faltantes?umbral=${settings.stockUmbral || 15}`)
      .then(res => setProductos(Array.isArray(res.data) ? res.data : []))
      .catch(() => { addToast('Error al cargar faltantes', 'error'); setProductos([]); })
      .finally(() => setCargando(false));
  };

  useEffect(() => { cargar(); }, []);

  const productosFiltrados = useMemo(() => {
    const termino = busquedaDebounced.toLowerCase();
    let lista = productos.filter(p => {
      const nombre = (p.nombre || '').toLowerCase();
      const codigo = (p.codigo || '').toLowerCase();
      return nombre.includes(termino) || codigo.includes(termino);
    });

    if (filtro === 'sin_existencia') lista = lista.filter(p => Number(p.stock) === 0);
    else if (filtro === 'muy_bajo')   lista = lista.filter(p => Number(p.stock) > 0 && Number(p.stock) <= 5);
    else if (filtro === 'por_terminarse') lista = lista.filter(p => Number(p.stock) > 5);
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

  // ── PDF ──────────────────────────────────────────────────────
  const exportarPDF = () => {
    const doc = new jsPDF();
    const fecha = new Date().toLocaleDateString('es-MX', { day: '2-digit', month: 'long', year: 'numeric' });

    doc.setFillColor(153, 103, 206);
    doc.rect(0, 0, 210, 28, 'F');
    doc.setTextColor(255, 255, 255);
    doc.setFontSize(16);
    doc.setFont('helvetica', 'bold');
    doc.text('Reporte de Faltantes', 14, 12);
    doc.setFontSize(9);
    doc.setFont('helvetica', 'normal');
    doc.text(`${settings.nombre}  ·  ${fecha}`, 14, 22);
    doc.setTextColor(0, 0, 0);

    const grupos = [
      { label: 'Sin existencia', color: [231, 76,  60],  items: productos.filter(p => Number(p.stock) === 0) },
      { label: 'Muy bajo',       color: [243, 156, 18],  items: productos.filter(p => Number(p.stock) > 0 && Number(p.stock) <= 5) },
      { label: 'Por terminarse', color: [241, 196, 15],  items: productos.filter(p => Number(p.stock) > 5) },
    ];

    let y = 34;
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
        head: [['Producto', 'Código', 'Stock', 'Vendidos (30d)']],
        body: g.items.map(p => [p.nombre, p.codigo || '-', p.stock, p.vendidos_mes || 0]),
        styles: { fontSize: 9 },
        headStyles: { fillColor: g.color, textColor: [255, 255, 255] },
        margin: { left: 14, right: 14 },
      });
      y = doc.lastAutoTable.finalY + 8;
    }

    doc.save(`faltantes-${new Date().toISOString().slice(0,10)}.pdf`);
    addToast('PDF exportado', 'exito');
  };

  // ── WhatsApp ─────────────────────────────────────────────────
  const compartirWhatsApp = () => {
    const fecha = new Date().toLocaleDateString('es-MX');
    const lineas = [`*📦 Faltantes - ${settings.nombre}*`, `📅 ${fecha}`, ''];

    const grupos = [
      { icon: '❌', label: 'SIN EXISTENCIA', items: productos.filter(p => Number(p.stock) === 0) },
      { icon: '⚠️', label: 'MUY BAJO',       items: productos.filter(p => Number(p.stock) > 0 && Number(p.stock) <= 5) },
      { icon: '📉', label: 'POR TERMINARSE', items: productos.filter(p => Number(p.stock) > 5) },
    ];

    for (const g of grupos) {
      if (g.items.length === 0) continue;
      lineas.push(`${g.icon} *${g.label}:*`);
      g.items.forEach(p => lineas.push(`  • ${p.nombre} (${p.stock} uds)`));
      lineas.push('');
    }

    window.open(`https://wa.me/?text=${encodeURIComponent(lineas.join('\n'))}`, '_blank');
  };

  // ── Conteos para badges de filtro ────────────────────────────
  const conteos = useMemo(() => ({
    todos:          productos.length,
    sin_existencia: productos.filter(p => Number(p.stock) === 0).length,
    muy_bajo:       productos.filter(p => Number(p.stock) > 0 && Number(p.stock) <= 5).length,
    por_terminarse: productos.filter(p => Number(p.stock) > 5).length,
    mas_vendidos:   productos.filter(p => (p.vendidos_mes || 0) > 0).length,
  }), [productos]);

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
          <button className="falt-btn falt-btn--wa" onClick={compartirWhatsApp} disabled={productos.length === 0}>
            💬 WhatsApp
          </button>
          <button className="falt-btn falt-btn--pdf" onClick={exportarPDF} disabled={productos.length === 0}>
            📄 PDF
          </button>
        </div>
      </div>

      {/* ── Recomendaciones ── */}
      {recomendaciones.length > 0 && (
        <div className="falt-recomendaciones">
          <p className="falt-rec-titulo">🔥 Pide con urgencia — sin stock pero muy vendidos:</p>
          <div className="falt-rec-lista">
            {recomendaciones.map(p => (
              <div key={p.id} className="falt-rec-item">
                <span className="falt-rec-nombre">{p.nombre}</span>
                <span className="falt-rec-ventas">{p.vendidos_mes} vendidos este mes</span>
              </div>
            ))}
          </div>
        </div>
      )}

      {/* ── Búsqueda + filtros ── */}
      <div className="falt-controles">
        <input
          className="falt-busqueda"
          type="text"
          placeholder="🔍 Buscar producto..."
          value={busqueda}
          onChange={e => setBusqueda(e.target.value)}
        />
        <div className="falt-filtros">
          {FILTROS.map(f => (
            <button
              key={f.key}
              className={`falt-filtro-btn${filtro === f.key ? ' activo' : ''}`}
              onClick={() => setFiltro(f.key)}
            >
              {f.label}
              {conteos[f.key] > 0 && <span className="falt-filtro-badge">{conteos[f.key]}</span>}
            </button>
          ))}
        </div>
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
              const est = ESTADO(p.stock);
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

                    <div className="falt-card-row">
                      <span className={`falt-estado ${est.cls}`}>
                        {est.icon} {est.label}
                      </span>
                      <span className="falt-stock-num">{p.stock} uds</span>
                    </div>

                    {p.vendidos_mes > 0 && (
                      <p className="falt-vendidos">🔥 {p.vendidos_mes} vendidos este mes</p>
                    )}
                  </div>

                  {Number(p.stock) === 0 && (
                    <button
                      className="falt-btn-eliminar"
                      onClick={() => setModalEliminar({ visible: true, id: p.id })}
                      disabled={eliminando === p.id}
                      title="Eliminar producto"
                    >
                      {eliminando === p.id ? '⏳' : '🗑️'}
                    </button>
                  )}
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
