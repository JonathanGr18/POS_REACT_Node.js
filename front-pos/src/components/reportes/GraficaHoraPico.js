import React, { useEffect, useMemo, useState } from 'react';
import api from '../../services/api';
import './GraficaHoraPico.css';

const GraficaHoraPico = ({ desde, hasta }) => {
  const [datos, setDatos] = useState([]);
  const [hoverIdx, setHoverIdx] = useState(null);

  useEffect(() => {
    if (!desde || !hasta) return;
    let cancelado = false;
    const params = `?desde=${desde}&hasta=${hasta}`;
    api.get(`/reportes/horas${params}`)
      .then(res => { if (!cancelado) setDatos(res.data); })
      .catch(() => { if (!cancelado) setDatos([]); });
    return () => { cancelado = true; };
  }, [desde, hasta]);

  const procesados = useMemo(() => {
    return datos.map(d => ({
      hora: Number(d.hora),
      ventas: Number(d.num_ventas) || 0,
      total: Number(d.total) || 0,
    }));
  }, [datos]);

  const totalPeriodo = procesados.reduce((a, d) => a + d.total, 0);
  const totalVentas = procesados.reduce((a, d) => a + d.ventas, 0);

  if (procesados.length === 0) return null;

  const maxVentas = Math.max(...procesados.map(d => d.ventas), 1);
  const picoIdx = procesados.reduce((mi, d, i) =>
    d.ventas > procesados[mi].ventas ? i : mi, 0);

  const fmtHora = (h) => {
    const period = h >= 12 ? 'pm' : 'am';
    const h12 = h % 12 || 12;
    return `${h12}${period}`;
  };

  const fmtRango = (h) =>
    `${String(h).padStart(2, '0')}:00 – ${String(h).padStart(2, '0')}:59`;

  const activo = hoverIdx != null ? procesados[hoverIdx] : null;

  return (
    <div className="ghp-card">
      <h3 className="ghp-titulo">Hora pico de ventas</h3>
      <div className="ghp-barras">
        {procesados.map((d, i) => {
          const pct = (d.ventas / maxVentas) * 100;
          const esPico = i === picoIdx;
          const esActivo = hoverIdx === i;
          return (
            <div
              key={d.hora}
              className={`ghp-col${esActivo ? ' ghp-col--activo' : ''}`}
              onMouseEnter={() => setHoverIdx(i)}
              onMouseLeave={() => setHoverIdx(null)}
            >
              {esActivo && (
                <div className="ghp-tooltip" role="tooltip">
                  <div className="ghp-tt-titulo">{fmtRango(d.hora)}</div>
                  <div className="ghp-tt-fila">
                    <span>Ventas</span>
                    <strong>{d.ventas}</strong>
                  </div>
                  <div className="ghp-tt-fila">
                    <span>Total</span>
                    <strong>${d.total.toFixed(2)}</strong>
                  </div>
                  <div className="ghp-tt-fila">
                    <span>Promedio</span>
                    <strong>${d.ventas > 0 ? (d.total / d.ventas).toFixed(2) : '0.00'}</strong>
                  </div>
                  <div className="ghp-tt-fila">
                    <span>% del período</span>
                    <strong>{totalVentas > 0 ? ((d.ventas / totalVentas) * 100).toFixed(1) : 0}%</strong>
                  </div>
                </div>
              )}
              <div className="ghp-barra-wrap">
                <div
                  className={`ghp-barra${esPico ? ' ghp-barra--pico' : ''}${esActivo ? ' ghp-barra--activo' : ''}`}
                  style={{ height: `${Math.max(pct, 3)}%` }}
                />
              </div>
              <span className={`ghp-label${esPico ? ' ghp-label--pico' : ''}`}>
                {fmtHora(d.hora)}
              </span>
              {esPico && <span className="ghp-pico-badge">pico</span>}
            </div>
          );
        })}
      </div>
      <p className="ghp-nota">
        {activo
          ? `${fmtRango(activo.hora)}: ${activo.ventas} ventas · $${activo.total.toFixed(2)}`
          : `${totalVentas} ventas · $${totalPeriodo.toFixed(2)}`}
      </p>
    </div>
  );
};

export default GraficaHoraPico;
