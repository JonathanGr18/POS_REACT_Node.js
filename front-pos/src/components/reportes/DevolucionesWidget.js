import React, { useEffect, useState } from 'react';
import api from '../../services/api';
import './DevolucionesWidget.css';

const DevolucionesWidget = ({ desde, hasta }) => {
  const [data, setData] = useState(null);
  const [expandido, setExpandido] = useState(false);
  const [detalleAbierto, setDetalleAbierto] = useState(null); // id del item con detalle desplegado

  useEffect(() => {
    if (!desde || !hasta) return;
    let cancelado = false;
    api.get(`/reportes/devoluciones?desde=${desde}&hasta=${hasta}`)
      .then(res => { if (!cancelado) setData(res.data); })
      .catch(() => { if (!cancelado) setData({ resumen: { total_devoluciones: 0, monto_total: 0, anulaciones: 0, ediciones: 0 }, lista: [] }); });
    return () => { cancelado = true; };
  }, [desde, hasta]);

  if (!data) return null;

  const { resumen, lista } = data;
  const vacio = resumen.total_devoluciones === 0;
  const fmtFecha = (iso) => {
    try {
      return new Date(iso).toLocaleString('es-MX', {
        day: '2-digit', month: 'short', hour: '2-digit', minute: '2-digit',
      });
    } catch { return iso; }
  };

  return (
    <div className={`dev-card${vacio ? ' dev-card--vacio' : ''}`}>
      <div
        className="dev-header"
        onClick={() => !vacio && setExpandido(v => !v)}
        style={vacio ? { cursor: 'default' } : undefined}
      >
        <span className="dev-titulo">
          💸 Devoluciones del período
        </span>
        <div className="dev-stats">
          <span className="dev-chip dev-chip--total">
            {resumen.total_devoluciones}
          </span>
          <span className="dev-monto">
            ${Number(resumen.monto_total).toFixed(2)}
          </span>
          {!vacio && <span className="dev-chevron">{expandido ? '▲' : '▼'}</span>}
        </div>
      </div>

      {vacio && (
        <p className="dev-vacio">Sin devoluciones en este período</p>
      )}

      {!vacio && expandido && (
        <div className="dev-body">
          <div className="dev-resumen">
            {resumen.anulaciones > 0 && (
              <span className="dev-chip dev-chip--anulacion">
                🗑 {resumen.anulaciones} anulación{resumen.anulaciones !== 1 ? 'es' : ''}
              </span>
            )}
            {resumen.ediciones > 0 && (
              <span className="dev-chip dev-chip--edicion">
                ✏️ {resumen.ediciones} edición{resumen.ediciones !== 1 ? 'es' : ''}
              </span>
            )}
          </div>

          <ul className="dev-lista">
            {lista.map(d => {
              const abierto = detalleAbierto === d.id;
              // productos: puede ser array (anulacion) u objeto { antes, despues } (edicion)
              const snap = d.productos || {};
              const esEdicion = d.tipo === 'edicion' && snap.antes && snap.despues;
              const listaProds = esEdicion ? null : (Array.isArray(snap) ? snap : []);
              return (
                <li key={d.id} className={`dev-item dev-item--${d.tipo}`}>
                  <div
                    className="dev-item-principal"
                    onClick={() => setDetalleAbierto(abierto ? null : d.id)}
                    role="button"
                  >
                    <div className="dev-item-izq">
                      <span className={`dev-tipo ${d.tipo}`}>
                        {d.tipo === 'anulacion' ? '🗑 Anulación' : '✏️ Edición'}
                      </span>
                      {d.venta_id && (
                        <span className="dev-venta">Venta #{String(d.venta_id).padStart(4, '0')}</span>
                      )}
                      <span className="dev-fecha">{fmtFecha(d.fecha)}</span>
                    </div>
                    <div className="dev-item-der">
                      <span className="dev-item-monto">
                        ${Math.abs(Number(d.monto)).toFixed(2)}
                      </span>
                      <span className="dev-item-chevron">{abierto ? '▲' : '▼'}</span>
                    </div>
                  </div>
                  {d.motivo && (
                    <p className="dev-motivo" title={d.motivo}>
                      "{d.motivo}"
                    </p>
                  )}

                  {/* Detalle expandible */}
                  {abierto && (
                    <div className="dev-detalle">
                      {esEdicion ? (
                        <div className="dev-diff">
                          <div className="dev-diff-col">
                            <h5>Antes</h5>
                            <ul>
                              {(snap.antes || []).map((p, i) => (
                                <li key={i}>
                                  {p.cantidad}× {p.nombre || p.producto} — ${Number(p.precio).toFixed(2)}
                                </li>
                              ))}
                            </ul>
                          </div>
                          <div className="dev-diff-flecha" aria-hidden="true">→</div>
                          <div className="dev-diff-col">
                            <h5>Después</h5>
                            <ul>
                              {(snap.despues || []).map((p, i) => (
                                <li key={i}>
                                  {p.cantidad}× {p.nombre || p.producto} — ${Number(p.precio).toFixed(2)}
                                </li>
                              ))}
                            </ul>
                          </div>
                        </div>
                      ) : (
                        <div className="dev-productos-anulados">
                          <h5>Productos devueltos al stock</h5>
                          {listaProds && listaProds.length > 0 ? (
                            <ul>
                              {listaProds.map((p, i) => (
                                <li key={i}>
                                  <span className="dev-prod-cant">{p.cantidad}×</span>
                                  <span className="dev-prod-nombre">{p.nombre || p.producto}</span>
                                  <span className="dev-prod-precio">
                                    ${Number(p.precio).toFixed(2)} c/u · ${(Number(p.precio) * Number(p.cantidad)).toFixed(2)}
                                  </span>
                                </li>
                              ))}
                            </ul>
                          ) : (
                            <p className="dev-sin-detalle">Sin detalle de productos</p>
                          )}
                        </div>
                      )}
                    </div>
                  )}
                </li>
              );
            })}
          </ul>
        </div>
      )}
    </div>
  );
};

export default DevolucionesWidget;
