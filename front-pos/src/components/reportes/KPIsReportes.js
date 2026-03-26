import React, { useEffect, useState } from 'react';
import api from '../../services/api';
import './KPIsReportes.css';

const toISO = (d) => d.toISOString().slice(0, 10);

const pctChange = (actual, anterior) => {
  if (!anterior || anterior === 0) return null;
  return ((actual - anterior) / anterior) * 100;
};

const KPIsReportes = ({ desde, hasta }) => {
  const [data, setData]     = useState(null);
  const [prevData, setPrev] = useState(null);

  useEffect(() => {
    if (!desde || !hasta) return;
    setData(null);
    setPrev(null);

    // Período actual
    api.get(`/reportes/resumen-periodo?desde=${desde}&hasta=${hasta}`)
      .then(res => setData(res.data))
      .catch(() => setData(null));

    // Período anterior (mismo rango hacia atrás)
    // +1 día porque el rango actual es [desde, hasta] inclusive (hasta - desde + 1 días)
    const durMs = new Date(hasta) - new Date(desde) + 86400000;
    const prevHasta = toISO(new Date(new Date(desde) - 86400000));
    const prevDesde = toISO(new Date(new Date(desde) - durMs));
    api.get(`/reportes/resumen-periodo?desde=${prevDesde}&hasta=${prevHasta}`)
      .then(res => setPrev(res.data))
      .catch(() => setPrev(null));
  }, [desde, hasta]);

  if (!data) return null;

  const diasConVentas  = data.dias?.length ?? 0;
  const total          = parseFloat(data.total) || 0;
  const promedioDiario = diasConVentas > 0 ? total / diasConVentas : 0;
  const ticketMax      = parseFloat(data.venta_max) || 0;
  const numVentas      = parseInt(data.num_ventas, 10) || 0;

  const prevTotal    = prevData ? (parseFloat(prevData.total) || 0) : null;
  const prevDias     = prevData?.dias?.length ?? null;
  const prevNumVentas = prevData != null ? (parseInt(prevData.num_ventas, 10) || 0) : null;
  const pct          = pctChange(total, prevTotal);

  const kpis = [
    {
      icon: '💰',
      valor: `$${total.toLocaleString('es-MX', { minimumFractionDigits: 2 })}`,
      label: 'Total del período',
      pct,
    },
    {
      icon: '📅',
      valor: diasConVentas,
      label: 'Días con ventas',
      pct: pctChange(diasConVentas, prevDias),
    },
    {
      icon: '📊',
      valor: `$${promedioDiario.toFixed(2)}`,
      label: 'Promedio diario',
    },
    {
      icon: '🧾',
      valor: numVentas,
      label: 'Tickets registrados',
      pct: pctChange(numVentas, prevNumVentas),
    },
    {
      icon: '⬆️',
      valor: numVentas > 0 ? `$${ticketMax.toFixed(2)}` : '—',
      label: 'Ticket más alto',
      destacado: true,
    },
  ];

  return (
    <div className="kpis-grid">
      {kpis.map((k, i) => (
        <div key={i} className={`kpi-card${k.destacado ? ' kpi-destacado' : ''}`}>
          <span className="kpi-icon">{k.icon}</span>
          <p className="kpi-valor">{k.valor}</p>
          <p className="kpi-label">{k.label}</p>
          {k.pct != null && !k.destacado && (
            <p className={`kpi-cambio ${k.pct >= 0 ? 'kpi-sube' : 'kpi-baja'}`}>
              {k.pct >= 0 ? '▲' : '▼'} {Math.abs(k.pct).toFixed(1)}% vs período ant.
            </p>
          )}
        </div>
      ))}
    </div>
  );
};

export default KPIsReportes;
