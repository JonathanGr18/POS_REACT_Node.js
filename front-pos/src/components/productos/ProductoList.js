import React from "react";
import { FaEdit, FaTrash } from 'react-icons/fa';
<<<<<<< HEAD
import Tabla from "../ui/Tabla"; // ruta nueva
=======
import Tabla from "../ui/Tabla"; 
>>>>>>> 0423949a6e9463fb24a6a377b2310e309be8e491

const ProductoTable = ({ productos, onDelete, onEdit }) => {
  const getStatusText = (stock) => {
    if (stock === 0) return 'Sin existencia';
<<<<<<< HEAD
=======
    if (stock <= 5) return 'Muy bajo';
>>>>>>> 0423949a6e9463fb24a6a377b2310e309be8e491
    if (stock < 10) return 'Por terminar';
    return 'Disponible';
  };

  const getStatusColor = (stock) => {
    if (stock === 0) return 'red';
<<<<<<< HEAD
    if (stock < 15) return 'orange';
=======
    if (stock <= 5) return 'orange';
    if (stock < 10) return 'gold';
>>>>>>> 0423949a6e9463fb24a6a377b2310e309be8e491
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
