import React, { useEffect, useState } from 'react';
import api from '../../services/api';
import Spinner from '../ui/Spinner';
import './TopProductos.css';

const TopProductos = ({ desde, hasta }) => {
  const [productos, setProductos] = useState([]);
  const [cargando, setCargando] = useState(true);

  useEffect(() => {
    let cancelado = false;
    setCargando(true);
    setProductos([]); // Reset mientras carga
    const params = desde && hasta ? `?desde=${desde}&hasta=${hasta}` : '';
    api.get(`/reportes/top-productos${params}`)
      .then(res => { if (!cancelado) setProductos(res.data); })
      .catch(() => { if (!cancelado) setProductos([]); })
      .finally(() => { if (!cancelado) setCargando(false); });
    return () => { cancelado = true; };
  }, [desde, hasta]);

  if (cargando) return <Spinner texto="Cargando top productos..." />;
  if (productos.length === 0) return <p style={{ textAlign: 'center', color: 'var(--texto-secundario)' }}>Sin datos</p>;

  const maxUnidades = Math.max(...productos.map(p => parseInt(p.total_unidades) || 0), 1);

  return (
    <div className="top-productos">
      <h3 className="top-productos-titulo">🏆 Productos más vendidos</h3>
      <div className="top-lista">
        {productos.map((p, i) => {
          const pct = Math.round((parseInt(p.total_unidades) / maxUnidades) * 100);
          return (
            <div key={p.producto} className="top-item">
              <span className="top-rank">{i + 1}</span>
              <div className="top-info">
                <div className="top-nombre-row">
                  <span className="top-nombre">{p.producto}</span>
                  <span className="top-unidades">{p.total_unidades} uds</span>
                </div>
                <div className="top-barra-bg">
                  <div className="top-barra-fill" style={{ width: `${pct}%` }} />
                </div>
              </div>
              <span className="top-ingreso">${parseFloat(p.total_ingresos).toFixed(2)}</span>
            </div>
          );
        })}
      </div>
    </div>
  );
};

export default TopProductos;
