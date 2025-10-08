import React, { useState } from 'react';
import './ProducListVen.css';

const ProductoListVenta = ({ productos = [], onSelect }) => {
  const [searchTerm, setSearchTerm] = useState('');
  const [orden, setOrden] = useState('nombre');
  const [ascendente, setAscendente] = useState(true);

  const valor = searchTerm.trim().toLowerCase();
  const esNumero = !isNaN(Number(valor));
  const productosFiltrados = productos
  .filter((producto) => producto.stock > 0)
  .filter((producto) => {
    if (!valor) return true; // si no hay búsqueda, mostrar todo
    if (esNumero) {
      // buscar coincidencia exacta en código
      const codigoExacto = Number(producto.codigo) === Number(valor);
      // sugerencias: mostrar si el código contiene el valor como substring
      const codigoSugerencia = producto.codigo.toString().startsWith(valor);
      return codigoExacto || codigoSugerencia;
    } else {
      // buscar coincidencias en nombre o descripción
      return (
        producto.nombre.toLowerCase().includes(valor) ||
        producto.descripcion?.toLowerCase().includes(valor)
      );
    }
  });


  productosFiltrados.sort((a, b) => {
    let resultado = 0;
    if (orden === 'nombre') resultado = a.nombre.localeCompare(b.nombre);
    if (orden === 'codigo') resultado = a.codigo.localeCompare(b.codigo);
    if (orden === 'precio') resultado = a.precio - b.precio;
    return ascendente ? resultado : -resultado;
  });

  const getStatusColor = (stock) => {
    if (stock === 0) return 'rojo';
    if (stock < 15) return 'naranja';
    return 'verde';
  };

  return (
    <div className="producto-list-venta">
      <div className="filtros-busqueda">
        <input
          className="input-busqueda"
          type="text"
          placeholder="Buscar por código, nombre o descripción"
          value={searchTerm}
          onChange={(e) => setSearchTerm(e.target.value)}
        />

        <select value={orden} onChange={(e) => setOrden(e.target.value)}>
          <option value="nombre">Nombre</option>
          <option value="codigo">Código</option>
          <option value="precio">Precio</option>
        </select>

        <button className="btn-orden" onClick={() => setAscendente(!ascendente)}>
          {ascendente ? '⬆️' : '⬇️'}
        </button>
      </div>

      <div className="tabla-scroll-limitada">
        <table className="tabla-productos">
          <thead>
            <tr>
              <th>Código</th>
              <th>Nombre</th>
              <th>Descripción</th>
              <th>Precio</th>
              <th>Stock</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            {productosFiltrados.length > 0 ? (
              productosFiltrados.map((producto) => (
                <tr key={producto.id}>
                  <td>{producto.codigo}</td>
                  <td>{producto.nombre}</td>
                  <td>{producto.descripcion || 'Sin descripción'}</td>
                  <td>${Number(producto.precio).toFixed(2)}</td>
                  <td className={`stock-${getStatusColor(producto.stock)}`}>
                    {producto.stock}
                  </td>
                  <td>
                    <button
                      className="button-primary"
                      onClick={() => onSelect?.(producto)}
                      disabled={producto.stock <= 0}
                    >
                      Agregar
                    </button>
                  </td>
                </tr>
              ))
            ) : (
              <tr>
                <td colSpan="6" style={{ textAlign: 'center' }}>
                  No se encontraron productos.
                </td>
              </tr>
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
};

export default ProductoListVenta;
