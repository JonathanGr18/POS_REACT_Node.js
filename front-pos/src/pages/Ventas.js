import React, { useEffect, useState } from 'react';
import api from '../services/api';
import { getProductosCache, invalidarProductosCache, onProductosActualizados } from '../services/productosCache';
import useLocalStorageState from '../hooks/useLocalStorageState';
import VentaForm from '../components/ventas/VentaForm';
import HistorialVentas from '../components/ventas/VentasList';
import Spinner from '../components/ui/Spinner';
import { useToast } from '../components/ui/Toast';
import './Ventas.css';

const Ventas = () => {
  const { addToast } = useToast();
  const [productos, setProductos] = useState([]);
  const [categorias, setCategorias] = useState([]);
  const [ventas, setVentas] = useState([]);
  // Persistencia ligera de preferencias UX
  const [verReportes, setVerReportes] = useLocalStorageState('ventas.verAnteriores', false);
  const [cargando, setCargando] = useState(false);
  const [mostrarHistorial, setMostrarHistorial] = useState(false);
  const [pagina, setPagina] = useState(1);
  const [paginas, setPaginas] = useState(1);
  const [totalVentas, setTotalVentas] = useState(0);
  const HIST_LIMIT = 20;

  useEffect(() => {
    const fetchData = async () => {
      setCargando(true);
      try {
        const [prods, catRes] = await Promise.all([
          getProductosCache(),                // usa cache en memoria
          api.get('/productos/categorias')
        ]);
        setProductos(prods);
        setCategorias(catRes.data);
      } catch {
        addToast('Error al cargar productos', 'error');
      } finally {
        setCargando(false);
      }
    };
    fetchData();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  // Suscribirse a actualizaciones en vivo del catálogo (stale-while-revalidate)
  useEffect(() => {
    return onProductosActualizados((productos) => setProductos(productos));
  }, []);

  // Al cambiar de tipo (hoy/anteriores) o abrir historial, reset página
  useEffect(() => {
    setPagina(1);
  }, [verReportes, mostrarHistorial]);

  useEffect(() => {
    if (!mostrarHistorial) return;
    const fetchVentas = async () => {
      try {
        const ruta = verReportes ? '/ventas/anteriores' : '/ventas/hoy';
        const resVentas = await api.get(`${ruta}?page=${pagina}&limit=${HIST_LIMIT}`);
        const data = resVentas.data;
        // Formato paginado: { ventas, total, pagina, paginas }
        setVentas(data.ventas || []);
        setPaginas(data.paginas || 1);
        setTotalVentas(data.total || 0);
      } catch {
        addToast('Error al cargar ventas', 'error');
      }
    };
    fetchVentas();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [mostrarHistorial, verReportes, pagina]);

  const cargarProductos = async () => {
    try {
      invalidarProductosCache();                    // stock cambió por la venta
      const data = await getProductosCache({ force: true });
      setProductos(data);
    } catch {
      addToast('Error al cargar productos', 'error');
    }
  };

  const cargarVentas = async () => {
    try {
      const ruta = verReportes ? '/ventas/anteriores' : '/ventas/hoy';
      const res = await api.get(`${ruta}?page=${pagina}&limit=${HIST_LIMIT}`);
      const data = res.data;
      if (data && Array.isArray(data.ventas)) {
        setVentas(data.ventas);
        setPaginas(data.paginas || 1);
        setTotalVentas(data.total || 0);
      } else {
        // fallback si backend devuelve array plano
        setVentas(Array.isArray(data) ? data : []);
      }
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
            categorias={categorias}
            onSubmit={registrarVenta}
          />
        )}
      </div>

      {/* Botón flotante para abrir el drawer del historial */}
      <button
        className="ventas-historial-fab"
        onClick={() => setMostrarHistorial(true)}
        title="Ver historial de ventas"
        aria-label="Ver historial de ventas"
      >
        📋 Historial
      </button>

      {/* Drawer lateral derecho con el historial */}
      {mostrarHistorial && (
        <div
          className="ventas-historial-overlay"
          onClick={() => setMostrarHistorial(false)}
          aria-hidden="true"
        />
      )}
      <aside
        className={`ventas-historial-drawer${mostrarHistorial ? ' ventas-historial-drawer--abierto' : ''}`}
        aria-hidden={!mostrarHistorial}
      >
        <div className="ventas-historial-header">
          <h3>{verReportes ? '📜 Ventas anteriores' : '📋 Ventas del día'}</h3>
          <button
            className="ventas-historial-close"
            onClick={() => setMostrarHistorial(false)}
            aria-label="Cerrar historial"
          >✕</button>
        </div>
        <div className="ventas-historial-tabs">
          <button
            className={`tab-btn${!verReportes ? ' tab-btn--activo' : ''}`}
            onClick={() => setVerReportes(false)}
          >Hoy</button>
          <button
            className={`tab-btn${verReportes ? ' tab-btn--activo' : ''}`}
            onClick={() => setVerReportes(true)}
          >Anteriores</button>
        </div>
        <div className="ventas-historial-body">
          <HistorialVentas ventas={ventas} onVentaModificada={cargarVentas} />
        </div>

        {paginas > 1 && (
          <div className="ventas-historial-paginacion">
            <button
              className="hist-pag-btn"
              disabled={pagina === 1}
              onClick={() => setPagina(p => Math.max(1, p - 1))}
            >‹</button>
            <span className="hist-pag-info">
              Página <strong>{pagina}</strong> de {paginas}
              <span className="hist-pag-total"> · {totalVentas} venta{totalVentas !== 1 ? 's' : ''}</span>
            </span>
            <button
              className="hist-pag-btn"
              disabled={pagina === paginas}
              onClick={() => setPagina(p => Math.min(paginas, p + 1))}
            >›</button>
          </div>
        )}
      </aside>
    </div>
  );
};

export default Ventas;
