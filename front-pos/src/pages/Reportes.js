import React, { useState, useEffect, useCallback } from 'react';
import api from '../services/api';
import { useToast } from '../components/ui/Toast';
import useLocalStorageState from '../hooks/useLocalStorageState';
import './Reportes.css';
import KPIsReportes from '../components/reportes/KPIsReportes';
import GraficaPeriodo from '../components/reportes/GraficaPeriodo';
import TopProductos from '../components/reportes/TopProductos';
import TicketPreviewModal from '../components/reportes/TicketPreviewModal';
import GraficaDiaSemana from '../components/reportes/GraficaDiaSemana';
import GraficaHoraPico from '../components/reportes/GraficaHoraPico';
import GraficaMetodoPago from '../components/reportes/GraficaMetodoPago';
import DevolucionesWidget from '../components/reportes/DevolucionesWidget';

const PERIODOS = [
  { label: '7 días',  value: '7d',  dias: 7   },
  { label: '30 días', value: '30d', dias: 30  },
  { label: '3 meses', value: '3m',  dias: 90  },
  { label: '6 meses', value: '6m',  dias: 180 },
  { label: '1 año',   value: '1a',  dias: 365 },
];

// Formato YYYY-MM-DD en zona local (evita off-by-one en TZ negativas)
const toISO = (date) => {
  const y = date.getFullYear();
  const m = String(date.getMonth() + 1).padStart(2, '0');
  const d = String(date.getDate()).padStart(2, '0');
  return `${y}-${m}-${d}`;
};

const calcularRango = (periodo) => {
  const hoy = new Date();
  const p = PERIODOS.find(p => p.value === periodo);
  if (!p) return { desde: '', hasta: '' };
  // dias - 1 porque el rango [desde, hasta] es inclusivo en ambos extremos
  const desde = new Date(hoy);
  desde.setDate(desde.getDate() - (p.dias - 1));
  return {
    desde: toISO(desde),
    hasta: toISO(hoy),
  };
};

