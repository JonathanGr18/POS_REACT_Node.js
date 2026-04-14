import React, { useEffect, useState } from 'react';
import api from '../services/api';
import Spinner from '../components/ui/Spinner';
import { useToast } from '../components/ui/Toast';
import { useSettings } from '../context/SettingsContext';
import { formatCurrency, formatDate, formatTime } from '../utils/format';
import './Dashboard.css';

const Dashboard = () => {
  const [datos, setDatos] = useState({
    ventasHoy: 0,
    ingresosHoy: 0,
    totalProductos: 0,
    stockCritico: 0,
    topProductos: [],
    ultimasVentas: []
  });
  const [cargando, setCargando] = useState(true);
  const { addToast } = useToast();
  const { settings } = useSettings();
  const umbral = settings.stockUmbral || 10;

  useEffect(() => {
    let cancelado = false;
    const fetchResumen = async () => {
      try {
        setCargando(true);
        const res = await api.get(`/dashboard/resumen?umbral=${umbral}`);
        if (!cancelado) setDatos(res.data);
      } catch (err) {
        if (!cancelado) addToast('Error al cargar el dashboard', 'error');
      } finally {
        if (!cancelado) setCargando(false);
      }
    };

    fetchResumen();
    return () => { cancelado = true; };
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [umbral]);

  if (cargando) {
    return (
      <div className="dashboard-page" style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', minHeight: '60vh' }}>
        <Spinner />
      </div>
    );
  }

  const formatFecha = (fechaStr) => {
    if (!fechaStr) return '-';
    return `${formatDate(fechaStr, { day: '2-digit', month: '2-digit', year: 'numeric' })} ${formatTime(fechaStr)}`;
  };

  const formatMoneda = (valor) => formatCurrency(valor);

  return (
    <div className="dashboard-page">
      <h2 className="dashboard-titulo">Dashboard</h2>

      {/* Tarjetas de métricas */}
      <div className="dashboard-grid">
        {/* Ventas hoy */}
        <div className="metrica-card">
          <div className="metrica-icono">🛒</div>
          <div className="metrica-valor">{datos.ventasHoy}</div>
          <div className="metrica-label">Ventas hoy</div>
        </div>

        {/* Ingresos hoy */}
        <div className="metrica-card">
          <div className="metrica-icono">💰</div>
          <div className="metrica-valor">{formatMoneda(datos.ingresosHoy)}</div>
          <div className="metrica-label">Ingresos hoy</div>
        </div>

        {/* Total productos */}
        <div className="metrica-card">
          <div className="metrica-icono">📦</div>
          <div className="metrica-valor">{datos.totalProductos}</div>
          <div className="metrica-label">Total productos activos</div>
        </div>

        {/* Stock crítico */}
        <div className={`metrica-card ${datos.stockCritico > 0 ? 'critico' : ''}`}>
          <div className="metrica-icono">⚠️</div>
          <div className="metrica-valor">{datos.stockCritico}</div>
          <div className="metrica-label">Productos con stock crítico</div>
        </div>
      </div>

      {/* Top productos del día */}
      {datos.topProductos && datos.topProductos.length > 0 && (
        <div className="dashboard-seccion">
          <h3>Top productos del día</h3>
          <table className="dashboard-tabla">
            <thead>
              <tr>
                <th>#</th>
                <th>Producto</th>
                <th>Unidades vendidas</th>
              </tr>
            </thead>
            <tbody>
              {datos.topProductos.map((prod, idx) => (
                <tr key={idx}>
                  <td>{idx + 1}</td>
                  <td>{prod.nombre}</td>
                  <td>{parseInt(prod.total_vendido, 10)}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {datos.topProductos && datos.topProductos.length === 0 && (
        <div className="dashboard-seccion">
          <h3>Top productos del día</h3>
          <p className="dashboard-vacio">No hay ventas registradas hoy.</p>
        </div>
      )}

      {/* Últimas 5 ventas */}
      <div className="dashboard-seccion">
        <h3>Últimas ventas</h3>
        {datos.ultimasVentas && datos.ultimasVentas.length > 0 ? (
          datos.ultimasVentas.map((venta) => (
            <div key={venta.id} className="ultima-venta-item">
              <span className="ultima-venta-id">Venta #{venta.id}</span>
              <span className="ultima-venta-fecha">{formatFecha(venta.fecha)}</span>
              <span className="ultima-venta-total">{formatMoneda(venta.total)}</span>
            </div>
          ))
        ) : (
          <p className="dashboard-vacio">No hay ventas registradas aún.</p>
        )}
      </div>
    </div>
  );
};

export default Dashboard;
