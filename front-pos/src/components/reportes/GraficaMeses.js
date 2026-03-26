import React, { useEffect, useState } from 'react';
import api from '../../services/api';
import Spinner from '../ui/Spinner';
import './GraficaMeses.css';

const MESES = ['Ene','Feb','Mar','Abr','May','Jun','Jul','Ago','Sep','Oct','Nov','Dic'];

const GraficaMeses = () => {
  const [datos, setDatos] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    api.get('/reportes/meses-resumen')
      .then(res => setDatos(res.data))
      .catch(() => setDatos([]))
      .finally(() => setLoading(false));
  }, []);

  if (loading) {
    return (
      <div className="grafica-meses-card">
        <Spinner texto="Cargando gráfica..." />
      </div>
    );
  }

  if (datos.length === 0) return null;

  const maxValor = Math.max(...datos.map(d => parseFloat(d.total_mes) || 0), 1);
  const alturaMax = 170;
  const anchoBarra = 38;
  const anchoEgreso = 14; // barra delgada de egresos a la derecha
  const gap = 14;
  const paddingLeft = 58;
  const paddingTop = 28;
  const paddingBottom = 38;
  const svgAncho = paddingLeft + datos.length * (anchoBarra + gap) + 20;
  const svgAlto = alturaMax + paddingTop + paddingBottom;

  const mesActual = new Date().toISOString().slice(0, 7);
  const niveles = [0, 0.25, 0.5, 0.75, 1];

  const totalSum = datos.reduce((a, d) => a + (parseFloat(d.total_mes) || 0), 0);
  const promedio = totalSum / datos.length;
  const promedioY = paddingTop + alturaMax - Math.round((promedio / maxValor) * alturaMax);

  return (
    <div className="grafica-meses-card">
      <div className="grafica-meses-top">
        <h3 className="grafica-meses-titulo">Comparativa mensual</h3>
        <span className="grafica-meses-sub">Últimos 12 meses</span>
      </div>

      <div className="grafica-meses-scroll">
        <svg width={svgAncho} height={svgAlto}>
          {/* Líneas guía Y */}
          {niveles.map((f, i) => {
            const y = paddingTop + alturaMax * (1 - f);
            const val = maxValor * f;
            return (
              <g key={i}>
                <line
                  x1={paddingLeft} y1={y}
                  x2={svgAncho - 10} y2={y}
                  stroke="var(--fondo-borde)"
                  strokeDasharray="3,4"
                  strokeWidth="1"
                />
                <text
                  x={paddingLeft - 6} y={y + 4}
                  textAnchor="end" fontSize="9"
                  fill="var(--texto-secundario)"
                >
                  ${val >= 1000 ? `${(val / 1000).toFixed(0)}k` : Math.round(val)}
                </text>
              </g>
            );
          })}

          {/* Línea promedio */}
          {promedio > 0 && (
            <g>
              <line
                x1={paddingLeft} y1={promedioY}
                x2={svgAncho - 10} y2={promedioY}
                stroke="#f5a623"
                strokeDasharray="5,4"
                strokeWidth="1.5"
              />
              <text
                x={svgAncho - 8} y={promedioY - 3}
                fontSize="8" fill="#f5a623"
                textAnchor="end"
              >
                prom
              </text>
            </g>
          )}

          {/* Barras */}
          {datos.map((d, i) => {
            const val = parseFloat(d.total_mes) || 0;
            const altura = Math.max(Math.round((val / maxValor) * alturaMax), val > 0 ? 3 : 0);
            const x = paddingLeft + i * (anchoBarra + gap);
            const y = paddingTop + alturaMax - altura;
            const [yearStr, mesStr] = d.mes.split('-');
            const esActual = d.mes === mesActual;
            const fill = esActual ? 'var(--boton-primario)' : 'var(--boton-secundario)';

            return (
              <g key={d.mes}>
                {/* Barra egresos (fondo, más ancha) */}
                {(() => {
                  const egr = parseFloat(d.total_egresos) || 0;
                  if (egr <= 0) return null;
                  const hEgr = Math.max(Math.round((egr / maxValor) * alturaMax), 3);
                  return (
                    <rect x={x} y={paddingTop + alturaMax - hEgr}
                      width={anchoBarra} height={hEgr} rx={5}
                      fill="var(--boton-peligro)" opacity={0.25}>
                      <title>Egresos: ${egr.toFixed(2)}</title>
                    </rect>
                  );
                })()}
                {/* Barra ingresos */}
                <rect
                  x={x} y={y}
                  width={anchoBarra} height={altura}
                  rx={5}
                  fill={fill}
                  opacity={esActual ? 1 : 0.7}
                >
                  <title>{MESES[parseInt(mesStr) - 1]} {yearStr}: ${val.toFixed(2)}</title>
                </rect>

                {val > 0 && altura > 22 && (
                  <text
                    x={x + anchoBarra / 2} y={y - 5}
                    textAnchor="middle" fontSize="8"
                    fill="var(--texto-secundario)"
                  >
                    ${val >= 1000 ? `${(val / 1000).toFixed(1)}k` : Math.round(val)}
                  </text>
                )}

                <text
                  x={x + anchoBarra / 2}
                  y={paddingTop + alturaMax + 14}
                  textAnchor="middle" fontSize="10"
                  fill={esActual ? 'var(--boton-primario)' : 'var(--texto-secundario)'}
                  fontWeight={esActual ? '700' : '400'}
                >
                  {MESES[parseInt(mesStr) - 1]}
                </text>
                <text
                  x={x + anchoBarra / 2}
                  y={paddingTop + alturaMax + 27}
                  textAnchor="middle" fontSize="8"
                  fill="var(--texto-secundario)"
                >
                  {yearStr}
                </text>
              </g>
            );
          })}

          {/* Línea base */}
          <line
            x1={paddingLeft} y1={paddingTop + alturaMax}
            x2={svgAncho - 10} y2={paddingTop + alturaMax}
            stroke="var(--fondo-borde)"
            strokeWidth="1"
          />
        </svg>
      </div>

      <div className="grafica-meses-leyenda">
        <span className="leyenda-item">
          <span className="leyenda-dot" style={{ background: 'var(--boton-primario)' }} />
          Mes actual
        </span>
        <span className="leyenda-item">
          <span className="leyenda-dot" style={{ background: 'var(--boton-secundario)', opacity: 0.7 }} />
          Meses anteriores
        </span>
        <span className="leyenda-item">
          <span className="leyenda-dot" style={{ background: 'var(--boton-peligro)', opacity: 0.4 }} />
          Egresos
        </span>
        <span className="leyenda-item">
          <span className="leyenda-linea" style={{ background: '#f5a623' }} />
          Promedio
        </span>
      </div>
    </div>
  );
};

export default GraficaMeses;
