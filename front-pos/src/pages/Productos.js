import React, { useState, useEffect, useCallback, useMemo } from 'react';
import './Productos.css';
import api from '../services/api';
import { useToast } from '../components/ui/Toast';
import ConfirmModal from '../components/ui/ConfirmModal';
import Spinner from '../components/ui/Spinner';
import { FaPlus, FaThList, FaTh, FaMoneyBillWave, FaBoxes } from 'react-icons/fa';
import useLocalStorageState from '../hooks/useLocalStorageState';

// Componentes
import FiltrosProducto from '../components/productos/FiltroProductos';
import ProductoTable from '../components/productos/ProductoList';
import ProductoGrid from '../components/productos/ProductoGrid';
import ProductoDrawer from '../components/productos/ProductoDrawer';
import CodigoBarrasModal from '../components/productos/CodigoBarrasModal';
import EgresoDrawer from '../components/faltantes/EgresoDrawer';
import ResurtirMasivoDrawer from '../components/productos/ResurtirMasivoDrawer';

const ITEMS_POR_PAGINA = 15;

const Productos = () => {
  const { addToast } = useToast();
  const [autorizado, setAutorizado] = useState(false);
  const [password, setPassword] = useState('');
  const [cargando, setCargando] = useState(false);
  const [modalEliminar, setModalEliminar] = useState({ visible: false, id: null });
  const [pagina, setPagina] = useState(1);
  const [drawerVisible, setDrawerVisible] = useState(false);
  const [vistaGrid, setVistaGrid] = useLocalStorageState('productos.vistaGrid', false);
  const [mostrarEgresos, setMostrarEgresos] = useState(false);
  const [mostrarResurtir, setMostrarResurtir] = useState(false);

  const [verificando, setVerificando] = useState(false);

  const verificarPassword = async () => {
    if (!password.trim()) {
      addToast('Ingresa una contraseña', 'aviso');
      return;
    }
    setVerificando(true);
    try {
      const res = await api.post('/auth/verificar', { password });
      if (res.data.autorizado) {
        setAutorizado(true);
      }
    } catch (err) {
      if (err?.response?.status === 429) {
        addToast('Demasiados intentos, espera unos minutos', 'error');
      } else {
        addToast('Contraseña incorrecta', 'error');
      }
    } finally {
      setVerificando(false);
    }
  };

  const [productos, setProductos] = useState([]);
  const [categorias, setCategorias] = useState([]);
  const [productoSeleccionado, setProductoSeleccionado] = useState(null);
  const [busqueda, setBusqueda] = useState('');
  const [orden, setOrden] = useState('nombre');
  const [ascendente, setAscendente] = useState(true);
  const [estadoFiltro, setEstadoFiltro] = useState('todos');
  const [categoriaFiltro, setCategoriaFiltro] = useState('todas');
  const [productoBarcode, setProductoBarcode] = useState(null);

  const cargarProductos = useCallback(async () => {
    setCargando(true);
    try {
      const [prodRes, catRes] = await Promise.all([
        api.get('/productos'),
        api.get('/productos/categorias')
      ]);
      setProductos(prodRes.data);
      setCategorias(catRes.data);
    } catch {
      addToast('Error al cargar productos', 'error');
    } finally {
      setCargando(false);
    }
  }, [addToast]);

  useEffect(() => {
    if (autorizado) cargarProductos();
  }, [autorizado, cargarProductos]);

  // Resetear paginación al cambiar filtros
  useEffect(() => {
    setPagina(1);
  }, [busqueda, estadoFiltro, categoriaFiltro, orden, ascendente]);

  const crearOActualizar = async (producto) => {
    try {
      if (producto.id) {
        await api.put(`/productos/${producto.id}`, producto);
        addToast('Producto actualizado correctamente', 'exito');
      } else {
        await api.post('/productos', producto);
        addToast('Producto creado correctamente', 'exito');
      }
      setProductoSeleccionado(null);
      cargarProductos();
    } catch (err) {
      if (err?.response?.status === 409) {
        addToast(err.response.data?.error || 'Ese código ya existe', 'error');
      } else if (err?.response?.status === 400) {
        addToast(err.response.data?.error || 'Datos inválidos', 'error');
      } else {
        addToast('Error al guardar el producto', 'error');
      }
    }
  };

  const subirImagen = async (id, file) => {
    const formData = new FormData();
    formData.append('imagen', file);
    try {
      await api.post(`/productos/${id}/imagen`, formData, {
        headers: { 'Content-Type': 'multipart/form-data' }
      });
      addToast('Imagen actualizada', 'exito');
      cargarProductos();
    } catch {
      addToast('Error al subir la imagen', 'error');
    }
  };

  const quitarImagen = async (id) => {
    try {
      await api.delete(`/productos/${id}/imagen`);
      addToast('Imagen eliminada', 'exito');
      cargarProductos();
    } catch {
      addToast('Error al eliminar la imagen', 'error');
    }
  };

  const resurtirProducto = async (id, cantidad) => {
    try {
      await api.put(`/productos/resurtir/${id}`, { cantidad });
      addToast(`Producto resurtido (+${cantidad})`, 'exito');
      cargarProductos();
    } catch {
      addToast('Error al resurtir producto', 'error');
    }
  };

  const pedirConfirmacionEliminar = (id) => {
    const prod = productos.find(p => p.id === id);
    setModalEliminar({ visible: true, id, nombre: prod?.nombre || '' });
  };

  const confirmarEliminar = async () => {
    try {
      await api.delete(`/productos/${modalEliminar.id}`);
      addToast('Producto eliminado', 'exito');
      cargarProductos();
    } catch {
      addToast('Error al eliminar el producto', 'error');
    } finally {
      setModalEliminar({ visible: false, id: null });
    }
  };

  const abrirEditar = (producto) => {
    setProductoSeleccionado(producto);
    setDrawerVisible(true);
  };

  const abrirNuevo = () => {
    setProductoSeleccionado(null);
    setDrawerVisible(true);
  };

  const cerrarDrawer = () => {
    setDrawerVisible(false);
    setProductoSeleccionado(null);
  };

  // Filtrar y ordenar (memoizado para evitar recalculos en cada render)
  const filtrados = useMemo(() => {
    const valor = busqueda.trim().toLowerCase();
    const esNumero = !isNaN(Number(valor)) && valor !== '';

    let lista = productos.filter(p => {
      if (!valor) return true;
      const codigoStr = p.codigo != null ? p.codigo.toString() : '';
      if (esNumero) {
        return Number(p.codigo) === Number(valor) || codigoStr.startsWith(valor);
      }
      return (
        (p.nombre?.toLowerCase().includes(valor) ?? false) ||
        (p.descripcion?.toLowerCase().includes(valor) ?? false)
      );
    });

    if (estadoFiltro !== 'todos') {
      lista = lista.filter(p => {
        const umbral = p.stock_minimo > 0 ? p.stock_minimo : 15;
        const stock = Number(p.stock);
        if (estadoFiltro === 'sin')  return stock === 0;
        if (estadoFiltro === 'bajo') return stock > 0 && stock < umbral;
        if (estadoFiltro === 'ok')   return stock >= umbral;
        return true;
      });
    }

    if (categoriaFiltro !== 'todas') {
      lista = lista.filter(p => (p.categoria || 'General') === categoriaFiltro);
    }

    const getMargen = (p) => {
      if (!p.precio_costo || Number(p.precio_costo) <= 0) return -Infinity;
      return (Number(p.precio) - Number(p.precio_costo)) / Number(p.precio_costo) * 100;
    };

    return [...lista].sort((a, b) => {
      let r = 0;
      if (orden === 'nombre')    r = (a.nombre ?? '').localeCompare(b.nombre ?? '');
      if (orden === 'codigo')    r = (a.codigo?.toString() ?? '').localeCompare(b.codigo?.toString() ?? '');
      if (orden === 'precio')    r = Number(a.precio) - Number(b.precio);
      if (orden === 'stock')     r = Number(b.stock) - Number(a.stock);
      if (orden === 'categoria') r = (a.categoria ?? '').localeCompare(b.categoria ?? '');
      if (orden === 'margen')    r = getMargen(a) - getMargen(b);
      return ascendente ? r : -r;
    });
  }, [productos, busqueda, estadoFiltro, categoriaFiltro, orden, ascendente]);

  // Paginación
  const totalPaginas = Math.max(1, Math.ceil(filtrados.length / ITEMS_POR_PAGINA));

  // Clampar página si queda fuera de rango (ej: al reducir resultados)
  useEffect(() => {
    if (pagina > totalPaginas) setPagina(totalPaginas);
  }, [totalPaginas, pagina]);

  const inicio = (pagina - 1) * ITEMS_POR_PAGINA;
  const paginados = filtrados.slice(inicio, inicio + ITEMS_POR_PAGINA);

  // Bloque de acceso
  if (!autorizado) {
    return (
      <div className="productos-acceso">
        <div className="card-acceso">
          <h2>🔐 Acceso Restringido</h2>
          <p>Esta sección es privada. Ingresa la contraseña para continuar.</p>
          <label htmlFor="productos-pass-input" className="sr-only">Contraseña</label>
          <input
            id="productos-pass-input"
            type="password"
            className="input"
            placeholder="Contraseña"
            aria-label="Contraseña de acceso"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            onKeyDown={(e) => e.key === 'Enter' && verificarPassword()}
          />
          <button className="btn btn-primary" onClick={verificarPassword} disabled={verificando}>
            {verificando ? 'Verificando...' : 'Ingresar'}
          </button>
        </div>
      </div>
    );
  }

  return (
    <div className="productos-page">
      <ConfirmModal
        visible={modalEliminar.visible}
        mensaje={`¿Eliminar "${modalEliminar.nombre || 'este producto'}"? Esta acción no se puede deshacer.`}
        onConfirm={confirmarEliminar}
        onCancel={() => setModalEliminar({ visible: false, id: null, nombre: '' })}
      />

      {productoBarcode && (
        <CodigoBarrasModal
          producto={productoBarcode}
          onCerrar={() => setProductoBarcode(null)}
        />
      )}

      <ProductoDrawer
        visible={drawerVisible}
        onCerrar={cerrarDrawer}
        productos={productos}
        categorias={categorias}
        onSubmit={crearOActualizar}
        productoSeleccionado={productoSeleccionado}
      />

      {/* Header con título, toggle vista y botón agregar */}
      <div className="productos-header">
        <div>
          <h2 className="productos-titulo">Productos</h2>
          <p className="productos-subtitulo">{productos.length} producto(s) en inventario</p>
        </div>
        <div className="productos-header-acciones">
          <div className="vista-toggle">
            <button
              className={`vista-btn ${!vistaGrid ? 'vista-btn--activo' : ''}`}
              onClick={() => setVistaGrid(false)}
              title="Vista tabla"
            >
              <FaThList />
            </button>
            <button
              className={`vista-btn ${vistaGrid ? 'vista-btn--activo' : ''}`}
              onClick={() => setVistaGrid(true)}
              title="Vista cuadrícula"
            >
              <FaTh />
            </button>
          </div>
          <button
            className="btn-surtir"
            onClick={() => setMostrarResurtir(true)}
            title="Surtir varios productos"
          >
            <FaBoxes /> Surtir
          </button>
          <button
            className="btn-egreso"
            onClick={() => setMostrarEgresos(true)}
            title="Registrar egreso"
          >
            <FaMoneyBillWave /> Egreso
          </button>
          <button className="btn-nuevo-producto" onClick={abrirNuevo}>
            <FaPlus /> Nuevo Producto
          </button>
        </div>
      </div>

      <EgresoDrawer
        visible={mostrarEgresos}
        onCerrar={() => setMostrarEgresos(false)}
      />

      <ResurtirMasivoDrawer
        visible={mostrarResurtir}
        onCerrar={() => setMostrarResurtir(false)}
        productos={productos}
        onResurtido={cargarProductos}
      />

      {/* Filtros */}
      <FiltrosProducto
        busqueda={busqueda}
        setBusqueda={setBusqueda}
        orden={orden}
        setOrden={setOrden}
        ascendente={ascendente}
        setAscendente={setAscendente}
        estadoFiltro={estadoFiltro}
        setEstadoFiltro={setEstadoFiltro}
        categoriaFiltro={categoriaFiltro}
        setCategoriaFiltro={setCategoriaFiltro}
        categorias={categorias}
      />

      <p className="contador-productos">
        Mostrando {filtrados.length} producto(s)
      </p>

      {/* Contenido: Tabla o Grid */}
      {cargando ? (
        <Spinner />
      ) : (
        <>
          {vistaGrid ? (
            <ProductoGrid
              productos={paginados}
              onEdit={abrirEditar}
              onBarcode={setProductoBarcode}
              onResurtir={resurtirProducto}
            />
          ) : (
            <ProductoTable
              productos={paginados}
              onDelete={pedirConfirmacionEliminar}
              onEdit={abrirEditar}
              onBarcode={setProductoBarcode}
              onSubirImagen={subirImagen}
              onQuitarImagen={quitarImagen}
              onResurtir={resurtirProducto}
            />
          )}

          {totalPaginas > 1 && (
            <div className="paginacion">
              <button
                className="btn-pagina"
                disabled={pagina === 1}
                onClick={() => setPagina(p => p - 1)}
              >
                ‹ Anterior
              </button>
              <span className="pagina-info">Página {pagina} de {totalPaginas}</span>
              <button
                className="btn-pagina"
                disabled={pagina === totalPaginas}
                onClick={() => setPagina(p => p + 1)}
              >
                Siguiente ›
              </button>
            </div>
          )}
        </>
      )}

    </div>
  );
};

export default Productos;
