import React, { useEffect, useState } from 'react';
import api from '../../services/api';
import './KPIsReportes.css';

// Formato YYYY-MM-DD en zona local (evita off-by-one en TZ negativas)
const toISO = (date) => {
  const y = date.getFullYear();
  const m = String(date.getMonth() + 1).padStart(2, '0');
  const d = String(date.getDate()).padStart(2, '0');
  return `${y}-${m}-${d}`;
};

const pctChange = (actual, anterior) => {
  if (!anterior || anterior === 0) return null;
  return ((actual - anterior) / anterior) * 100;
};

const KPIsReportes = ({ desde, hasta }) => {
  const [data, setData]     = useState(null);
  const [prevData, setPrev] = useState(null);

  useEffect(() => {
    if (!desde || !hasta) return;
    let cancelado = false;
    setData(null);
    setPrev(null);

    // Período actual
    api.get(`/reportes/resumen-periodo?desde=${desde}&hasta=${hasta}`)
      .then(res => { if (!cancelado) setData(res.data); })
      .catch(() => { if (!cancelado) setData(null); });

    // Período anterior (usar T12:00:00 para evitar problemas de TZ)
    const desdeD = new Date(desde + 'T12:00:00');
    const hastaD = new Date(hasta + 'T12:00:00');
    const durMs = hastaD - desdeD + 86400000;
    const prevHasta = toISO(new Date(desdeD.getTime() - 86400000));
    const prevDesde = toISO(new Date(desdeD.getTime() - durMs));
    api.get(`/reportes/resumen-periodo?desde=${prevDesde}&hasta=${prevHasta}`)
      .then(res => { if (!cancelado) setPrev(res.data); })
      .catch(() => { if (!cancelado) setPrev(null); });

    return () => { cancelado = true; };
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
