import React, { useRef, useState } from "react";
import { FaEdit, FaTrash, FaBarcode, FaCamera, FaTimes, FaEllipsisV, FaBoxOpen } from 'react-icons/fa';
import { IMAGE_BASE_URL } from '../../services/api';
import Tabla from "../ui/Tabla";
import './ProductoList.css';

const ProductoTable = ({ productos, onDelete, onEdit, onBarcode, onSubirImagen, onQuitarImagen, onResurtir }) => {
  const fileInputRef = useRef(null);
  const pendingIdRef = useRef(null);
  const [menuAbierto, setMenuAbierto] = useState(null);
  const [resurtirId, setResurtirId] = useState(null);
  const [resurtirCantidad, setResurtirCantidad] = useState('');

  const getStatusText = (stock, stock_minimo = 15) => {
    if (stock === 0) return 'Sin existencia';
    if (stock < stock_minimo) return 'Por terminar';
    return 'Disponible';
  };

  const getStatusColor = (stock, stock_minimo = 15) => {
    if (stock === 0) return 'red';
    if (stock < stock_minimo) return 'orange';
    return 'green';
  };

  const getMargen = (precio, precio_costo) => {
    if (!precio_costo || precio_costo <= 0) return null;
    return ((precio - precio_costo) / precio_costo * 100).toFixed(1);
  };

  const handleCameraClick = (id) => {
    pendingIdRef.current = id;
    fileInputRef.current.value = '';
    fileInputRef.current.click();
    setMenuAbierto(null);
  };

  const handleFileChange = (e) => {
    const file = e.target.files[0];
    if (file && pendingIdRef.current != null) {
      onSubirImagen?.(pendingIdRef.current, file);
      pendingIdRef.current = null;
    }
  };

  const handleResurtir = (id) => {
    const cantidad = parseInt(resurtirCantidad);
    if (!cantidad || cantidad <= 0) return;
    onResurtir?.(id, cantidad);
    setResurtirId(null);
    setResurtirCantidad('');
  };

  const toggleMenu = (id) => {
    setMenuAbierto(menuAbierto === id ? null : id);
    setResurtirId(null);
    setResurtirCantidad('');
  };

  const abrirResurtir = (id) => {
    setResurtirId(id);
    setMenuAbierto(null); // Cerrar menú si estaba abierto
  };

  return (
    <>
      <input
        ref={fileInputRef}
        type="file"
        accept=".jpg,.jpeg,.png,.webp"
        style={{ display: 'none' }}
        onChange={handleFileChange}
      />

      {/* Overlay para cerrar menú */}
      {menuAbierto && <div className="menu-overlay" onClick={() => setMenuAbierto(null)} />}

      <Tabla
        columnas={['Imagen', 'Código', 'Nombre', 'Descripción', 'Categoría', 'Costo', 'Precio', 'Margen', 'Stock', 'Status', 'Acciones']}
        datos={productos}
        renderFila={(producto) => {
          const margen = getMargen(producto.precio, producto.precio_costo);
          const stockMin = producto.stock_minimo > 0 ? producto.stock_minimo : 15;
          return (
          <tr key={producto.id}>
            <td className="td-imagen">
              {producto.imagen_url ? (
                <img
                  src={`${IMAGE_BASE_URL}${producto.imagen_url}`}
                  alt={producto.nombre}
                  className="producto-img"
                />
              ) : (
                <span className="producto-img-placeholder">📦</span>
              )}
            </td>
            <td>{producto.codigo}</td>
            <td className="td-nombre">{producto.nombre}</td>
            <td className="td-desc">{producto.descripcion && producto.descripcion !== 'Sin descripcion' ? producto.descripcion : '—'}</td>
            <td><span className="badge-categoria">{producto.categoria || 'General'}</span></td>
            <td className="td-precio">${Number(producto.precio_costo || 0).toFixed(2)}</td>
            <td className="td-precio">${Number(producto.precio).toFixed(2)}</td>
            <td>
              {margen !== null ? (
                <span className={`badge-margen ${Number(margen) >= 0 ? 'margen-pos' : 'margen-neg'}`}>
                  {margen}%
                </span>
              ) : '—'}
            </td>
            <td style={{ color: getStatusColor(producto.stock, stockMin), fontWeight: 'bold' }}>
              {producto.stock}
            </td>
            <td style={{ color: getStatusColor(producto.stock, stockMin), fontWeight: 'bold' }}>
              {getStatusText(producto.stock, stockMin)}
            </td>
            <td className="td-acciones">
              {/* Resurtir inline */}
              {resurtirId === producto.id ? (
                <div className="resurtir-inline">
                  <label htmlFor={`resurtir-input-${producto.id}`} className="sr-only">
                    Cantidad a resurtir de {producto.nombre}
                  </label>
                  <input
                    id={`resurtir-input-${producto.id}`}
                    type="number"
                    min="1"
                    placeholder="Cant."
                    className="resurtir-input"
                    value={resurtirCantidad}
                    onChange={e => setResurtirCantidad(e.target.value)}
                    onKeyDown={e => e.key === 'Enter' && handleResurtir(producto.id)}
                    autoFocus
                  />
                  <button
                    className="btn-icon btn-success-sm"
                    onClick={() => handleResurtir(producto.id)}
                    aria-label="Confirmar resurtir"
                  >+</button>
                  <button
                    className="btn-icon btn-cancel-sm"
                    onClick={() => { setResurtirId(null); setResurtirCantidad(''); }}
                    aria-label="Cancelar resurtir"
                  >x</button>
                </div>
              ) : (
                <>
                  <button
                    className="btn-icon btn-edit"
                    onClick={() => onEdit(producto)}
                    aria-label={`Editar ${producto.nombre}`}
                    title="Editar"
                  >
                    <FaEdit aria-hidden="true" />
                  </button>
                  <button
                    className="btn-icon btn-resurtir"
                    onClick={() => abrirResurtir(producto.id)}
                    aria-label={`Resurtir ${producto.nombre}`}
                    title="Resurtir"
                  >
                    <FaBoxOpen aria-hidden="true" />
                  </button>

                  {/* Menú contextual "..." */}
                  <div className="menu-contextual-wrap">
                    <button
                      className="btn-icon btn-menu"
                      onClick={() => toggleMenu(producto.id)}
                      aria-label={`Más opciones para ${producto.nombre}`}
                      aria-haspopup="menu"
                      aria-expanded={menuAbierto === producto.id}
                      title="Más opciones"
                    >
                      <FaEllipsisV aria-hidden="true" />
                    </button>
                    {menuAbierto === producto.id && (
                      <div className="menu-contextual">
                        <button onClick={() => { onBarcode?.(producto); setMenuAbierto(null); }}>
                          <FaBarcode /> Código de barras
                        </button>
                        <button onClick={() => handleCameraClick(producto.id)}>
                          <FaCamera /> Subir foto
                        </button>
                        {producto.imagen_url && (
                          <button onClick={() => { onQuitarImagen?.(producto.id); setMenuAbierto(null); }}>
                            <FaTimes /> Quitar imagen
                          </button>
                        )}
                        <hr />
                        <button className="menu-item-danger" onClick={() => { onDelete(producto.id); setMenuAbierto(null); }}>
                          <FaTrash /> Eliminar
                        </button>
                      </div>
                    )}
                  </div>
                </>
              )}
            </td>
          </tr>
          );
        }}
      />
    </>
  );
};

export default ProductoTable;
