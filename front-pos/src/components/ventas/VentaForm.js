import React, { useState } from 'react';
import ProductoListVenta from './ProducListVenta';
import ConfirmModal from '../ui/ConfirmModal';
import TicketPreviewModal from '../reportes/TicketPreviewModal';
import { useToast } from '../ui/Toast';
import './VentaForm.css';

const VentaForm = ({ productosDisponibles, onSubmit }) => {
  const { addToast } = useToast();
  const [items, setItems] = useState([]);
  const [modalConfirm, setModalConfirm] = useState(false);
  const [ticketVenta, setTicketVenta] = useState(null);
  const [registrando, setRegistrando] = useState(false);
  const [descuento, setDescuento] = useState(0);
  const [montoRecibido, setMontoRecibido] = useState('');
  const [metodoPago, setMetodoPago] = useState('efectivo');

  const agregarProducto = (producto) => {
    const yaExiste = items.find((i) => i.id === producto.id);
    if (yaExiste) {
      if (yaExiste.cantidad < producto.stock) {
        setItems(items.map((i) =>
          i.id === producto.id ? { ...i, cantidad: i.cantidad + 1 } : i
        ));
      } else {
        addToast('No puedes agregar más de la cantidad disponible en stock.', 'aviso');
      }
    } else {
      setItems([...items, { ...producto, cantidad: 1 }]);
    }
  };

  const actualizarCantidad = (id, delta) => {
    setItems(items.map((item) => {
      if (item.id !== id) return item;
      const nueva = Math.max(1, Math.min(item.stock, item.cantidad + delta));
      return { ...item, cantidad: nueva };
    }));
  };

  const eliminarItem = (id) => setItems(items.filter((item) => item.id !== id));

  const calcularTotal = () =>
    items.reduce((acc, item) => acc + Number(item.precio) * Number(item.cantidad), 0);

  const calcularTotalConDescuento = () => {
    const subtotal = calcularTotal();
    return Math.max(0, subtotal - subtotal * (descuento / 100));
  };

  const calcularCambio = () => Math.max(0, (parseFloat(montoRecibido) || 0) - calcularTotalConDescuento());

  const handleSubmit = () => {
    if (items.length === 0) {
      addToast('Agrega al menos un producto para registrar la venta.', 'aviso');
      return;
    }
    const recibido = parseFloat(montoRecibido);
    if (montoRecibido !== '' && !isNaN(recibido) && recibido < calcularTotalConDescuento()) {
      addToast('El monto recibido es menor al total de la venta.', 'aviso');
      return;
    }
    setModalConfirm(true);
  };

  const confirmarVenta = async () => {
    setModalConfirm(false);
    setRegistrando(true);
    const totalFinal = calcularTotalConDescuento();
    const descuentoMonto = calcularTotal() * descuento / 100;
    const venta = {
      productos: items.map(({ id, nombre, cantidad, precio }) => ({ id, nombre, cantidad, precio })),
      total: totalFinal,
      descuento: descuentoMonto,
      monto_recibido: parseFloat(montoRecibido) || 0,
      metodo_pago: metodoPago,
    };

    try {
      const result = await onSubmit(venta);
      setTicketVenta({
        id: result?.id,
        fecha: new Date().toISOString(),
        total: totalFinal,
        descuento: descuentoMonto,
        monto_recibido: parseFloat(montoRecibido) || 0,
        metodo_pago: metodoPago,
        productos: items.map(item => ({
          producto: item.nombre,
          cantidad: item.cantidad,
          precio: item.precio,
        })),
      });
      setItems([]);
      setDescuento(0);
      setMontoRecibido('');
      setMetodoPago('efectivo');
    } catch (err) {
      addToast(err?.response?.data?.error || 'Error al registrar la venta', 'error');
    } finally {
      setRegistrando(false);
    }
  };

  const totalConDesc = calcularTotalConDescuento();
  const recibido = parseFloat(montoRecibido) || 0;

  return (
    <>
      <ConfirmModal
        visible={modalConfirm}
        mensaje={`¿Confirmar venta por $${totalConDesc.toFixed(2)} con ${items.length} producto(s)?`}
        textoConfirmar="Registrar venta"
        tipoBtnConfirmar="btn-primary"
        onConfirm={confirmarVenta}
        onCancel={() => setModalConfirm(false)}
      />
      {ticketVenta && (
        <TicketPreviewModal
          venta={ticketVenta}
          onCerrar={() => setTicketVenta(null)}
        />
      )}

      <div className="pos-layout">
        {/* ── Panel izquierdo: catálogo de productos ── */}
        <div className="pos-productos">
          <ProductoListVenta
            productos={productosDisponibles}
            onSelect={agregarProducto}
            itemsEnCarrito={items}
          />
        </div>

        {/* ── Panel derecho: carrito ── */}
        <div className="pos-carrito">
          <h3 className="carrito-titulo">🛒 Orden actual</h3>

          {/* Lista de items */}
          <div className="carrito-items">
            {items.length === 0 ? (
              <p className="carrito-vacio">Selecciona productos de la izquierda</p>
            ) : (
              items.map((item) => (
                <div key={item.id} className="carrito-item">
                  <div className="carrito-item-info">
                    <span className="carrito-item-nombre">{item.nombre}</span>
                    <span className="carrito-item-subtotal">
                      ${(Number(item.precio) * item.cantidad).toFixed(2)}
                    </span>
                  </div>
                  <div className="carrito-item-controls">
                    <button
                      className="qty-btn"
                      onClick={() => actualizarCantidad(item.id, -1)}
                      disabled={item.cantidad <= 1}
                    >−</button>
                    <span className="qty-num">{item.cantidad}</span>
                    <button
                      className="qty-btn"
                      onClick={() => actualizarCantidad(item.id, +1)}
                      disabled={item.cantidad >= item.stock}
                    >+</button>
                    <button
                      className="qty-btn qty-btn--eliminar"
                      onClick={() => eliminarItem(item.id)}
                    >✕</button>
                  </div>
                </div>
              ))
            )}
          </div>

          {/* Descuento + Método de pago */}
          <div className="carrito-opciones">
            <div className="carrito-descuento">
              <span className="carrito-label">Descuento</span>
              <div className="desc-btns">
                {[0, 10, 15, 20, 25].map(d => (
                  <button
                    key={d}
                    type="button"
                    className={`btn-desc${descuento === d ? ' activo' : ''}`}
                    onClick={() => setDescuento(d)}
                  >{d}%</button>
                ))}
              </div>
            </div>
            <div className="carrito-metodo">
              <span className="carrito-label">Pago</span>
              <div className="metodo-btns">
                {[
                  { value: 'efectivo',      label: '💵', title: 'Efectivo' },
                  { value: 'tarjeta',       label: '💳', title: 'Tarjeta' },
                  { value: 'transferencia', label: '🏦', title: 'Transferencia' },
                ].map(m => (
                  <button
                    key={m.value}
                    type="button"
                    className={`btn-metodo${metodoPago === m.value ? ' activo' : ''}`}
                    onClick={() => setMetodoPago(m.value)}
                    title={m.title}
                  >{m.label}</button>
                ))}
              </div>
            </div>
          </div>

          {/* Monto recibido + billetero */}
          <div className="carrito-recibido">
            <div className="recibido-row">
              <input
                type="number"
                className="recibido-input"
                placeholder="Monto recibido..."
                value={montoRecibido}
                onChange={e => setMontoRecibido(e.target.value)}
                min="0"
                step="0.01"
              />
              {montoRecibido && (
                <button
                  type="button"
                  className="btn-limpiar"
                  onClick={() => setMontoRecibido('')}
                >✕</button>
              )}
            </div>

            <div className="billetero">
              {[500, 200, 100, 50, 20].map(val => (
                <button
                  key={val}
                  type="button"
                  className="btn-billete"
                  onClick={() => setMontoRecibido(prev => String((parseFloat(prev) || 0) + val))}
                >${val}</button>
              ))}
              {[10, 5, 2, 1].map(val => (
                <button
                  key={val}
                  type="button"
                  className="btn-moneda"
                  onClick={() => setMontoRecibido(prev => String((parseFloat(prev) || 0) + val))}
                >${val}</button>
              ))}
            </div>

            {montoRecibido && recibido >= totalConDesc && (
              <p className="cambio-ok">💵 Cambio: <strong>${calcularCambio().toFixed(2)}</strong></p>
            )}
            {montoRecibido && recibido < totalConDesc && (
              <p className="cambio-falta">⚠️ Faltan: ${(totalConDesc - recibido).toFixed(2)}</p>
            )}
          </div>

          {/* Total + COBRAR */}
          <div className="carrito-footer">
            {descuento > 0 && (
              <p className="carrito-subtotal">Subtotal: ${calcularTotal().toFixed(2)}</p>
            )}
            <p className="carrito-total">
              Total{descuento > 0 ? ` (−${descuento}%)` : ''}: <strong>${totalConDesc.toFixed(2)}</strong>
            </p>
            <button
              className="btn-cobrar"
              onClick={handleSubmit}
              disabled={items.length === 0 || registrando}
            >
              {registrando ? 'Registrando...' : '✅ COBRAR'}
            </button>
          </div>
        </div>
      </div>
    </>
  );
};

export default VentaForm;
