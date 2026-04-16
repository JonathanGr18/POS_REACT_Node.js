import React, { useState, useEffect, useCallback, useMemo, useRef } from 'react';
import ProductoListVenta from './ProducListVenta';
import ConfirmModal from '../ui/ConfirmModal';
import TicketPreviewModal from '../reportes/TicketPreviewModal';
import { useToast } from '../ui/Toast';
import './VentaForm.css';

const VentaForm = ({ productosDisponibles, categorias = [], onSubmit }) => {
  const { addToast } = useToast();
  const [items, setItems] = useState([]);
  const [modalConfirm, setModalConfirm] = useState(false);
  const [ticketVenta, setTicketVenta] = useState(null);
  const [registrando, setRegistrando] = useState(false);
  const [descuento, setDescuento] = useState(0);
  const [descuentoTipo, setDescuentoTipo] = useState('porcentaje'); // 'porcentaje' | 'monto'
  const [montoRecibido, setMontoRecibido] = useState('');
  const [metodoPago, setMetodoPago] = useState('efectivo');
  const [editandoCantidad, setEditandoCantidad] = useState(null);
  const [cantidadTemp, setCantidadTemp] = useState('');

  // Ordenes pausadas
  const [ordenesPausadas, setOrdenesPausadas] = useState([]);
  // Ref sincrono para evitar doble cobro en eventos rapidos (ctrl+enter)
  const procesandoRef = useRef(false);

  // Memoizados para evitar recalculos en cada render
  const totalItems = useMemo(() => items.reduce((acc, i) => acc + i.cantidad, 0), [items]);
  const subtotal = useMemo(
    () => items.reduce((acc, item) => acc + Number(item.precio) * Number(item.cantidad), 0),
    [items]
  );
  const totalConDesc = useMemo(() => {
    if (descuentoTipo === 'porcentaje') {
      return Math.max(0, subtotal - subtotal * (descuento / 100));
    }
    return Math.max(0, subtotal - descuento);
  }, [subtotal, descuento, descuentoTipo]);

  // Si el descuento monto excede el subtotal (por cambiar items), clamparlo
  useEffect(() => {
    if (descuentoTipo === 'monto' && descuento > subtotal) {
      setDescuento(subtotal);
    }
  }, [subtotal, descuentoTipo, descuento]);

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

  const setCantidadDirecta = (id, cantidad) => {
    const num = parseInt(cantidad);
    if (isNaN(num) || num < 1) return;
    setItems(items.map(item => {
      if (item.id !== id) return item;
      return { ...item, cantidad: Math.min(num, item.stock) };
    }));
  };

  const eliminarItem = (id) => setItems(items.filter((item) => item.id !== id));

  const limpiarCarrito = () => {
    setItems([]);
    setDescuento(0);
    setDescuentoTipo('porcentaje');
    setMontoRecibido('');
    setMetodoPago('efectivo');
    setEditandoCantidad(null);
    setCantidadTemp('');
  };

  // Validar descuento segun tipo
  const setDescuentoSeguro = (val) => {
    const num = parseFloat(val) || 0;
    if (descuentoTipo === 'porcentaje') {
      setDescuento(Math.max(0, Math.min(100, num)));
    } else {
      const subtotal = calcularTotal();
      setDescuento(Math.max(0, Math.min(subtotal, num)));
    }
  };

  // Alias para compatibilidad con codigo existente
  const calcularTotal = () => subtotal;
  const calcularTotalConDescuento = () => totalConDesc;
  const calcularCambio = () => Math.max(0, (parseFloat(montoRecibido) || 0) - totalConDesc);

  // Pausar orden actual
  const pausarOrden = () => {
    if (items.length === 0) {
      addToast('No hay productos en la orden', 'aviso');
      return;
    }
    setOrdenesPausadas(prev => [...prev, { items, descuento, descuentoTipo, metodoPago, fecha: new Date() }]);
    // Reset completo para nueva orden
    setItems([]);
    setDescuento(0);
    setDescuentoTipo('porcentaje');
    setMontoRecibido('');
    setMetodoPago('efectivo');
    setEditandoCantidad(null);
    setCantidadTemp('');
    addToast('Orden pausada', 'exito');
  };

  // Recuperar orden pausada
  const recuperarOrden = (index) => {
    const orden = ordenesPausadas[index];
    if (items.length > 0) {
      // Pausar la actual antes de recuperar
      setOrdenesPausadas(prev => {
        const nuevas = [...prev];
        nuevas.splice(index, 1);
        return [...nuevas, { items, descuento, descuentoTipo, metodoPago, fecha: new Date() }];
      });
    } else {
      setOrdenesPausadas(prev => prev.filter((_, i) => i !== index));
    }
    setItems(orden.items);
    setDescuento(orden.descuento);
    setDescuentoTipo(orden.descuentoTipo);
    setMetodoPago(orden.metodoPago);
    setMontoRecibido('');
    addToast('Orden recuperada', 'exito');
  };

  const handleSubmit = () => {
    if (procesandoRef.current || registrando || modalConfirm) return; // Evita doble cobro
    procesandoRef.current = true;
    if (items.length === 0) {
      addToast('Agrega al menos un producto para registrar la venta.', 'aviso');
      procesandoRef.current = false;
      return;
    }
    const totalConDescuento = calcularTotalConDescuento();
    const recibido = parseFloat(montoRecibido);

    // Solo efectivo requiere monto recibido válido
    if (metodoPago === 'efectivo') {
      if (montoRecibido === '' || isNaN(recibido)) {
        addToast('Ingresa el monto recibido (pago en efectivo).', 'aviso');
        procesandoRef.current = false;
        return;
      }
      if (recibido < totalConDescuento) {
        addToast('El monto recibido es menor al total de la venta.', 'aviso');
        procesandoRef.current = false;
        return;
      }
    }
    setModalConfirm(true);
    // NO liberar aqui: se libera en confirmarVenta/onCancel del modal
  };

  const confirmarVenta = async () => {
    setModalConfirm(false);
    setRegistrando(true);
    const totalFinal = calcularTotalConDescuento();
    const subtotal = calcularTotal();
    const descuentoMonto = descuentoTipo === 'porcentaje'
      ? subtotal * descuento / 100
      : descuento;
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
      procesandoRef.current = false;
    }
  };

  // ── Atajos de teclado globales ──
  const handleGlobalKeyDown = useCallback((e) => {
    // F2 = focus busqueda
    if (e.key === 'F2') {
      e.preventDefault();
      document.getElementById('plv-busqueda-input')?.focus();
      return;
    }
    // F4 = monto exacto
    if (e.key === 'F4') {
      e.preventDefault();
      if (totalConDesc > 0) setMontoRecibido(String(totalConDesc));
      return;
    }
    // Esc = limpiar carrito (solo si no hay otro modal/input activo)
    if (e.key === 'Escape' && !modalConfirm && !ticketVenta) {
      const tag = document.activeElement?.tagName;
      // No interferir con inputs activos (la busqueda maneja su propio Esc)
      if (tag !== 'INPUT' && tag !== 'TEXTAREA' && items.length > 0) {
        e.preventDefault();
        limpiarCarrito();
      }
      return;
    }
    // Ctrl+Enter = cobrar (bloqueado mientras registrando o modal abierto)
    if (e.ctrlKey && e.key === 'Enter') {
      e.preventDefault();
      if (!registrando && !modalConfirm) handleSubmit();
    }
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [items, registrando, modalConfirm, ticketVenta, metodoPago, montoRecibido, descuento, descuentoTipo, totalConDesc]);

  useEffect(() => {
    window.addEventListener('keydown', handleGlobalKeyDown);
    return () => window.removeEventListener('keydown', handleGlobalKeyDown);
  }, [handleGlobalKeyDown]);

  const recibido = parseFloat(montoRecibido) || 0;

  return (
    <>
      <ConfirmModal
        visible={modalConfirm}
        mensaje={`¿Confirmar venta por $${totalConDesc.toFixed(2)} con ${items.length} producto(s)?`}
        textoConfirmar="Registrar venta"
        tipoBtnConfirmar="btn-primary"
        onConfirm={confirmarVenta}
        onCancel={() => {
          setModalConfirm(false);
          procesandoRef.current = false;
        }}
      />
      {ticketVenta && (
        <TicketPreviewModal
          venta={ticketVenta}
          onCerrar={() => {
            setTicketVenta(null);
            // Auto-focus a búsqueda para siguiente venta
            setTimeout(() => {
              document.getElementById('plv-busqueda-input')?.focus();
            }, 100);
          }}
        />
      )}

      <div className="pos-layout">
        {/* ── Panel izquierdo: catálogo de productos ── */}
        <div className="pos-productos">
          <ProductoListVenta
            productos={productosDisponibles}
            categorias={categorias}
            onSelect={agregarProducto}
            itemsEnCarrito={items}
          />
        </div>

        {/* ── Panel derecho: carrito ── */}
        <div className="pos-carrito">
          <div className="carrito-header">
            <h3 className="carrito-titulo">
              🛒 Orden actual
              {totalItems > 0 && <span className="carrito-badge">{totalItems}</span>}
            </h3>
            <div className="carrito-header-btns">
              {ordenesPausadas.length > 0 && (
                <div className="pausadas-dropdown">
                  <button className="btn-pausadas" title="Órdenes pausadas">
                    ⏸ {ordenesPausadas.length}
                  </button>
                  <div className="pausadas-menu">
                    {ordenesPausadas.map((o, i) => (
                      <button key={i} onClick={() => recuperarOrden(i)}>
                        Orden #{i + 1} — {o.items.length} item(s)
                      </button>
                    ))}
                  </div>
                </div>
              )}
              <button
                className="btn-pausar"
                onClick={pausarOrden}
                disabled={items.length === 0}
                title="Pausar orden (apartar)"
              >⏸</button>
              <button
                className="btn-limpiar-carrito"
                onClick={limpiarCarrito}
                disabled={items.length === 0}
                title="Vaciar carrito"
              >🗑</button>
            </div>
          </div>

          {/* Lista de items */}
          <div className="carrito-items">
            {items.length === 0 ? (
              <p className="carrito-vacio">Selecciona productos de la izquierda</p>
            ) : (
              items.map((item) => (
                <div key={item.id} className="carrito-item">
                  <div className="carrito-item-info">
                    <div className="carrito-item-detalle">
                      <span className="carrito-item-nombre">{item.nombre}</span>
                      <span className="carrito-item-precio-unit">${Number(item.precio).toFixed(2)} c/u</span>
                    </div>
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

                    {/* Cantidad editable: click para editar */}
                    {editandoCantidad === item.id ? (
                      <input
                        type="number"
                        className="qty-input"
                        value={cantidadTemp}
                        onChange={e => setCantidadTemp(e.target.value)}
                        onBlur={() => {
                          setCantidadDirecta(item.id, cantidadTemp);
                          setEditandoCantidad(null);
                        }}
                        onKeyDown={e => {
                          if (e.key === 'Enter') {
                            setCantidadDirecta(item.id, cantidadTemp);
                            setEditandoCantidad(null);
                          }
                          if (e.key === 'Escape') setEditandoCantidad(null);
                        }}
                        autoFocus
                        min="1"
                        max={item.stock}
                      />
                    ) : (
                      <span
                        className="qty-num qty-num--editable"
                        onClick={() => {
                          setEditandoCantidad(item.id);
                          setCantidadTemp(String(item.cantidad));
                        }}
                        title="Click para editar cantidad"
                      >{item.cantidad}</span>
                    )}

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
              <div className="desc-header">
                <span className="carrito-label">Descuento</span>
                <div className="desc-tipo-toggle">
                  <button
                    type="button"
                    className={`desc-tipo-btn${descuentoTipo === 'porcentaje' ? ' activo' : ''}`}
                    onClick={() => { setDescuentoTipo('porcentaje'); setDescuento(0); }}
                  >%</button>
                  <button
                    type="button"
                    className={`desc-tipo-btn${descuentoTipo === 'monto' ? ' activo' : ''}`}
                    onClick={() => { setDescuentoTipo('monto'); setDescuento(0); }}
                  >$</button>
                </div>
              </div>
              {descuentoTipo === 'porcentaje' ? (
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
              ) : (
                <input
                  type="number"
                  className="desc-monto-input"
                  placeholder="Monto descuento..."
                  value={descuento || ''}
                  onChange={e => setDescuentoSeguro(e.target.value)}
                  min="0"
                  step="0.01"
                />
              )}
            </div>
            <div className="carrito-metodo">
              <span className="carrito-label">Pago</span>
              <div className="metodo-btns">
                {[
                  { value: 'efectivo',      emoji: '💵', label: 'Efectivo' },
                  { value: 'tarjeta',       emoji: '💳', label: 'Tarjeta' },
                  { value: 'transferencia', emoji: '🏦', label: 'Transf.' },
                ].map(m => (
                  <button
                    key={m.value}
                    type="button"
                    className={`btn-metodo${metodoPago === m.value ? ' activo' : ''}`}
                    onClick={() => setMetodoPago(m.value)}
                    title={m.label}
                  >
                    <span className="metodo-emoji">{m.emoji}</span>
                    <span className="metodo-label">{m.label}</span>
                  </button>
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
              <button
                type="button"
                className="btn-exacto"
                onClick={() => setMontoRecibido(String(totalConDesc))}
                disabled={totalConDesc <= 0}
                title="Monto exacto (F4)"
              >= Exacto</button>
              {[1000, 500, 200, 100, 50, 20].map(val => (
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
              <p className="carrito-subtotal">
                Subtotal: ${calcularTotal().toFixed(2)}
                {descuentoTipo === 'porcentaje' ? ` (−${descuento}%)` : ` (−$${descuento.toFixed(2)})`}
              </p>
            )}
            <div className="carrito-total-box">
              <span className="carrito-total-label">Total</span>
              <span className="carrito-total-monto">${totalConDesc.toFixed(2)}</span>
            </div>
            <button
              className="btn-cobrar"
              onClick={handleSubmit}
              disabled={items.length === 0 || registrando}
            >
              {registrando ? 'Registrando...' : '✅ COBRAR'}
            </button>
          </div>

          {/* Atajos info */}
          <div className="atajos-info">
            <span>F2 Buscar</span>
            <span>Esc Limpiar</span>
            <span>Ctrl+Enter Cobrar</span>
          </div>
        </div>
      </div>
    </>
  );
};

export default VentaForm;
