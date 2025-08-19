import React, { useEffect, useState, useMemo } from 'react';
import axios from 'axios';
import './MesesReportes.css';

const meses = [
  'Enero','Febrero','Marzo','Abril','Mayo','Junio',
  'Julio','Agosto','Septiembre','Octubre','Noviembre','Diciembre'
];

const MesesReportes = () => {
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

  // Obtener resumen de ventas por día (una sola vez)
  useEffect(() => {
    axios.get('/api/reportes/dias')
      .then(res => setResumenDias(res.data))
      .catch(err => {
        console.error('Error al obtener resumen diario:', err);
        setResumenDias([]);
      });
  }, []);

  // Obtener datos del mes actual o seleccionado
  useEffect(() => {
    setLoading(true);
    setError('');

    Promise.all([
      axios.get(`/api/reportes/mensual/${mesSeleccionado}`),
      axios.get(`/api/reportes/dias-no-abiertos/${mesSeleccionado}`)
    ])
    .then(([resMes, resDias]) => {
      const { ingresos, egresos, ganancia } = resMes.data;
      const dias_no_abiertos = resMes.data.dias_no_abiertos || resDias.data.diasNoAbiertos;
      setDatosMes({ ingresos, egresos, dias_no_abiertos, ganancia });
    })
    .catch(err => {
      console.error('Error cargando datos del mes:', err);
      setError('Error cargando datos del mes');
      setDatosMes({ ingresos: 0, egresos: 0, dias_no_abiertos: [], ganancia: 0 });
    })
    .finally(() => setLoading(false));
  }, [mesSeleccionado]);

  // Filtrar ventas diarias del mes actual
  const resumenFiltrado = useMemo(() => {
    return resumenDias
      .filter(item => new Date(item.dia).getMonth() === mesSeleccionado)
      .sort((a, b) => new Date(a.dia) - new Date(b.dia));
  }, [resumenDias, mesSeleccionado]);

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
        <p>Cargando datos...</p>
      ) : (
        <div className="tarjeta-mes">
          <h3>Resumen de {meses[mesSeleccionado]}</h3>
          <p><strong>Ingresos:</strong> ${datosMes.ingresos.toFixed(2)}</p>
          <p><strong>Egresos:</strong> ${datosMes.egresos.toFixed(2)}</p>
          <p><strong>Ganancia:</strong> ${datosMes.ganancia.toFixed(2)}</p>
          <p><strong>Días no abiertos:</strong> {datosMes.dias_no_abiertos.length} días</p>
        </div>
      )}

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
                <td>{new Date(r.dia).toLocaleDateString()}</td>
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
    </div>
  );
};

export default MesesReportes;
