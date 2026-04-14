import React, { useEffect, useState } from 'react';
import api from '../../services/api';
import './GraficaHoraPico.css';

const GraficaHoraPico = ({ desde, hasta }) => {
  const [datos, setDatos] = useState([]);

  useEffect(() => {
    if (!desde || !hasta) return;
    let cancelado = false;
    const params = `?desde=${desde}&hasta=${hasta}`;
    api.get(`/reportes/horas${params}`)
      .then(res => { if (!cancelado) setDatos(res.data); })
      .catch(() => { if (!cancelado) setDatos([]); });
    return () => { cancelado = true; };
  }, [desde, hasta]);

  if (datos.length === 0) return null;

  // Number() para evitar comparacion lexicografica de strings ("9" > "10" = true)
  const maxVentas = Math.max(...datos.map(d => Number(d.num_ventas) || 0), 1);
  const picoIdx = datos.reduce((mi, d, i) =>
    (Number(d.num_ventas) || 0) > (Number(datos[mi].num_ventas) || 0) ? i : mi, 0);

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
          const numV = Number(d.num_ventas) || 0;
          const pct = (numV / maxVentas) * 100;
          const esPico = i === picoIdx;
          return (
            <div key={d.hora} className="ghp-col">
              <div className="ghp-barra-wrap">
                <div
                  className={`ghp-barra${esPico ? ' ghp-barra--pico' : ''}`}
                  style={{ height: `${Math.max(pct, 3)}%` }}
                  title={`${fmtHora(d.hora)}: ${numV} ventas ($${parseFloat(d.total).toFixed(0)})`}
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
