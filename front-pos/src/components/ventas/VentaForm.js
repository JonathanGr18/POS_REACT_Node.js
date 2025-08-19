import React, { useState } from 'react';
import ProductoListVenta from './ProducListVenta';
import './VentaForm.css';

const VentaForm = ({ productosDisponibles, onSubmit }) => {
  const [items, setItems] = useState([]);

  const agregarProducto = (producto) => {
    const yaExiste = items.find((i) => i.id === producto.id);
    if (yaExiste) {
      if (yaExiste.cantidad < producto.stock) {
        setItems(items.map((i) =>
          i.id === producto.id
            ? { ...i, cantidad: i.cantidad + 1 }
            : i
        ));
      } else {
        alert('No puedes agregar más de la cantidad disponible en stock.');
      }
    } else {
      setItems([...items, { ...producto, cantidad: 1 }]);
    }
  };

  const actualizarCantidad = (id, cantidad) => {
    setItems(items.map((item) =>
      item.id === id
        ? { ...item, cantidad: Math.min(Number(cantidad), item.stock) }
        : item
    ));
  };

  const eliminarItem = (id) => {
    setItems(items.filter((item) => item.id !== id));
  };

  const calcularTotal = () =>
    items.reduce((acc, item) => acc + item.precio * item.cantidad, 0);

  const handleSubmit = (e) => {
    e.preventDefault();
    if (items.length === 0) return;

    const venta = {
      productos: items.map(({ id, nombre, cantidad, precio }) => ({
        id,
        nombre,
        cantidad,
        precio,
      })),
      total: calcularTotal(),
    };

    onSubmit(venta);
    setItems([]);
  };

  return (
    <div className="productos-grid">
      {/* Columna izquierda: productos disponibles */}
      <div className="columna-productos-disponibles">
        <h3>Productos Disponibles</h3>
        <ProductoListVenta
          productos={productosDisponibles}
          onSelect={agregarProducto}
        />
      </div>

      {/* Columna derecha: productos seleccionados */}
      <div className="columna-productos-seleccionados">
        <h3>Productos Seleccionados</h3>
        <div className="tabla-scroll-seleccionados">
          <table>
            <thead>
              <tr>
                <th>Producto</th>
                <th>Precio</th>
                <th>Cantidad</th>
                <th>Subtotal</th>
                <th></th>
              </tr>
            </thead>
            <tbody>
              {items.map((item) => (
                <tr key={item.id}>
                  <td>{item.nombre}</td>
                  <td>${Number(item.precio).toFixed(2)}</td>
                  <td style={{ display: 'flex', alignItems: 'center', gap: '5px', justifyContent: 'center' }}>
                    <button
                      className='plus-minus-btn'
                      onClick={() =>
                        actualizarCantidad(item.id, Math.max(1, item.cantidad - 1))
                      }
                      disabled={item.cantidad <= 1}
                    >
                      ➖
                    </button>

                    <input
                      type="number"
                      value={item.cantidad}
                      min="1"
                      max={item.stock}
                      onChange={(e) => actualizarCantidad(item.id, e.target.value)}
                      style={{ width: '50px', textAlign: 'center' }}
                    />

                    <button
                      className='plus-minus-btn'
                      onClick={() =>
                        actualizarCantidad(item.id, Math.min(item.stock, item.cantidad + 1))
                      }
                      disabled={item.cantidad >= item.stock}
                    >
                      ➕
                    </button>
                  </td>
                  <td>${(item.precio * item.cantidad).toFixed(2)}</td>
                  <td>
                    <button
                      onClick={() => eliminarItem(item.id)}
                      className="eliminar-btn"
                    >
                      Eliminar
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>

        <h4>Total: ${calcularTotal().toFixed(2)}</h4>
        <button
          onClick={handleSubmit}
          className="registrar-venta-btn"
          disabled={items.length === 0}
        >
          Registrar Venta
        </button>
      </div>
    </div>
  );
};

export default VentaForm;
