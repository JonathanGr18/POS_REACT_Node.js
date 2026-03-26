import React, { useRef } from "react";
import { FaEdit, FaTrash, FaBarcode, FaCamera, FaTimes } from 'react-icons/fa';
import { IMAGE_BASE_URL } from '../../services/api';
import Tabla from "../ui/Tabla";

const ProductoTable = ({ productos, onDelete, onEdit, onBarcode, onSubirImagen, onQuitarImagen }) => {
  const fileInputRef = useRef(null);
  const pendingIdRef = useRef(null);

  const getStatusText = (stock) => {
    if (stock === 0) return 'Sin existencia';
    if (stock < 15) return 'Por terminar';
    return 'Disponible';
  };

  const getStatusColor = (stock) => {
    if (stock === 0) return 'red';
    if (stock < 15) return 'orange';
    return 'green';
  };

  const handleCameraClick = (id) => {
    pendingIdRef.current = id;
    fileInputRef.current.value = '';
    fileInputRef.current.click();
  };

  const handleFileChange = (e) => {
    const file = e.target.files[0];
    if (file && pendingIdRef.current != null) {
      onSubirImagen?.(pendingIdRef.current, file);
      pendingIdRef.current = null;
    }
  };

  return (
    <>
      {/* Input oculto compartido para subir imágenes */}
      <input
        ref={fileInputRef}
        type="file"
        accept=".jpg,.jpeg,.png,.webp"
        style={{ display: 'none' }}
        onChange={handleFileChange}
      />
      <Tabla
        columnas={['Imagen', 'Código', 'Nombre', 'Descripción', 'Precio', 'Stock', 'Status', 'Acciones']}
        datos={productos}
        renderFila={(producto) => (
          <tr key={producto.id}>
            <td style={{ textAlign: 'center', verticalAlign: 'middle', width: '70px' }}>
              {producto.imagen_url ? (
                <img
                  src={`${IMAGE_BASE_URL}${producto.imagen_url}`}
                  alt={producto.nombre}
                  style={{ width: '56px', height: '56px', objectFit: 'cover', borderRadius: '6px', display: 'block', margin: '0 auto' }}
                />
              ) : (
                <span style={{ fontSize: '1.8rem' }}>📦</span>
              )}
            </td>
            <td>{producto.codigo}</td>
            <td>{producto.nombre}</td>
            <td>{producto.descripcion}</td>
            <td>${Number(producto.precio).toFixed(2)}</td>
            <td style={{ color: getStatusColor(producto.stock), fontWeight: 'bold' }}>
              {producto.stock}
            </td>
            <td style={{ color: getStatusColor(producto.stock), fontWeight: 'bold' }}>
              {getStatusText(producto.stock)}
            </td>
            <td>
              <button className="btn-icon btn-edit" onClick={() => onEdit(producto)}>
                <FaEdit /> Editar
              </button>
              <button className="btn-icon btn-danger" onClick={() => onDelete(producto.id)}>
                <FaTrash /> Eliminar
              </button>
              <button className="btn-icon btn-secondary" onClick={() => onBarcode?.(producto)} title="Código de barras / QR">
                <FaBarcode />
              </button>
              <button
                className="btn-icon btn-secondary"
                onClick={() => handleCameraClick(producto.id)}
                title="Subir foto"
              >
                <FaCamera /> Foto
              </button>
              {producto.imagen_url && (
                <button
                  className="btn-icon btn-danger"
                  onClick={() => onQuitarImagen?.(producto.id)}
                  title="Quitar imagen"
                >
                  <FaTimes /> Quitar
                </button>
              )}
            </td>
          </tr>
        )}
      />
    </>
  );
};

export default ProductoTable;
