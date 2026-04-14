import React, { useEffect, useState } from 'react';
import api from '../../services/api';
import './GraficaMetodoPago.css';

const ICONOS = { efectivo: '💵', tarjeta: '💳', transferencia: '🏦' };
const COLORES = {
  efectivo:      'var(--boton-exito)',
  tarjeta:       'var(--boton-primario)',
  transferencia: '#f5a623',
};

const GraficaMetodoPago = ({ desde, hasta }) => {
  const [datos, setDatos] = useState([]);

  useEffect(() => {
    if (!desde || !hasta) return;
    let cancelado = false;
    setDatos([]);
    api.get(`/reportes/metodos-pago?desde=${desde}&hasta=${hasta}`)
      .then(res => { if (!cancelado) setDatos(res.data); })
      .catch(() => { if (!cancelado) setDatos([]); });
    return () => { cancelado = true; };
  }, [desde, hasta]);

  if (datos.length === 0) return null;

  const totalGeneral = datos.reduce((a, d) => a + Number(d.total), 0);

  return (
    <div className="gmp-card">
      <h3 className="gmp-titulo">Métodos de pago</h3>
      <div className="gmp-contenido">
        {/* Barras */}
        <div className="gmp-barras">
          {datos.map(d => {
            const total = Number(d.total);
            const pct = totalGeneral > 0 ? (total / totalGeneral) * 100 : 0;
            return (
              <div key={d.metodo_pago} className="gmp-fila">
                <span className="gmp-icono">{ICONOS[d.metodo_pago] || '💰'}</span>
                <span className="gmp-label">
                  {d.metodo_pago.charAt(0).toUpperCase() + d.metodo_pago.slice(1)}
                </span>
                <div className="gmp-barra-wrap">
                  <div
                    className="gmp-barra"
                    style={{
                      width: `${Math.max(pct, 2)}%`,
                      background: COLORES[d.metodo_pago] || 'var(--boton-secundario)',
                    }}
                  />
                </div>
                <span className="gmp-pct">{pct.toFixed(1)}%</span>
                <span className="gmp-monto">${total.toLocaleString('es-MX', { minimumFractionDigits: 0 })}</span>
                <span className="gmp-ventas">{d.num_ventas} vta{Number(d.num_ventas) !== 1 ? 's' : ''}</span>
              </div>
            );
          })}
        </div>
      </div>
    </div>
  );
};

export default GraficaMetodoPago;
