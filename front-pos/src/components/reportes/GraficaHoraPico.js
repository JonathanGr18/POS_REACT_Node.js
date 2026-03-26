import React, { useEffect, useState } from 'react';
import api from '../../services/api';
import './GraficaHoraPico.css';

const GraficaHoraPico = ({ desde, hasta }) => {
  const [datos, setDatos] = useState([]);

  useEffect(() => {
    if (!desde || !hasta) return;
    const params = `?desde=${desde}&hasta=${hasta}`;
    api.get(`/reportes/horas${params}`)
      .then(res => setDatos(res.data))
      .catch(() => setDatos([]));
  }, [desde, hasta]);

  if (datos.length === 0) return null;

  const maxVentas = Math.max(...datos.map(d => d.num_ventas), 1);
  const picoIdx = datos.reduce((mi, d, i) => d.num_ventas > datos[mi].num_ventas ? i : mi, 0);

  const fmtHora = (h) => {
    const period = h >= 12 ? 'pm' : 'am';
    const h12 = h % 12 || 12;
    return `${h12}${period}`;
  };

  return (
    <div className="ghp-card">
      <h3 className="ghp-titulo">Hora pico de ventas</h3>
      <div className="ghp-barras">
        {datos.map((d, i) => {
          const pct = (d.num_ventas / maxVentas) * 100;
          const esPico = i === picoIdx;
          return (
            <div key={d.hora} className="ghp-col">
              <div className="ghp-barra-wrap">
                <div
                  className={`ghp-barra${esPico ? ' ghp-barra--pico' : ''}`}
                  style={{ height: `${Math.max(pct, 3)}%` }}
                  title={`${fmtHora(d.hora)}: ${d.num_ventas} ventas ($${parseFloat(d.total).toFixed(0)})`}
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
      <p className="ghp-nota">Número de ventas por hora del día</p>
    </div>
  );
};

export default GraficaHoraPico;
