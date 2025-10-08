import React, { useEffect, useState } from 'react';
import api from '../services/api';
import VentaForm from '../components/ventas/VentaForm';
import HistorialVentas from '../components/ventas/VentasList';
import './Ventas.css';

const Ventas = () => {
  const [productos, setProductos] = useState([]);
  const [ventas, setVentas] = useState([]);
  const [verReportes, setVerReportes] = useState(false);
  const [productosSeleccionados, setProductosSeleccionados] = useState([]);

  useEffect(() => {
    const fetchData = async () => {
      const resProductos = await api.get('/productos');
      setProductos(resProductos.data);

      const ruta = verReportes ? '/ventas' : '/ventas/hoy';
      const resVentas = await api.get(ruta);
      setVentas(resVentas.data);
    };

    fetchData();
  }, [verReportes]); // ✅ Ahora depende solo de verReportes


  const cargarProductos = async () => {
    const res = await api.get('/productos');
    setProductos(res.data);
  };

  const cargarVentas = async () => {
    const ruta = verReportes ? '/ventas' : '/ventas/hoy';
    const res = await api.get(ruta);
    setVentas(res.data);
  };

  const registrarVenta = async (ventaData) => {
    await api.post('/ventas', ventaData);
    setProductosSeleccionados([]);
    cargarProductos();
    cargarVentas();
  };

  return (
    <div className="ventas-page">
      <div className="venta-form-section">
        <h2>Formulario de Venta</h2>
        <VentaForm
          productosDisponibles={productos}
          productosSeleccionados={productosSeleccionados}
          setProductosSeleccionados={setProductosSeleccionados}
          onSubmit={registrarVenta}
        />
      </div>

      <div className="venta-historial-section">
        <h2>{verReportes ? 'Reportes de Ventas' : 'Historial de Ventas del Día'}</h2>
        <button
          className="toggle-button"
          onClick={() => setVerReportes(!verReportes)}
        >
          {verReportes ? 'Ver ventas del día' : 'Ver reportes anteriores'}
        </button>
        <HistorialVentas ventas={ventas} />
      </div>
    </div>
  );
};

export default Ventas;
