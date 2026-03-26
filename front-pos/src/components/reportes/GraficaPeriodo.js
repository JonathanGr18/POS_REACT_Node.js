import React, { useMemo } from 'react';
import './GraficaPeriodo.css';

const GraficaPeriodo = ({ dias = [] }) => {
  const datos = useMemo(() => {
    return [...(dias || [])]
      .map(d => ({ fecha: d.dia.slice(0, 10), total: parseFloat(d.total_dia) || 0 }))
      .sort((a, b) => a.fecha.localeCompare(b.fecha));
  }, [dias]);

  if (datos.length < 2) return null;

  // Dimensiones del SVG
  const W = 900;
  const H = 220;
  const padL = 58;
  const padR = 20;
  const padT = 24;
  const padB = 36;
  const gW = W - padL - padR;
  const gH = H - padT - padB;

  const maxValor = Math.max(...datos.map(d => d.total), 1);
  const n = datos.length;

  // Posición X de cada punto
  const xOf = (i) => padL + (i / (n - 1)) * gW;
  // Posición Y de cada punto
  const yOf = (v) => padT + gH - (v / maxValor) * gH;

  // Línea SVG
  const puntos = datos.map((d, i) => `${xOf(i).toFixed(1)},${yOf(d.total).toFixed(1)}`);
  const linePath = `M ${puntos.join(' L ')}`;

  // Área de relleno (cierra abajo)
  const areaPath = `${linePath} L ${xOf(n - 1).toFixed(1)},${(padT + gH).toFixed(1)} L ${padL},${(padT + gH).toFixed(1)} Z`;

  // Línea de promedio
  const promedio = datos.reduce((a, d) => a + d.total, 0) / n;
  const promY = yOf(promedio).toFixed(1);

  // Etiquetas eje Y (5 niveles)
  const nivelesY = [0, 0.25, 0.5, 0.75, 1].map(f => ({
    val: maxValor * f,
    y: yOf(maxValor * f),
  }));

  // Etiquetas eje X — mostrar solo algunas fechas para no saturar
  const paso = Math.max(1, Math.floor(n / 8));
  const etiquetasX = datos
    .map((d, i) => ({ ...d, i }))
    .filter((_, i) => i % paso === 0 || i === n - 1);

  // Formato fecha corto
  const fmtFecha = (iso) => {
    const d = new Date(iso + 'T12:00:00');
    return d.toLocaleDateString('es-MX', { day: 'numeric', month: 'short' });
  };

  // Punto máximo
  const maxIdx = datos.reduce((mi, d, i) => d.total > datos[mi].total ? i : mi, 0);

  return (
    <div className="grafica-periodo-card">
      <div className="grafica-periodo-top">
        <h3 className="grafica-periodo-titulo">Ventas diarias del período</h3>
        <div className="grafica-periodo-leyenda">
          <span className="gp-ley-item">
            <span className="gp-ley-linea" style={{ background: 'var(--boton-primario)' }} />
            Ventas por día
          </span>
          <span className="gp-ley-item">
            <span className="gp-ley-linea gp-ley-dash" style={{ background: '#f5a623' }} />
            Promedio
          </span>
        </div>
      </div>

      <div className="grafica-periodo-scroll">
        <svg viewBox={`0 0 ${W} ${H}`} className="grafica-periodo-svg">
          <defs>
            <linearGradient id="areaGrad" x1="0" y1="0" x2="0" y2="1">
              <stop offset="0%" stopColor="var(--boton-primario)" stopOpacity="0.25" />
              <stop offset="100%" stopColor="var(--boton-primario)" stopOpacity="0.02" />
            </linearGradient>
          </defs>

          {/* Líneas guía Y */}
          {nivelesY.map((n, i) => (
            <g key={i}>
              <line
                x1={padL} y1={n.y}
                x2={W - padR} y2={n.y}
                stroke="var(--fondo-borde)"
                strokeDasharray="3,4"
                strokeWidth="1"
              />
              <text
                x={padL - 6} y={n.y + 4}
                textAnchor="end" fontSize="10"
                fill="var(--texto-secundario)"
              >
                ${n.val >= 1000 ? `${(n.val / 1000).toFixed(0)}k` : Math.round(n.val)}
              </text>
            </g>
          ))}

          {/* Línea base */}
          <line
            x1={padL} y1={padT + gH}
            x2={W - padR} y2={padT + gH}
            stroke="var(--fondo-borde)"
            strokeWidth="1"
          />

          {/* Área de relleno */}
          <path d={areaPath} fill="url(#areaGrad)" />

          {/* Línea principal */}
          <path
            d={linePath}
            fill="none"
            stroke="var(--boton-primario)"
            strokeWidth="2.5"
            strokeLinejoin="round"
            strokeLinecap="round"
          />

          {/* Línea de promedio */}
          <line
            x1={padL} y1={promY}
            x2={W - padR} y2={promY}
            stroke="#f5a623"
            strokeWidth="1.5"
            strokeDasharray="6,4"
          />
          <text
            x={W - padR - 2} y={parseFloat(promY) - 5}
            textAnchor="end" fontSize="9"
            fill="#f5a623"
          >
            prom ${Math.round(promedio).toLocaleString('es-MX')}
          </text>

          {/* Puntos en la línea (solo si pocos días) */}
          {n <= 40 && datos.map((d, i) => (
            <circle
              key={i}
              cx={xOf(i)} cy={yOf(d.total)}
              r={i === maxIdx ? 5 : 3}
              fill={i === maxIdx ? '#f5a623' : 'var(--boton-primario)'}
              stroke="var(--fondo-tarjeta)"
              strokeWidth="1.5"
            >
              <title>{d.fecha}: ${d.total.toFixed(2)}</title>
            </circle>
          ))}

          {/* Marcador del día máximo */}
          {(() => {
            const mx = datos[maxIdx];
            const cx = xOf(maxIdx);
            const cy = yOf(mx.total);
            return (
              <g>
                <line
                  x1={cx} y1={cy - 8}
                  x2={cx} y2={padT}
                  stroke="#f5a623"
                  strokeWidth="1"
                  strokeDasharray="3,3"
                />
                <rect
                  x={cx - 34} y={padT - 16}
                  width={68} height={16}
                  rx={4}
                  fill="#f5a623"
                />
                <text
                  x={cx} y={padT - 4}
                  textAnchor="middle"
                  fontSize="9" fontWeight="700"
                  fill="#fff"
                >
                  ${mx.total.toLocaleString('es-MX')} — {fmtFecha(mx.fecha)}
                </text>
              </g>
            );
          })()}

          {/* Etiquetas eje X */}
          {etiquetasX.map(({ fecha, i }) => (
            <text
              key={i}
              x={xOf(i)} y={padT + gH + 16}
              textAnchor="middle"
              fontSize="9"
              fill="var(--texto-secundario)"
            >
              {fmtFecha(fecha)}
            </text>
          ))}
        </svg>
      </div>
    </div>
  );
};

export default GraficaPeriodo;
