import React, { useState, useEffect, useCallback } from 'react';
import api from '../services/api';
import { useToast } from '../components/ui/Toast';
import './Reportes.css';
import KPIsReportes from '../components/reportes/KPIsReportes';
import GraficaPeriodo from '../components/reportes/GraficaPeriodo';
import GraficaMeses from '../components/reportes/GraficaMeses';
import HeatmapAnual from '../components/reportes/HeatmapAnual';
import TopProductos from '../components/reportes/TopProductos';
import TicketPreviewModal from '../components/reportes/TicketPreviewModal';
import GraficaDiaSemana from '../components/reportes/GraficaDiaSemana';
import GraficaHoraPico from '../components/reportes/GraficaHoraPico';
import GraficaMetodoPago from '../components/reportes/GraficaMetodoPago';

const PERIODOS = [
  { label: '7 días',  value: '7d',  dias: 7   },
  { label: '30 días', value: '30d', dias: 30  },
  { label: '3 meses', value: '3m',  dias: 90  },
  { label: '6 meses', value: '6m',  dias: 180 },
  { label: '1 año',   value: '1a',  dias: 365 },
];

const toISO = (date) => date.toISOString().slice(0, 10);

const calcularRango = (periodo) => {
  const hoy = new Date();
  const p = PERIODOS.find(p => p.value === periodo);
  if (!p) return { desde: '', hasta: '' };
  return {
    desde: toISO(new Date(hoy - p.dias * 86400000)),
    hasta: toISO(hoy),
  };
};

const Reportes = () => {
  const { addToast } = useToast();
  const [periodo, setPeriodo] = useState('30d');
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
    setExpandido({});
    api.get(`/reportes/dias-filtrado?desde=${desde}&hasta=${hasta}`)
      .then(res => setDias(res.data))
      .catch(() => setDias([]));
  }, [desde, hasta]);

  const aplicarCustom = () => {
    if (!customDesde || !customHasta) return;
    if (customDesde > customHasta) {
      addToast('La fecha inicial no puede ser mayor a la fecha final', 'error');
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
      api.get(`/reportes/detalle/${fecha}`)
        .then(res => setDetalles(p => ({ ...p, [fecha]: res.data })))
        .catch(() => addToast('Error al cargar detalle del día', 'error'));
      return prev;
    });
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
    const { default: jsPDF } = await import('jspdf');
    const { default: autoTable } = await import('jspdf-autotable');
    const doc = new jsPDF();
    doc.setFontSize(16);
    doc.text('Reporte de Ventas', 14, 18);
    doc.setFontSize(10);
    doc.text(`Período: ${desde} — ${hasta}`, 14, 26);

    autoTable(doc, {
      startY: 32,
      head: [['Fecha', 'Ventas', 'Total del día']],
      body: dias.map(d => [
        d.dia.slice(0, 10),
        d.num_ventas,
        `$${parseFloat(d.total_dia).toFixed(2)}`,
      ]),
      styles: { fontSize: 9 },
      headStyles: { fillColor: [153, 103, 206] },
    });

    doc.save(`reporte-ventas-${desde}-${hasta}.pdf`);
  };

  const exportarCSV = () => {
    if (dias.length === 0) return;
    const header = 'Fecha,Total del día,Num ventas';
    const rows = dias.map(d =>
      `${d.dia},${parseFloat(d.total_dia).toFixed(2)},${d.num_ventas ?? ''}`
    );
    const csv = [header, ...rows].join('\n');
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
        />
      )}

      {/* ── Header + filtro ── */}
      <div className="reportes-header">
        <h2 className="reportes-titulo">Reportes de Ventas</h2>
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

      {/* ── Gráficas: día semana + hora pico + método pago ── */}
      <div className="reportes-charts-row">
        <GraficaDiaSemana dias={dias} />
        <GraficaHoraPico desde={desde} hasta={hasta} />
      </div>
      <GraficaMetodoPago desde={desde} hasta={hasta} />

      {/* ── Gráfica mensual ── */}
      <GraficaMeses />

      {/* ── Heatmap anual ── */}
      <HeatmapAnual />

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

                  {expandido[fechaISO] && detalles[fechaISO] && (
                    <div className="historial-detalle">
                      {detalles[fechaISO].map((venta, i) => (
                        <div key={i} className="historial-venta">
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
                      ))}
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
