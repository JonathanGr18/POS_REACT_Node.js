import React, { useMemo } from 'react';
import './GraficaDiaSemana.css';

const DIAS = ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb'];
const DOW_MAP = [0, 1, 2, 3, 4, 5, 6]; // JS getDay: 0=Dom, 1=Lun...6=Sáb

const GraficaDiaSemana = ({ dias = [] }) => {
  const datos = useMemo(() => {
    const acum = DOW_MAP.map(() => ({ total: 0, count: 0 }));
    (dias || []).forEach(d => {
      const fecha = d.dia.slice(0, 10);
      const dow = new Date(fecha + 'T12:00:00').getDay();
      const idx = DOW_MAP.indexOf(dow);
      if (idx === -1) return;
      acum[idx].total += parseFloat(d.total_dia) || 0;
      acum[idx].count += 1;
    });
    return acum.map((a, i) => ({
      dia: DIAS[i],
      promedio: a.count > 0 ? a.total / a.count : 0,
      dias: a.count,
    }));
  }, [dias]);

  const maxProm = Math.max(...datos.map(d => d.promedio), 1);
  const mejorIdx = datos.reduce((mi, d, i) => d.promedio > datos[mi].promedio ? i : mi, 0);

  if (dias.length === 0) return null;

  return (
    <div className="gds-card">
      <h3 className="gds-titulo">Ventas por día de la semana</h3>
      <div className="gds-barras">
        {datos.map((d, i) => {
          const pct = maxProm > 0 ? (d.promedio / maxProm) * 100 : 0;
          const esMejor = i === mejorIdx && d.promedio > 0;
          return (
            <div key={i} className="gds-col">
              <div className="gds-barra-wrap">
                <div
                  className={`gds-barra${esMejor ? ' gds-barra--mejor' : ''}`}
                  style={{ height: `${Math.max(pct, 2)}%` }}
                  title={`${d.dia}: $${d.promedio.toFixed(0)} promedio (${d.dias} días)`}
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
      <p className="gds-nota">Promedio de ventas por día</p>
    </div>
  );
};

export default GraficaDiaSemana;