const Reportes = () => {
  const { addToast } = useToast();
  const [periodo, setPeriodo] = useLocalStorageState('reportes.periodo', '30d');
  const [customDesde, setCustomDesde] = useState('');
  const [customHasta, setCustomHasta] = useState('');
  const [desde, setDesde] = useState('');
  const [hasta, setHasta] = useState('');

  const [dias, setDias] = useState([]);
  const [ticketSeleccionado, setTicketSeleccionado] = useState(null);
  const [expandido, setExpandido] = useState({});
  const [detalles, setDetalles] = useState({});

  useEffect(() => {
    if (periodo === 'custom') return;
    const { desde: d, hasta: h } = calcularRango(periodo);
    setDesde(d);
    setHasta(h);
  }, [periodo]);

  useEffect(() => {
    if (!desde || !hasta) return;
    let cancelado = false;
    setExpandido({});
    setDias([]); // Limpiar datos viejos mientras carga
    api.get(`/reportes/dias-filtrado?desde=${desde}&hasta=${hasta}`)
      .then(res => { if (!cancelado) setDias(res.data); })
      .catch(() => {
        if (!cancelado) {
          setDias([]);
          addToast('Error al cargar reporte', 'error');
        }
      });
    return () => { cancelado = true; };
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [desde, hasta]);

  const aplicarCustom = () => {
    if (!customDesde || !customHasta) return;
    if (customDesde > customHasta) {
      addToast('La fecha inicial no puede ser mayor a la fecha final', 'error');
      return;
    }
    const hoyISO = toISO(new Date());
    if (customDesde > hoyISO || customHasta > hoyISO) {
      addToast('No se pueden seleccionar fechas futuras', 'error');
      return;
    }
    // Limitar rango maximo a ~2 años para evitar queries pesadas
    const diff = (new Date(customHasta) - new Date(customDesde)) / 86400000;
    if (diff > 730) {
      addToast('El rango no puede exceder 2 años', 'error');
      return;
    }
    setDesde(customDesde);
    setHasta(customHasta);
  };

  const toggleDia = useCallback(async (fecha) => {
    setExpandido(prev => {
      if (prev[fecha]) {
        const c = { ...prev }; delete c[fecha]; return c;
      }
      return { ...prev, [fecha]: true };
    });
    setDetalles(prev => {
      if (prev[fecha]) return prev;
      // Marca como loading
      api.get(`/reportes/detalle/${fecha}`)
        .then(res => setDetalles(p => ({ ...p, [fecha]: res.data })))
        .catch(() => {
          addToast('Error al cargar detalle del día', 'error');
          setDetalles(p => ({ ...p, [fecha]: [] })); // Marca como vacío para no reintentar
        });
      return { ...prev, [fecha]: 'loading' };
    });
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  // Compute days without sales within the range
  const diasSinVentas = (() => {
    if (!desde || !hasta) return [];
    const conVentas = new Set(dias.map(d => d.dia.slice(0, 10)));
    const resultado = [];
    const cur = new Date(desde + 'T12:00:00');
    const fin = new Date(hasta + 'T12:00:00');
    while (cur <= fin) {
      const iso = cur.toISOString().slice(0, 10);
      if (!conVentas.has(iso)) resultado.push(iso);
      cur.setDate(cur.getDate() + 1);
    }
    return resultado;
  })();

  const exportarPDF = async () => {
    if (dias.length === 0) return;
    addToast('Generando reporte...', 'aviso');

    const { default: jsPDF } = await import('jspdf');
    const { default: autoTable } = await import('jspdf-autotable');
    const doc = new jsPDF();
    const purple = [153, 103, 206];
    const darkPurple = [100, 70, 160];

    // Fetch toda la data en paralelo (con Promise.allSettled para no fallar en bloque)
    let resumen = null, topProductos = [], metodos = [], horas = [];
    const fallosEndpoint = [];
    const [resRes, topRes, metRes, horasRes] = await Promise.allSettled([
      api.get(`/reportes/resumen-periodo?desde=${desde}&hasta=${hasta}`),
      api.get(`/reportes/top-productos?desde=${desde}&hasta=${hasta}`),
      api.get(`/reportes/metodos-pago?desde=${desde}&hasta=${hasta}`),
      api.get(`/reportes/horas?desde=${desde}&hasta=${hasta}`),
    ]);
    if (resRes.status === 'fulfilled') resumen = resRes.value.data;
    else fallosEndpoint.push('resumen');
    if (topRes.status === 'fulfilled') topProductos = topRes.value.data || [];
    else fallosEndpoint.push('top productos');
    if (metRes.status === 'fulfilled') metodos = metRes.value.data || [];
    else fallosEndpoint.push('métodos de pago');
    if (horasRes.status === 'fulfilled') horas = horasRes.value.data || [];
    else fallosEndpoint.push('horas');

    if (fallosEndpoint.length > 0) {
      addToast(`Algunos datos no pudieron cargarse: ${fallosEndpoint.join(', ')}`, 'aviso');
    }

    const totalPeriodo = dias.reduce((a, d) => a + parseFloat(d.total_dia), 0);
    const totalVentas = dias.reduce((a, d) => a + Number(d.num_ventas), 0);
    const promedioDiario = dias.length > 0 ? totalPeriodo / dias.length : 0;
    const ventaMax = dias.length > 0 ? Math.max(...dias.map(d => parseFloat(d.total_dia))) : 0;
    const mejorDiaFecha = dias.find(d => parseFloat(d.total_dia) === ventaMax)?.dia?.slice(0, 10) || '';
    const ticketMax = resumen ? parseFloat(resumen.venta_max) || 0 : null;
    const ticketMaxStr = ticketMax !== null ? `$${ticketMax.toFixed(2)}` : '—';
    const promedioTicket = totalVentas > 0 ? totalPeriodo / totalVentas : 0;

    const formatFecha = (iso) => new Date(iso + 'T12:00:00').toLocaleDateString('es-MX', { weekday: 'short', day: 'numeric', month: 'short' });
    const seccion = (num, titulo) => {
      if (y > 240) { doc.addPage(); y = 20; }
      y += 4;
      doc.setFillColor(...darkPurple);
      doc.roundedRect(14, y - 5, 182, 8, 2, 2, 'F');
      doc.setTextColor(255, 255, 255);
      doc.setFontSize(11);
      doc.setFont('helvetica', 'bold');
      doc.text(`${num}. ${titulo}`, 18, y + 1);
      doc.setTextColor(0, 0, 0);
      y += 7;
    };

    // ═══ PORTADA ═══
    doc.setFillColor(...purple);
    doc.rect(0, 0, 210, 40, 'F');
    doc.setTextColor(255, 255, 255);
    doc.setFontSize(22);
    doc.setFont('helvetica', 'bold');
    doc.text('Reporte de Ventas', 105, 16, { align: 'center' });
    doc.setFontSize(12);
    doc.setFont('helvetica', 'normal');
    doc.text(`${desde}  —  ${hasta}`, 105, 26, { align: 'center' });
    doc.setFontSize(9);
    doc.text(`Generado: ${new Date().toLocaleDateString('es-MX', { day: '2-digit', month: 'long', year: 'numeric' })}`, 105, 35, { align: 'center' });
    doc.setTextColor(0, 0, 0);

    let y = 50;

    // ═══ 1. RESUMEN GENERAL ═══
    seccion(1, 'Resumen General');

    // KPIs en 2 columnas visuales
    autoTable(doc, {
      startY: y,
      body: [
        [{ content: 'Total vendido', styles: { fontStyle: 'bold', textColor: [100, 100, 100] } }, { content: `$${totalPeriodo.toFixed(2)}`, styles: { fontStyle: 'bold', fontSize: 13 } },
         { content: 'Num. ventas', styles: { fontStyle: 'bold', textColor: [100, 100, 100] } }, { content: `${totalVentas}`, styles: { fontStyle: 'bold', fontSize: 13 } }],
        [{ content: 'Promedio diario', styles: { textColor: [100, 100, 100] } }, `$${promedioDiario.toFixed(2)}`,
         { content: 'Promedio por ticket', styles: { textColor: [100, 100, 100] } }, `$${promedioTicket.toFixed(2)}`],
        [{ content: 'Ticket más alto', styles: { textColor: [100, 100, 100] } }, ticketMaxStr,
         { content: 'Mejor día', styles: { textColor: [100, 100, 100] } }, `$${ventaMax.toFixed(2)} (${formatFecha(mejorDiaFecha)})`],
        [{ content: 'Días con ventas', styles: { textColor: [100, 100, 100] } }, `${dias.length}`,
         { content: 'Días sin ventas', styles: { textColor: [100, 100, 100] } }, `${diasSinVentas.length}`],
      ],
      theme: 'plain',
      styles: { fontSize: 9, cellPadding: 3 },
      columnStyles: { 0: { cellWidth: 40 }, 1: { cellWidth: 50 }, 2: { cellWidth: 42 }, 3: { cellWidth: 50 } },
      margin: { left: 14, right: 14 },
    });
    y = doc.lastAutoTable.finalY + 6;

    // ═══ 2. MÉTODOS DE PAGO ═══
    if (metodos.length > 0) {
      seccion(2, 'Métodos de Pago');
      const totalMetodos = metodos.reduce((a, m) => a + parseFloat(m.total), 0);
      autoTable(doc, {
        startY: y,
        head: [['Método', 'Num. ventas', 'Total recaudado', '% del total']],
        body: metodos.map(m => {
          const nombre = m.metodo_pago === 'efectivo' ? 'Efectivo' : m.metodo_pago === 'tarjeta' ? 'Tarjeta' : 'Transferencia';
          return [nombre, m.num_ventas, `$${parseFloat(m.total).toFixed(2)}`, `${(parseFloat(m.total) / totalMetodos * 100).toFixed(1)}%`];
        }),
        styles: { fontSize: 9 },
        headStyles: { fillColor: [46, 134, 193], textColor: 255 },
        columnStyles: { 1: { halign: 'center' }, 2: { halign: 'right' }, 3: { halign: 'center' } },
        margin: { left: 14, right: 14 },
      });
      y = doc.lastAutoTable.finalY + 6;
    }

    // ═══ 3. TOP PRODUCTOS ═══
    if (topProductos.length > 0) {
      seccion(3, 'Top Productos Más Vendidos');
      autoTable(doc, {
        startY: y,
        head: [['#', 'Producto', 'Unidades', 'Ingresos', 'Ventas']],
        body: topProductos.slice(0, 10).map((p, i) => [
          i + 1,
          p.producto,
          p.total_unidades,
          `$${parseFloat(p.total_ingresos).toFixed(2)}`,
          p.num_ventas,
        ]),
        styles: { fontSize: 9 },
        headStyles: { fillColor: [39, 174, 96], textColor: 255 },
        columnStyles: { 0: { halign: 'center', cellWidth: 10 }, 2: { halign: 'center' }, 3: { halign: 'right' }, 4: { halign: 'center' } },
        margin: { left: 14, right: 14 },
      });
      y = doc.lastAutoTable.finalY + 6;
    }

    // ═══ 4. HORARIOS PICO ═══
    if (horas.length > 0) {
      seccion(4, 'Horarios con Mayor Actividad');
      const topHoras = [...horas].sort((a, b) => Number(b.total) - Number(a.total)).slice(0, 8);
      autoTable(doc, {
        startY: y,
        head: [['Horario', 'Num. ventas', 'Total recaudado']],
        body: topHoras.map(h => [
          `${String(h.hora).padStart(2, '0')}:00 – ${String(h.hora).padStart(2, '0')}:59`,
          h.num_ventas,
          `$${parseFloat(h.total).toFixed(2)}`,
        ]),
        styles: { fontSize: 9 },
        headStyles: { fillColor: [243, 156, 18], textColor: 255 },
        columnStyles: { 1: { halign: 'center' }, 2: { halign: 'right' } },
        margin: { left: 14, right: 14 },
      });
      y = doc.lastAutoTable.finalY + 6;
    }

    // ═══ 5. VENTAS POR DÍA DE SEMANA ═══
    if (dias.length > 0) {
      seccion(5, 'Ventas por Día de la Semana');
      const diasSemana = ['Domingo', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado'];
      const porDia = {};
      dias.forEach(d => {
        const dow = new Date(d.dia.slice(0, 10) + 'T12:00:00').getDay();
        if (!porDia[dow]) porDia[dow] = { ventas: 0, total: 0 };
        porDia[dow].ventas += Number(d.num_ventas);
        porDia[dow].total += parseFloat(d.total_dia);
      });

      autoTable(doc, {
        startY: y,
        head: [['Día', 'Num. ventas', 'Total', 'Prom. por venta']],
        body: Object.entries(porDia)
          .sort((a, b) => b[1].total - a[1].total)
          .map(([dow, data]) => [
            diasSemana[dow],
            data.ventas,
            `$${data.total.toFixed(2)}`,
            `$${(data.ventas > 0 ? data.total / data.ventas : 0).toFixed(2)}`,
          ]),
        styles: { fontSize: 9 },
        headStyles: { fillColor: [52, 152, 219], textColor: 255 },
        columnStyles: { 1: { halign: 'center' }, 2: { halign: 'right' }, 3: { halign: 'right' } },
        margin: { left: 14, right: 14 },
      });
      y = doc.lastAutoTable.finalY + 6;
    }

    // ═══ 6. DÍAS SIN VENTAS ═══
    if (diasSinVentas.length > 0) {
      seccion(6, `Días sin Ventas (${diasSinVentas.length})`);
      doc.setFontSize(8);
      doc.setFont('helvetica', 'normal');
      doc.setTextColor(80);
      const linea = diasSinVentas.map(iso => formatFecha(iso)).join('   ·   ');
      const splitText = doc.splitTextToSize(linea, 180);
      doc.text(splitText, 14, y);
      doc.setTextColor(0, 0, 0);
      y += splitText.length * 4 + 6;
    }

    // ═══ 7. DETALLE DIARIO ═══
    const numSec = diasSinVentas.length > 0 ? 7 : 6;
    seccion(numSec, 'Detalle Diario');
    autoTable(doc, {
      startY: y,
      head: [['Fecha', 'Día', 'Num. ventas', 'Total del día']],
      body: dias.map(d => {
        const fecha = d.dia.slice(0, 10);
        return [fecha, formatFecha(fecha), d.num_ventas, `$${parseFloat(d.total_dia).toFixed(2)}`];
      }),
      styles: { fontSize: 8 },
      headStyles: { fillColor: [...purple], textColor: 255 },
      columnStyles: { 2: { halign: 'center' }, 3: { halign: 'right' } },
      alternateRowStyles: { fillColor: [245, 240, 255] },
      margin: { left: 14, right: 14 },
    });

    // ═══ FOOTER ═══
    const pageCount = doc.internal.getNumberOfPages();
    for (let i = 1; i <= pageCount; i++) {
      doc.setPage(i);
      // Línea separadora
      doc.setDrawColor(200);
      doc.line(14, 285, 196, 285);
      doc.setFontSize(7);
      doc.setTextColor(150);
      doc.text(`Reporte de Ventas  ·  ${desde} a ${hasta}`, 14, 289);
      doc.text(`Página ${i} de ${pageCount}`, 196, 289, { align: 'right' });
    }

    doc.save(`reporte-ventas-${desde}-${hasta}.pdf`);
    addToast('Reporte PDF exportado', 'exito');
  };

  const exportarCSV = () => {
    if (dias.length === 0) return;
    // Escape de comas y comillas (CSV estándar)
    const esc = (val) => {
      const s = String(val ?? '');
      if (/[",\n]/.test(s)) return `"${s.replace(/"/g, '""')}"`;
      return s;
    };
    const header = ['Fecha', 'Total del día', 'Num ventas'].map(esc).join(',');
    const rows = dias.map(d => [
      esc(d.dia.slice(0, 10)),
      esc(parseFloat(d.total_dia).toFixed(2)),
      esc(d.num_ventas ?? ''),
    ].join(','));
    // BOM UTF-8 para que Excel muestre acentos correctamente
    const csv = '\uFEFF' + [header, ...rows].join('\r\n');
    const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `ventas-${desde}-${hasta}.csv`;
    a.click();
    URL.revokeObjectURL(url);
  };

  return (
    <div className="reportes-page">
      {ticketSeleccionado && (
        <TicketPreviewModal
          venta={ticketSeleccionado}
          onCerrar={() => setTicketSeleccionado(null)}
          onVentaModificada={() => {
            // Recargar datos del periodo tras modificar/anular venta
            setTicketSeleccionado(null);
            setExpandido({});
            setDetalles({});
            // Trigger re-fetch via cambio de deps
            const d = desde;
            setDesde('');
            setTimeout(() => setDesde(d), 0);
          }}
        />
      )}

      {/* ── Header + filtro ── */}
      <div className="reportes-header">
        <div className="reportes-titulo-row">
          <h2 className="reportes-titulo">Reportes de Ventas</h2>
          <div className="reportes-export-btns">
            <button
              className="btn-export-pdf"
              onClick={exportarPDF}
              disabled={dias.length === 0}
            >
              📄 Exportar PDF
            </button>
            <button
              className="btn-export-csv"
              onClick={exportarCSV}
              disabled={dias.length === 0}
            >
              📊 CSV
            </button>
          </div>
        </div>
        <div className="filtro-periodo">
          {PERIODOS.map(p => (
            <button
              key={p.value}
              className={periodo === p.value ? 'activo' : ''}
              onClick={() => setPeriodo(p.value)}
            >
              {p.label}
            </button>
          ))}
          <button
            className={periodo === 'custom' ? 'activo' : ''}
            onClick={() => setPeriodo('custom')}
          >
            Personalizado
          </button>
        </div>
      </div>

      {periodo === 'custom' && (
        <div className="filtro-custom">
          <input
            type="date"
            value={customDesde}
            onChange={e => setCustomDesde(e.target.value)}
          />
          <span className="filtro-separador">—</span>
          <input
            type="date"
            value={customHasta}
            onChange={e => setCustomHasta(e.target.value)}
          />
          <button
            onClick={aplicarCustom}
            disabled={!customDesde || !customHasta}
          >
            Aplicar
          </button>
        </div>
      )}

      {/* ── KPIs ── */}
      <KPIsReportes desde={desde} hasta={hasta} />

      {/* ── Gráfica de ventas diarias del período ── */}
      <GraficaPeriodo dias={dias} />

      {/* ── Gráficas: día semana + método pago + hora pico ── */}
      <div className="reportes-charts-row">
        <GraficaDiaSemana dias={dias} />
        <GraficaMetodoPago desde={desde} hasta={hasta} />
        <GraficaHoraPico desde={desde} hasta={hasta} />
      </div>

      {/* ── Devoluciones: widget compacto ── */}
      <DevolucionesWidget desde={desde} hasta={hasta} />

      {/* ── Días sin ventas ── */}
      {diasSinVentas.length > 0 && (
        <div className="dias-sin-ventas-card">
          <h3 className="dsv-titulo">
            Días sin ventas
            <span className="dsv-badge">{diasSinVentas.length}</span>
          </h3>
          <div className="dsv-lista">
            {diasSinVentas.map(iso => (
              <span key={iso} className="dsv-dia">
                {new Date(iso + 'T12:00:00').toLocaleDateString('es-MX', {
                  weekday: 'short', day: 'numeric', month: 'short'
                })}
              </span>
            ))}
          </div>
        </div>
      )}

      {/* ── Historial + Top productos ── */}
      <div className="reportes-bottom">
        {/* Historial */}
        <div className="historial-card">
          <div className="historial-header">
            <h3>Historial del período</h3>
            <div className="historial-acciones">
              <button
                className="btn-pdf"
                onClick={exportarPDF}
                disabled={dias.length === 0}
              >
                ⬇️ PDF
              </button>
              <button
                className="btn-csv"
                onClick={exportarCSV}
                disabled={dias.length === 0}
              >
                ⬇️ CSV
              </button>
            </div>
          </div>

          <div className="historial-lista">
            {dias.length === 0 ? (
              <p className="sin-datos">Sin datos en el período seleccionado</p>
            ) : (
              dias.map(dia => {
                const fechaISO = dia.dia.slice(0, 10);
                return (
                <div key={fechaISO} className="historial-dia">
                  <div
                    className="historial-dia-header"
                    onClick={() => toggleDia(fechaISO)}
                  >
                    <span className="historial-fecha">
                      {new Date(fechaISO + 'T12:00:00').toLocaleDateString('es-MX', {
                        weekday: 'short', day: 'numeric', month: 'short'
                      })}
                    </span>
                    <span className="historial-num-ventas">
                      {dia.num_ventas} venta{Number(dia.num_ventas) !== 1 ? 's' : ''}
                    </span>
                    <span className="historial-total">
                      ${parseFloat(dia.total_dia).toFixed(2)}
                    </span>
                    <span className="historial-chevron">
                      {expandido[fechaISO] ? '▲' : '▼'}
                    </span>
                  </div>

                  {expandido[fechaISO] && (
                    <div className="historial-detalle">
                      {detalles[fechaISO] === 'loading' ? (
                        <p className="sin-datos">Cargando detalle...</p>
                      ) : Array.isArray(detalles[fechaISO]) && detalles[fechaISO].length > 0 ? (
                        detalles[fechaISO].map((venta, i) => (
                          <div key={venta.id ?? i} className="historial-venta">
                            <span className="historial-hora">
                              🕒 {new Date(venta.fecha).toLocaleTimeString('es-MX', {
                                hour: '2-digit', minute: '2-digit'
                              })}
                            </span>
                            <span className="historial-venta-total">
                              ${parseFloat(venta.total).toFixed(2)}
                            </span>
                            <button
                              className="btn-ticket"
                              onClick={() => setTicketSeleccionado(venta)}
                            >
                              🧾
                            </button>
                          </div>
                        ))
                      ) : Array.isArray(detalles[fechaISO]) ? (
                        <p className="sin-datos">Sin ventas</p>
                      ) : null}
                    </div>
                  )}
                </div>
                );
              })
            )}
          </div>
        </div>

        {/* Top productos */}
        <TopProductos desde={desde} hasta={hasta} />
      </div>
    </div>
  );
};

export default Reportes;
