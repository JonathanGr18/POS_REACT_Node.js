import React, { useEffect, useState } from 'react';
import api from '../services/api';
import VentaForm from '../components/ventas/VentaForm';
import HistorialVentas from '../components/ventas/VentasList';
import Spinner from '../components/ui/Spinner';
import { useToast } from '../components/ui/Toast';
import './Ventas.css';

const Ventas = () => {
  const { addToast } = useToast();
  const [productos, setProductos] = useState([]);
  const [ventas, setVentas] = useState([]);
  const [verReportes, setVerReportes] = useState(false);
  const [cargando, setCargando] = useState(false);
  const [mostrarHistorial, setMostrarHistorial] = useState(false);

  useEffect(() => {
    const fetchData = async () => {
      setCargando(true);
      try {
        const resProductos = await api.get('/productos');
        setProductos(resProductos.data);
      } catch {
        addToast('Error al cargar productos', 'error');
      } finally {
        setCargando(false);
      }
    };
    fetchData();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  useEffect(() => {
    if (!mostrarHistorial) return;
    const fetchVentas = async () => {
      try {
        const ruta = verReportes ? '/ventas/anteriores' : '/ventas/hoy';
        const resVentas = await api.get(ruta);
        setVentas(resVentas.data);
      } catch {
        addToast('Error al cargar ventas', 'error');
      }
    };
    fetchVentas();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [mostrarHistorial, verReportes]);

  const cargarProductos = async () => {
    try {
      const res = await api.get('/productos');
      setProductos(res.data || []);
    } catch {
      addToast('Error al cargar productos', 'error');
    }
  };

  const cargarVentas = async () => {
    try {
      const ruta = verReportes ? '/ventas/anteriores' : '/ventas/hoy';
      const res = await api.get(ruta);
      setVentas(res.data || []);
    } catch {
      addToast('Error al cargar ventas', 'error');
    }
  };

  const registrarVenta = async (ventaData) => {
    try {
      const res = await api.post('/ventas', ventaData);
      await Promise.all([cargarProductos(), cargarVentas()]);
      return res.data;
    } catch (err) {
      throw err;
    }
  };

  return (
    <div className="ventas-page">
      <div className="ventas-pos-section">
        {cargando ? (
          <Spinner texto="Cargando productos..." />
        ) : (
          <VentaForm
            productosDisponibles={productos}
            onSubmit={registrarVenta}
          />
        )}
      </div>

      <div className="ventas-historial-toggle">
        <button
          className="toggle-button"
          onClick={() => setMostrarHistorial(v => !v)}
        >
          {mostrarHistorial ? '▲ Ocultar historial' : '▼ Ver historial de ventas'}
        </button>
        {mostrarHistorial && (
          <button
            className="toggle-button"
            onClick={() => setVerReportes(v => !v)}
          >
            {verReportes ? 'Ver ventas del día' : 'Ver ventas anteriores'}
          </button>
        )}
      </div>

      {mostrarHistorial && (
        <div className="ventas-historial-section">
          <h3>{verReportes ? 'Ventas anteriores' : 'Ventas del día'}</h3>
          <HistorialVentas ventas={ventas} />
        </div>
      )}
    </div>
  );
};

export default Ventas;
