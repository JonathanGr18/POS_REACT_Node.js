import React, { useEffect, useState, useMemo } from 'react';
import jsPDF from 'jspdf';
import autoTable from 'jspdf-autotable';
import api from '../../services/api';
import Spinner from '../ui/Spinner';
import { useToast } from '../ui/Toast';
import './MesesReportes.css';

const meses = [
  'Enero','Febrero','Marzo','Abril','Mayo','Junio',
  'Julio','Agosto','Septiembre','Octubre','Noviembre','Diciembre'
];

// Gráfica de barras SVG simple
const GraficaBarras = ({ datos, promedio }) => {
  if (!datos || datos.length === 0) {
    return <p style={{ textAlign: 'center', color: 'var(--texto-secundario)' }}>Sin datos para graficar</p>;
  }

  const maxValor = Math.max(...datos.map(d => parseFloat(d.total_dia) || 0), 1);
  const alturaMax = 160;
  const anchoTotal = Math.max(datos.length * 36, 300);
  const promedioY = promedio ? alturaMax - Math.round((promedio / maxValor) * alturaMax) : null;

  // Eje Y: 5 niveles
  const niveles = [0, 0.25, 0.5, 0.75, 1].map(f => ({
    valor: maxValor * f,
    y: alturaMax - Math.round(f * alturaMax),
  }));

  return (
    <div className="grafica-container">
      <h3>Ventas diarias del mes</h3>
      <div className="grafica-scroll">
        <svg width={anchoTotal + 60} height={alturaMax + 50} className="grafica-svg">
          {/* Eje Y */}
          {niveles.map((n, i) => (
            <g key={i}>
              <line x1={50} y1={n.y} x2={anchoTotal + 50} y2={n.y} stroke="var(--borde)" strokeDasharray="3,3" strokeWidth="1" />
              <text x={44} y={n.y + 4} textAnchor="end" fontSize="9" fill="var(--texto-secundario)">
                ${n.valor >= 1000 ? `${(n.valor/1000).toFixed(1)}k` : Math.round(n.valor)}
              </text>
            </g>
          ))}

          {/* Línea de promedio */}
          {promedioY !== null && (
            <g>
              <line x1={50} y1={promedioY} x2={anchoTotal + 50} y2={promedioY} stroke="#f5a623" strokeDasharray="5,3" strokeWidth="1.5" />
              <text x={anchoTotal + 52} y={promedioY + 4} fontSize="9" fill="#f5a623">prom</text>
            </g>
          )}

          {/* Barras */}
          {datos.map((d, i) => {
            const valor = parseFloat(d.total_dia) || 0;
            const altura = Math.round((valor / maxValor) * alturaMax);
            const x = i * 36 + 54;
            const y = alturaMax - altura;
            const sobrePromedio = promedio && valor >= promedio;

            return (
              <g key={d.dia}>
                <rect
                  x={x}
                  y={y}
                  width={28}
                  height={altura}
                  rx={4}
                  fill={sobrePromedio ? 'var(--primario)' : '#e57373'}
                  opacity={0.85}
                />
                <title>${valor.toFixed(2)}</title>
                <text x={x + 14} y={alturaMax + 14} textAnchor="middle" className="barra-label">
                  {new Date(d.dia + 'T12:00:00').getDate()}
                </text>
                {valor > 0 && altura > 20 && (
                  <text x={x + 14} y={y - 4} textAnchor="middle" fontSize="8" fill="var(--texto-secundario)">
                    ${valor >= 1000 ? `${(valor/1000).toFixed(1)}k` : Math.round(valor)}
                  </text>
                )}
              </g>
            );
          })}

          {/* Línea base */}
          <line x1={50} y1={alturaMax} x2={anchoTotal + 50} y2={alturaMax} className="barra-linea" />
        </svg>
      </div>
      <div className="grafica-leyenda">
        <span className="leyenda-item"><span className="leyenda-color" style={{background:'var(--primario)'}}></span> Sobre promedio</span>
        <span className="leyenda-item"><span className="leyenda-color" style={{background:'#e57373'}}></span> Bajo promedio</span>
        <span className="leyenda-item"><span className="leyenda-color" style={{background:'#f5a623'}}></span> Promedio</span>
      </div>
    </div>
  );
};

