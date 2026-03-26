import React, { useState, useEffect, useCallback } from 'react';
import './Productos.css';
import api from '../services/api';
import { useToast } from '../components/ui/Toast';
import ConfirmModal from '../components/ui/ConfirmModal';
import Spinner from '../components/ui/Spinner';

// Componentes
import FiltrosProducto from '../components/productos/FiltroProductos';
import ProductoTable from '../components/productos/ProductoList';
import ProductoForm from '../components/productos/ProductoForm';
import AgregarEgresoForm from '../components/faltantes/Egresos';
import ResurtirProductoForm from '../components/productos/Resurtir';
import CodigoBarrasModal from '../components/productos/CodigoBarrasModal';

const ITEMS_POR_PAGINA = 15;

const Productos = () => {
  const { addToast } = useToast();
  const [autorizado, setAutorizado] = useState(false);
  const [password, setPassword] = useState('');
  const [cargando, setCargando] = useState(false);
  const [modalEliminar, setModalEliminar] = useState({ visible: false, id: null });
  const [pagina, setPagina] = useState(1);

  const verificarPassword = () => {
    const claveAcceso = process.env.REACT_APP_ACCESS_PASSWORD || 'admin';
    if (password === claveAcceso) {
      setAutorizado(true);
    } else {
      addToast('Contraseña incorrecta', 'error');
    }
  };

  const [productos, setProductos] = useState([]);
  const [productoSeleccionado, setProductoSeleccionado] = useState(null);
  const [busqueda, setBusqueda] = useState('');
  const [orden, setOrden] = useState('nombre');
  const [ascendente, setAscendente] = useState(true);
  const [estadoFiltro, setEstadoFiltro] = useState('todos');
  const [productoBarcode, setProductoBarcode] = useState(null);

  const cargarProductos = useCallback(async () => {
    setCargando(true);
    try {
      const res = await api.get('/productos');
      setProductos(res.data);
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
  }, [busqueda, estadoFiltro, orden, ascendente]);

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

  const pedirConfirmacionEliminar = (id) => {
    setModalEliminar({ visible: true, id });
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

  // Filtrar y ordenar
  const valor = busqueda.trim().toLowerCase();
  const esNumero = !isNaN(Number(valor)) && valor !== '';

  let filtrados = productos.filter(p => {
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
    filtrados = filtrados.filter(p => {
      if (estadoFiltro === 'sin')  return p.stock === 0;
      if (estadoFiltro === 'bajo') return p.stock > 0 && p.stock < 15;
      if (estadoFiltro === 'ok')   return p.stock >= 15;
      return true;
    });
  }

  filtrados.sort((a, b) => {
    let r = 0;
    if (orden === 'nombre') r = (a.nombre ?? '').localeCompare(b.nombre ?? '');
    if (orden === 'codigo') r = (a.codigo?.toString() ?? '').localeCompare(b.codigo?.toString() ?? '');
    if (orden === 'precio') r = Number(a.precio) - Number(b.precio);
    if (orden === 'stock')  r = b.stock - a.stock;
    return ascendente ? r : -r;
  });

  // Paginación
  const totalPaginas = Math.ceil(filtrados.length / ITEMS_POR_PAGINA);
  const inicio = (pagina - 1) * ITEMS_POR_PAGINA;
  const paginados = filtrados.slice(inicio, inicio + ITEMS_POR_PAGINA);

  // Bloque de acceso
  if (!autorizado) {
    return (
      <div className="productos-acceso">
        <div className="card-acceso">
          <h2>🔐 Acceso Restringido</h2>
          <p>Esta sección es privada. Ingresa la contraseña para continuar.</p>
          <input
            type="password"
            className="input"
            placeholder="Contraseña"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            onKeyDown={(e) => e.key === 'Enter' && verificarPassword()}
          />
          <button className="btn btn-primary" onClick={verificarPassword}>Ingresar</button>
        </div>
      </div>
    );
  }

  return (
    <div className="productos-container">
      <ConfirmModal
        visible={modalEliminar.visible}
        mensaje="¿Estás seguro de que quieres eliminar este producto? Esta acción no se puede deshacer."
        onConfirm={confirmarEliminar}
        onCancel={() => setModalEliminar({ visible: false, id: null })}
      />

      {productoBarcode && (
        <CodigoBarrasModal
          producto={productoBarcode}
          onCerrar={() => setProductoBarcode(null)}
        />
      )}

      {/* Formulario */}
      <div className="form-section">
        <h2>Formulario de Producto</h2>
        <ProductoForm
          productos={productos}
          onSubmit={crearOActualizar}
          productoSeleccionado={productoSeleccionado}
        />
        <AgregarEgresoForm />
        <ResurtirProductoForm productos={productos} onResurtir={cargarProductos} />
      </div>

      {/* Tabla */}
      <div className="tabla-section">
        <h2>Listado de Productos</h2>

        <FiltrosProducto
          busqueda={busqueda}
          setBusqueda={setBusqueda}
          orden={orden}
          setOrden={setOrden}
          ascendente={ascendente}
          setAscendente={setAscendente}
          estadoFiltro={estadoFiltro}
          setEstadoFiltro={setEstadoFiltro}
        />

        <p className="contador-productos">
          Mostrando {filtrados.length} producto(s)
        </p>

        {cargando ? (
          <Spinner />
        ) : (
          <>
            <ProductoTable
              productos={paginados}
              onDelete={pedirConfirmacionEliminar}
              onEdit={setProductoSeleccionado}
              onBarcode={setProductoBarcode}
              onSubirImagen={subirImagen}
              onQuitarImagen={quitarImagen}
            />

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
    </div>
  );
};

export default Productos;
