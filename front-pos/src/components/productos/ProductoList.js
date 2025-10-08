import React from "react";
import { FaEdit, FaTrash } from 'react-icons/fa';
import Tabla from "../ui/Tabla"; 

const ProductoTable = ({ productos, onDelete, onEdit }) => {
  const getStatusText = (stock) => {
    if (stock === 0) return 'Sin existencia';
    if (stock <= 5) return 'Muy bajo';
    if (stock < 10) return 'Por terminar';
    return 'Disponible';
  };

  const getStatusColor = (stock) => {
    if (stock === 0) return 'red';
    if (stock <= 5) return 'orange';
    if (stock < 10) return 'gold';
    return 'green';
  };

  return (
    <Tabla
      columnas={['Código', 'Nombre', 'Descripción', 'Precio', 'Stock', 'Status', 'Acciones']}
      datos={productos}
      renderFila={(producto) => (
        <tr key={producto.id}>
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
          </td>
        </tr>
      )}
    />
  );
};

export default ProductoTable;
