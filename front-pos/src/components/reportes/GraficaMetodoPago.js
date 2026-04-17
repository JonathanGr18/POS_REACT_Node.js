import React, { useEffect, useMemo, useState } from 'react';
import api from '../../services/api';
import './GraficaMetodoPago.css';

const META = {
  efectivo:      { icono: '💵', label: 'Efectivo',      color: 'var(--boton-exito)' },
  tarjeta:       { icono: '💳', label: 'Tarjeta',       color: 'var(--boton-primario)' },
  transferencia: { icono: '🏦', label: 'Transferencia', color: '#f5a623' },
};

const GraficaMetodoPago = ({ desde, hasta }) => {
  const [datos, setDatos] = useState([]);
  const [hoverIdx, setHoverIdx] = useState(null);

  useEffect(() => {
    if (!desde || !hasta) return;
    let cancelado = false;
    setDatos([]);
    api.get(`/reportes/metodos-pago?desde=${desde}&hasta=${hasta}`)
      .then(res => { if (!cancelado) setDatos(res.data); })
      .catch(() => { if (!cancelado) setDatos([]); });
    return () => { cancelado = true; };
  }, [desde, hasta]);

  const procesados = useMemo(() => {
    const total = datos.reduce((a, d) => a + Number(d.total), 0);
    return datos.map(d => {
      const monto = Number(d.total) || 0;
      const meta = META[d.metodo_pago] || { icono: '💰', label: d.metodo_pago, color: 'var(--boton-secundario)' };
      return {
        clave: d.metodo_pago,
        ...meta,
        monto,
        pct: total > 0 ? (monto / total) * 100 : 0,
        ventas: Number(d.num_ventas) || 0,
      };
    });
  }, [datos]);

  if (procesados.length === 0) return null;

  const maxMonto = Math.max(...procesados.map(d => d.monto), 1);
  const mejorIdx = procesados.reduce((mi, d, i) => d.monto > procesados[mi].monto ? i : mi, 0);
  const activo = hoverIdx != null ? procesados[hoverIdx] : null;
  const totalGeneral = procesados.reduce((a, d) => a + d.monto, 0);

  return (
    <div className="gmp-card">
      <h3 className="gmp-titulo">Métodos de pago</h3>
      <div className="gmp-barras">
        {procesados.map((d, i) => {
          const pct = (d.monto / maxMonto) * 100;
          const esMejor = i === mejorIdx && d.monto > 0;
          const esActivo = hoverIdx === i;
          return (
            <div
              key={d.clave}
              className={`gmp-col${esActivo ? ' gmp-col--activo' : ''}`}
              onMouseEnter={() => setHoverIdx(i)}
              onMouseLeave={() => setHoverIdx(null)}
            >
              {esActivo && (
                <div className="gmp-tooltip" role="tooltip">
                  <div className="gmp-tt-titulo">{d.icono} {d.label}</div>
                  <div className="gmp-tt-fila">
                    <span>Total</span>
                    <strong>${d.monto.toFixed(2)}</strong>
                  </div>
                  <div className="gmp-tt-fila">
                    <span>Porcentaje</span>
                    <strong>{d.pct.toFixed(1)}%</strong>
                  </div>
                  <div className="gmp-tt-fila">
                    <span>Num. ventas</span>
                    <strong>{d.ventas}</strong>
                  </div>
                  <div className="gmp-tt-fila">
                    <span>Promedio</span>
                    <strong>${d.ventas > 0 ? (d.monto / d.ventas).toFixed(2) : '0.00'}</strong>
                  </div>
                </div>
              )}
              <div className="gmp-barra-wrap">
                <div
                  className={`gmp-barra${esMejor ? ' gmp-barra--mejor' : ''}${esActivo ? ' gmp-barra--activo' : ''}`}
                  style={{
                    height: `${Math.max(pct, 2)}%`,
                    background: d.color,
                  }}
                />
              </div>
              <span className="gmp-valor">
                {d.monto > 0
                  ? `$${d.monto >= 1000 ? `${(d.monto/1000).toFixed(1)}k` : Math.round(d.monto)}`
                  : '—'}
              </span>
              <span className="gmp-label-icono">
                <span className="gmp-icono" aria-hidden="true">{d.icono}</span>
                <span className={`gmp-label${esMejor ? ' gmp-label--mejor' : ''}`}>{d.label}</span>
              </span>
              {esMejor && <span className="gmp-crown">★</span>}
            </div>
          );
        })}
      </div>
      <p className="gmp-nota">
        {activo
          ? `${activo.label}: $${activo.monto.toFixed(2)} · ${activo.pct.toFixed(1)}% · ${activo.ventas} venta(s)`
          : `Total: $${totalGeneral.toFixed(2)} · ${procesados.reduce((a, d) => a + d.ventas, 0)} ventas`}
      </p>
    </div>
  );
};

export default GraficaMetodoPago;
