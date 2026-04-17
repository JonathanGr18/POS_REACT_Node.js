import React, { useMemo, useState } from 'react';
import './GraficaDiaSemana.css';

const DIAS = ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb'];
const DIAS_LARGO = ['Domingo', 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado'];
const DOW_MAP = [0, 1, 2, 3, 4, 5, 6];

const GraficaDiaSemana = ({ dias = [] }) => {
  const [hoverIdx, setHoverIdx] = useState(null);

  const datos = useMemo(() => {
    const acum = DOW_MAP.map(() => ({ total: 0, count: 0, ventas: 0 }));
    (dias || []).forEach(d => {
      const fecha = d.dia.slice(0, 10);
      const dow = new Date(fecha + 'T12:00:00').getDay();
      const idx = DOW_MAP.indexOf(dow);
      if (idx === -1) return;
      acum[idx].total += parseFloat(d.total_dia) || 0;
      acum[idx].count += 1;
      acum[idx].ventas += Number(d.num_ventas) || 0;
    });
    return acum.map((a, i) => ({
      dia: DIAS[i],
      diaLargo: DIAS_LARGO[i],
      total: a.total,
      promedio: a.count > 0 ? a.total / a.count : 0,
      dias: a.count,
      ventas: a.ventas,
    }));
  }, [dias]);

  const maxProm = Math.max(...datos.map(d => d.promedio), 1);
  const mejorIdx = datos.reduce((mi, d, i) => d.promedio > datos[mi].promedio ? i : mi, 0);

  if (dias.length === 0) return null;

  const activo = hoverIdx != null ? datos[hoverIdx] : null;

  return (
    <div className="gds-card">
      <h3 className="gds-titulo">Ventas por día de la semana</h3>
      <div className="gds-barras">
        {datos.map((d, i) => {
          const pct = maxProm > 0 ? (d.promedio / maxProm) * 100 : 0;
          const esMejor = i === mejorIdx && d.promedio > 0;
          const esActivo = hoverIdx === i;
          return (
            <div
              key={i}
              className={`gds-col${esActivo ? ' gds-col--activo' : ''}`}
              onMouseEnter={() => setHoverIdx(i)}
              onMouseLeave={() => setHoverIdx(null)}
            >
              {esActivo && (
                <div className="gds-tooltip" role="tooltip">
                  <div className="gds-tt-titulo">{d.diaLargo}</div>
                  <div className="gds-tt-fila">
                    <span>Promedio</span>
                    <strong>${d.promedio.toFixed(2)}</strong>
                  </div>
                  <div className="gds-tt-fila">
                    <span>Total</span>
                    <strong>${d.total.toFixed(2)}</strong>
                  </div>
                  <div className="gds-tt-fila">
                    <span>Días registrados</span>
                    <strong>{d.dias}</strong>
                  </div>
                  <div className="gds-tt-fila">
                    <span>Ventas totales</span>
                    <strong>{d.ventas}</strong>
                  </div>
                </div>
              )}
              <div className="gds-barra-wrap">
                <div
                  className={`gds-barra${esMejor ? ' gds-barra--mejor' : ''}${esActivo ? ' gds-barra--activo' : ''}`}
                  style={{ height: `${Math.max(pct, 2)}%` }}
                />
              </div>
              <span className="gds-valor">
                {d.promedio > 0 ? `$${d.promedio >= 1000 ? `${(d.promedio/1000).toFixed(1)}k` : Math.round(d.promedio)}` : '—'}
              </span>
              <span className={`gds-label${esMejor ? ' gds-label--mejor' : ''}`}>{d.dia}</span>
              {esMejor && <span className="gds-crown">★</span>}
            </div>
          );
        })}
      </div>
      <p className="gds-nota">
        {activo
          ? `${activo.diaLargo}: $${activo.promedio.toFixed(2)} promedio · ${activo.ventas} ventas en ${activo.dias} día(s)`
          : 'Pasa el mouse sobre una barra para ver detalles'}
      </p>
    </div>
  );
};

export default GraficaDiaSemana;