const MesesReportes = () => {
  const { addToast } = useToast();
  const mesActual = new Date().getMonth();
  const [mesSeleccionado, setMesSeleccionado] = useState(mesActual);
  const [resumenDias, setResumenDias] = useState([]);
  const [datosMes, setDatosMes] = useState({
    ingresos: 0,
    egresos: 0,
    dias_no_abiertos: [],
    ganancia: 0
  });
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [datosMesAnterior, setDatosMesAnterior] = useState(null);

  useEffect(() => {
    api.get('/reportes/dias')
      .then(res => setResumenDias(res.data))
      .catch(() => {
        addToast('Error al cargar resumen diario', 'error');
        setResumenDias([]);
      });
  }, []);

  useEffect(() => {
    setLoading(true);
    setError('');

    Promise.all([
      api.get(`/reportes/mensual/${mesSeleccionado}`),
      api.get(`/reportes/dias-no-abiertos/${mesSeleccionado}`)
    ])
    .then(([resMes, resDias]) => {
      const { ingresos, egresos, ganancia } = resMes.data;
      const dias_no_abiertos = resMes.data.dias_no_abiertos || resDias.data.diasNoAbiertos || [];
      setDatosMes({ ingresos, egresos, dias_no_abiertos, ganancia });
      // Fetch previous month for comparison
      const mesAnterior = mesSeleccionado === 0 ? 11 : mesSeleccionado - 1;
      const yearAnterior = mesSeleccionado === 0 ? new Date().getFullYear() - 1 : new Date().getFullYear();
      api.get(`/reportes/mensual/${mesAnterior}?year=${yearAnterior}`)
        .then(r => setDatosMesAnterior(r.data))
        .catch(() => setDatosMesAnterior(null));
    })
    .catch(() => {
      addToast('Error cargando datos del mes', 'error');
      setError('Error cargando datos del mes');
      setDatosMes({ ingresos: 0, egresos: 0, dias_no_abiertos: [], ganancia: 0 });
    })
    .finally(() => setLoading(false));
  }, [mesSeleccionado]);

  const resumenFiltrado = useMemo(() => {
    return resumenDias
      .filter(item => new Date(item.dia + 'T12:00:00').getMonth() === mesSeleccionado)
      .sort((a, b) => new Date(a.dia) - new Date(b.dia));
  }, [resumenDias, mesSeleccionado]);

  const exportarPDF = () => {
    const doc = new jsPDF();
    const nombreMes = meses[mesSeleccionado];

    doc.setFontSize(16);
    doc.text(`Reporte Mensual - ${nombreMes}`, 14, 18);

    doc.setFontSize(11);
    doc.text(`Ingresos:  $${Number(datosMes.ingresos).toFixed(2)}`, 14, 30);
    doc.text(`Egresos:   $${Number(datosMes.egresos).toFixed(2)}`, 14, 38);
    doc.text(`Ganancia:  $${Number(datosMes.ganancia).toFixed(2)}`, 14, 46);
    doc.text(`Días no abiertos: ${datosMes.dias_no_abiertos.length}`, 14, 54);

    if (resumenFiltrado.length > 0) {
      autoTable(doc, {
        startY: 62,
        head: [['Fecha', 'Total del día']],
        body: resumenFiltrado.map(r => [
          new Date(r.dia + 'T12:00:00').toLocaleDateString('es-MX'),
          `$${parseFloat(r.total_dia).toFixed(2)}`
        ]),
        theme: 'striped',
        styles: { fontSize: 10 }
      });
    }

    doc.save(`reporte-${nombreMes.toLowerCase()}.pdf`);
  };

  return (
    <div className="meses-reporte-container">
      <h2>📆 Reportes Mensuales</h2>
      {error && <div className="error">{error}</div>}

      <div className="grid-meses">
        {meses.map((m, i) => (
          <button
            key={i}
            className={i === mesSeleccionado ? 'activo' : ''}
            onClick={() => setMesSeleccionado(i)}
          >
            {m}
          </button>
        ))}
      </div>

      {loading ? (
        <Spinner texto="Cargando reporte..." />
      ) : (
        <>
          <div className="tarjeta-mes-header">
            <div className="tarjeta-mes">
              <h3>Resumen de {meses[mesSeleccionado]}</h3>
              <p><strong>Ingresos:</strong> ${Number(datosMes.ingresos).toFixed(2)}</p>
              <p><strong>Egresos:</strong> ${Number(datosMes.egresos).toFixed(2)}</p>
              <p><strong>Ganancia:</strong> ${Number(datosMes.ganancia).toFixed(2)}</p>
              <p><strong>Días no abiertos:</strong> {datosMes.dias_no_abiertos.length} días</p>
            </div>

            {datosMesAnterior && datosMesAnterior.ingresos > 0 && (
              <div className="comparativa-mes">
                <h4>vs {meses[mesSeleccionado === 0 ? 11 : mesSeleccionado - 1]}</h4>
                {(() => {
                  const diff = datosMes.ingresos - datosMesAnterior.ingresos;
                  const pct = datosMesAnterior.ingresos > 0
                    ? ((diff / datosMesAnterior.ingresos) * 100).toFixed(1)
                    : 0;
                  const sube = diff >= 0;
                  return (
                    <>
                      <p className={`comparativa-valor ${sube ? 'sube' : 'baja'}`}>
                        {sube ? '↑' : '↓'} {Math.abs(pct)}%
                      </p>
                      <p className="comparativa-sub">
                        {sube ? '+' : ''}${diff.toFixed(2)}
                      </p>
                      <p className="comparativa-anterior">Anterior: ${Number(datosMesAnterior.ingresos).toFixed(2)}</p>
                    </>
                  );
                })()}
              </div>
            )}

            <button className="btn btn-primary btn-exportar-pdf" onClick={exportarPDF}>
              📄 Exportar PDF mensual
            </button>
          </div>

          <GraficaBarras
            datos={resumenFiltrado}
            promedio={resumenFiltrado.length > 0
              ? resumenFiltrado.reduce((a, d) => a + parseFloat(d.total_dia), 0) / resumenFiltrado.length
              : 0}
          />

          <h3>Ventas del mes</h3>
          <table className="tabla-resumen">
            <thead>
              <tr>
                <th>Fecha</th>
                <th>Total día</th>
              </tr>
            </thead>
            <tbody>
              {resumenFiltrado.length > 0 ? (
                resumenFiltrado.map((r) => (
                  <tr key={r.dia}>
                    <td>{new Date(r.dia + 'T12:00:00').toLocaleDateString('es-MX')}</td>
                    <td>${parseFloat(r.total_dia).toFixed(2)}</td>
                  </tr>
                ))
              ) : (
                <tr>
                  <td colSpan="2" style={{ textAlign: 'center' }}>
                    No hay ventas este mes
                  </td>
                </tr>
              )}
            </tbody>
          </table>
        </>
      )}
    </div>
  );
};

export default MesesReportes;
