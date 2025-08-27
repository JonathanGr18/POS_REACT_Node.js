import React, { useState, useEffect } from 'react';
import './Productos.css';
import api from '../services/api';

// Componentes
import FiltrosProducto from '../components/productos/FiltroProductos';
import ProductoTable from '../components/productos/ProductoList';
import ProductoForm from '../components/productos/ProductoForm';
import AgregarEgresoForm from '../components/faltantes/Egresos';
import ResurtirProductoForm from '../components/productos/Resurtir';

const Productos = () => {
  const [autorizado, setAutorizado] = useState(false);
  const [password, setPassword] = useState('');

  const claveAcceso = 'admin'; // Seguridad básica

  const verificarPassword = () => {
    if (password === claveAcceso) {
      setAutorizado(true);
    } else {
      alert('Contraseña incorrecta');
    }
  };

  const [productos, setProductos] = useState([]);
  const [productoSeleccionado, setProductoSeleccionado] = useState(null);
  const [busqueda, setBusqueda] = useState('');
  const [orden, setOrden] = useState('nombre');
  const [ascendente, setAscendente] = useState(true);
  const [estadoFiltro, setEstadoFiltro] = useState('todos');

  useEffect(() => {
    if (autorizado) {
      cargarProductos();
    }
  }, [autorizado]);

  const cargarProductos = async () => {
    const res = await api.get('/productos');
    setProductos(res.data);
  };

  const crearOActualizar = async (producto) => {
    if (producto.id) {
      await api.put(`/productos/${producto.id}`, producto);
    } else {
      await api.post('/productos', producto);
    }
    setProductoSeleccionado(null);
    cargarProductos();
  };

  const eliminarProducto = async (id) => {
    await api.delete(`/productos/${id}`);
    cargarProductos();
  };

  // Filtrar y ordenar
  let filtrados = productos.filter(p =>
    p.nombre.toLowerCase().includes(busqueda.toLowerCase()) ||
    p.descripcion.toLowerCase().includes(busqueda.toLowerCase())
  );

  if (estadoFiltro !== 'todos') {
    filtrados = filtrados.filter(p => {
      if (estadoFiltro === 'sin') return p.stock === 0;
      if (estadoFiltro === 'bajo') return p.stock > 0 && p.stock < 15;
      if (estadoFiltro === 'ok') return p.stock >= 15;
      return true;
    });
  }

  filtrados.sort((a, b) => {
    let resultado = 0;
    if (orden === 'nombre') resultado = a.nombre.localeCompare(b.nombre);
    if (orden === 'codigo') resultado = a.codigo.localeCompare(b.codigo);
    if (orden === 'precio') resultado = a.precio - b.precio;
    if (orden === 'stock') resultado = b.stock - a.stock;
    return ascendente ? resultado : -resultado;
  });

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
          />
          <button className="btn btn-primary" onClick={verificarPassword}>Ingresar</button>
        </div>
      </div>
    );
  }

  return (
    <div className="productos-container">
      {/* 🧾 Formulario */}
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

      {/* 📋 Tabla */}
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

        <ProductoTable
          productos={filtrados}
          onDelete={eliminarProducto}
          onEdit={setProductoSeleccionado}
        />
      </div>
    </div>
  );
};

export default Productos;
