import React, { useEffect, useState, useMemo } from 'react';
import api from '../../services/api';
import './HeatmapAnual.css';

const DIAS_LABEL = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
const MESES_CORTOS = ['Ene','Feb','Mar','Abr','May','Jun','Jul','Ago','Sep','Oct','Nov','Dic'];

const toISO = (d) => d.toISOString().slice(0, 10);

const COLORES = [
  'var(--fondo-borde)',
  '#e8d5f5',
  '#c49ee8',
  '#9967CE',
  '#7c4cb5',
  '#5c3a8a',
];

const getColor = (total, maxValor, esFuturo) => {
  if (esFuturo) return 'transparent';
  if (!total || total === 0) return COLORES[0];
  const pct = total / maxValor;
  if (pct < 0.15) return COLORES[1];
  if (pct < 0.35) return COLORES[2];
  if (pct < 0.60) return COLORES[3];
  if (pct < 0.85) return COLORES[4];
  return COLORES[5];
};

// Calcula el lunes de inicio del heatmap (52 semanas atrás desde hoy)
const calcularInicio = () => {
  const hoy = new Date();
  // Retroceder exactamente 1 año calendario (maneja años bisiestos correctamente)
  const inicio = new Date(hoy);
  inicio.setFullYear(inicio.getFullYear() - 1);
  // Alinear al lunes de esa semana
  const dow = inicio.getDay();
  const diasARestar = dow === 0 ? 6 : dow - 1;
  inicio.setDate(inicio.getDate() - diasARestar);
  return inicio;
};

const HeatmapAnual = () => {
  const [mapaVentas, setMapaVentas] = useState({});
  const [maxValor, setMaxValor] = useState(1);

  useEffect(() => {
    const hoy = new Date();
    const hasta = toISO(hoy);
    // El fetch cubre desde el lunes alineado para que no haya celdas sin datos
    const inicio = calcularInicio();
    const desde = toISO(inicio);
    api.get(`/reportes/dias-filtrado?desde=${desde}&hasta=${hasta}`)
      .then(res => {
        const mapa = {};
        res.data.forEach(d => {
          mapa[d.dia.slice(0, 10)] = parseFloat(d.total_dia);
        });
        setMapaVentas(mapa);
        const vals = Object.values(mapa);
        setMaxValor(vals.length > 0 ? Math.max(...vals) : 1);
      })
      .catch(() => {});
  }, []);

  const { semanas, mesesLabel } = useMemo(() => {
    const hoy = new Date();
    const todayISO = toISO(hoy);
    const inicio = calcularInicio();
    const semanasArr = [];
    const mesesArr = [];
    // Usar fecha ISO string para iterar y evitar problemas de DST
    let currISO = toISO(inicio);
    let semIdx = 0;

    const addDays = (iso, n) => {
      const [y, m, d] = iso.split('-').map(Number);
      const dt = new Date(Date.UTC(y, m - 1, d + n));
      return dt.toISOString().slice(0, 10);
    };

    while (currISO <= todayISO) {
      const semana = [];
      for (let d = 0; d < 7; d++) {
        const fecha = addDays(currISO, d);
        semana.push({ fecha, esFuturo: fecha > todayISO });
      }
      currISO = addDays(currISO, 7);
      semanasArr.push(semana);

      const primerDia = new Date(semana[0].fecha + 'T12:00:00');
      if (primerDia.getDate() <= 7) {
        mesesArr.push({ idx: semIdx, mes: MESES_CORTOS[primerDia.getMonth()] });
      }
      semIdx++;
    }

    return { semanas: semanasArr, mesesLabel: mesesArr };
  }, []);

  const semanasConDatos = useMemo(() => {
    return semanas.map(semana =>
      semana.map(dia => ({ ...dia, total: mapaVentas[dia.fecha] || 0 }))
    );
  }, [semanas, mapaVentas]);

  const totalDiasConVentas = Object.keys(mapaVentas).length;
  const totalAnual = Object.values(mapaVentas).reduce((a, b) => a + b, 0);

  return (
    <div className="heatmap-card">
      <div className="heatmap-top">
        <h3 className="heatmap-titulo">Actividad del último año</h3>
        <div className="heatmap-resumen">
          <span>{totalDiasConVentas} días con ventas</span>
          <span className="heatmap-resumen-sep">·</span>
          <span>${totalAnual.toLocaleString('es-MX', { minimumFractionDigits: 2 })} en el período</span>
        </div>
      </div>

      <div className="heatmap-scroll">
        <div className="heatmap-inner">
          <div className="heatmap-dias-col">
            <div className="heatmap-dias-spacer" />
            {DIAS_LABEL.map((d, i) => (
              <div key={i} className="heatmap-dia-label">{d}</div>
            ))}
          </div>

          <div className="heatmap-semanas-col">
            <div className="heatmap-meses-row">
              {semanas.map((_, si) => {
                const label = mesesLabel.find(m => m.idx === si);
                return (
                  <div key={si} className="heatmap-mes-slot">
                    {label ? label.mes : ''}
                  </div>
                );
              })}
            </div>

            <div className="heatmap-celdas-row">
              {semanasConDatos.map((semana, si) => (
                <div key={si} className="heatmap-semana-col">
                  {semana.map((dia, di) => (
                    <div
                      key={di}
                      className="heatmap-celda"
                      style={{ backgroundColor: getColor(dia.total, maxValor, dia.esFuturo) }}
                      title={
                        dia.esFuturo ? '' :
                        dia.total > 0
                          ? `${dia.fecha}: $${dia.total.toFixed(2)}`
                          : `${dia.fecha}: sin ventas`
                      }
                    />
                  ))}
                </div>
              ))}
            </div>
          </div>
        </div>

        <div className="heatmap-leyenda">
          <span className="heatmap-leyenda-label">Menos</span>
          {COLORES.map((c, i) => (
            <div key={i} className="heatmap-leyenda-celda" style={{ backgroundColor: c }} />
          ))}
          <span className="heatmap-leyenda-label">Más</span>
        </div>
      </div>
    </div>
  );
};

export default HeatmapAnual;
