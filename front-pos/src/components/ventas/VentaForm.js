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
  const [mostrarPausadas, setMostrarPausadas] = useState(false);
  const pausadasRef = useRef(null);
  // Ref sincrono para evitar doble cobro en eventos rapidos (ctrl+enter)
  const procesandoRef = useRef(false);

  // Cerrar dropdown al hacer click fuera
  useEffect(() => {
    if (!mostrarPausadas) return;
    const onClickFuera = (e) => {
      if (pausadasRef.current && !pausadasRef.current.contains(e.target)) {
        setMostrarPausadas(false);
      }
    };
    document.addEventListener('mousedown', onClickFuera);
    return () => document.removeEventListener('mousedown', onClickFuera);
  }, [mostrarPausadas]);

  // Cantidades reservadas por órdenes pausadas (id → cantidad total)
  const reservadoPausadas = useMemo(() => {
    const map = {};
    ordenesPausadas.forEach(o => {
      o.items.forEach(it => {
        map[it.id] = (map[it.id] || 0) + Number(it.cantidad);
      });
    });
    return map;
  }, [ordenesPausadas]);

  // Productos con stock ajustado (descontando lo reservado por órdenes pausadas)
  const productosAjustados = useMemo(() => {
    if (Object.keys(reservadoPausadas).length === 0) return productosDisponibles;
    return productosDisponibles.map(p => ({
      ...p,
      stock: Math.max(0, Number(p.stock) - (reservadoPausadas[p.id] || 0)),
    }));
  }, [productosDisponibles, reservadoPausadas]);

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

  // Stock máximo real para un producto id (descontando reservas de pausadas)
  const stockMaximo = useCallback((id) => {
    const prod = productosDisponibles.find(p => p.id === id);
    if (!prod) return 0;
    return Math.max(0, Number(prod.stock) - (reservadoPausadas[id] || 0));
  }, [productosDisponibles, reservadoPausadas]);

  const agregarProducto = (producto) => {
    const stockMax = stockMaximo(producto.id);
    const yaExiste = items.find((i) => i.id === producto.id);
    if (yaExiste) {
      if (yaExiste.cantidad < stockMax) {
        setItems(items.map((i) =>
          i.id === producto.id ? { ...i, cantidad: i.cantidad + 1 } : i
        ));
      } else {
        addToast('No puedes agregar más: stock reservado en órdenes pausadas.', 'aviso');
      }
    } else {
      if (stockMax <= 0) {
        addToast('Sin stock disponible (reservado en órdenes pausadas).', 'aviso');
        return;
      }
      setItems([...items, { ...producto, cantidad: 1 }]);
    }
  };

  const actualizarCantidad = (id, delta) => {
    const stockMax = stockMaximo(id);
    setItems(items.map((item) => {
      if (item.id !== id) return item;
      const nueva = Math.max(1, Math.min(stockMax, item.cantidad + delta));
      return { ...item, cantidad: nueva };
    }));
  };

  const setCantidadDirecta = (id, cantidad) => {
    const num = parseInt(cantidad);
    if (isNaN(num) || num < 1) return;
    const stockMax = stockMaximo(id);
    setItems(items.map(item => {
      if (item.id !== id) return item;
      return { ...item, cantidad: Math.min(num, stockMax) };
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
    setMostrarPausadas(false);
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
    // Ctrl+ArrowUp = monto exacto
    if (e.ctrlKey && e.key === 'ArrowUp') {
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
            productos={productosAjustados}
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
                <div
                  className={`pausadas-dropdown${mostrarPausadas ? ' pausadas-dropdown--abierto' : ''}`}
                  ref={pausadasRef}
                >
                  <button
                    className="btn-pausadas"
                    title="Órdenes pausadas"
                    onClick={() => setMostrarPausadas(v => !v)}
                    type="button"
                  >
                    ⏸ {ordenesPausadas.length}
                  </button>
                  <div className="pausadas-menu">
                    {ordenesPausadas.map((o, i) => {
                      const totalOrden = o.items.reduce(
                        (acc, it) => acc + Number(it.precio) * Number(it.cantidad), 0
                      );
                      return (
                        <button
                          key={i}
                          className="pausada-item"
                          onClick={() => recuperarOrden(i)}
                          title="Recuperar orden"
                        >
                          <div className="pausada-item-header">
                            <span className="pausada-item-titulo">Orden #{i + 1}</span>
                            <span className="pausada-item-total">${totalOrden.toFixed(2)}</span>
                          </div>
                          <ul className="pausada-item-productos">
                            {o.items.slice(0, 4).map((it, idx) => (
                              <li key={idx}>
                                <span className="pausada-prod-nombre">{it.nombre}</span>
                                <span className="pausada-prod-cant">×{it.cantidad}</span>
                              </li>
                            ))}
                            {o.items.length > 4 && (
                              <li className="pausada-mas">+{o.items.length - 4} más…</li>
                            )}
                          </ul>
                        </button>
                      );
                    })}
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
                  <div className="carrito-item-row">
                    <div className="carrito-item-info">
                      <span className="carrito-item-nombre">{item.nombre}</span>
                      {item.descripcion && item.descripcion !== 'Sin descripcion' && (
                        <span className="carrito-item-desc">{item.descripcion}</span>
                      )}
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
                    <span className="carrito-item-subtotal">
                      ${(Number(item.precio) * item.cantidad).toFixed(2)}
                    </span>
                  </div>
                </div>
              ))
            )}
          </div>

          {/* ── Descuento % + Método pago (misma fila) ── */}
          <div className="carrito-opciones">
            <div className="desc-btns">
              {[0, 10, 15, 20, 25].map(d => (
                <button
                  key={d}
                  type="button"
                  className={`btn-op${descuento === d ? ' btn-op--activo' : ''}`}
                  onClick={() => { setDescuentoTipo('porcentaje'); setDescuento(d); }}
                >{d}%</button>
              ))}
            </div>
            <div className="metodo-btns">
              {[
                { value: 'efectivo', label: '💵' },
                { value: 'tarjeta', label: '💳' },
                { value: 'transferencia', label: '🏦' },
              ].map(m => (
                <button
                  key={m.value}
                  type="button"
                  className={`btn-op${metodoPago === m.value ? ' btn-op--activo' : ''}`}
                  onClick={() => setMetodoPago(m.value)}
                >{m.label}</button>
              ))}
            </div>
          </div>

          {/* ── Monto recibido + TOTAL ── */}
          <div className="carrito-recibido">
            <div className="recibido-row">
              <button
                type="button"
                className="btn-exacto"
                onClick={() => setMontoRecibido(String(totalConDesc))}
                disabled={totalConDesc <= 0}
              >=</button>
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
                <button type="button" className="btn-limpiar" onClick={() => setMontoRecibido('')}>✕</button>
              )}
              <div className="recibido-total-badge">
                <span className="rtb-label">TOTAL</span>
                <span className="rtb-monto">${totalConDesc.toFixed(2)}</span>
              </div>
            </div>
            {montoRecibido && recibido >= totalConDesc && (
              <p className="cambio-ok">Cambio: <strong>${calcularCambio().toFixed(2)}</strong></p>
            )}
            {montoRecibido && recibido < totalConDesc && (
              <p className="cambio-falta">Faltan: ${(totalConDesc - recibido).toFixed(2)}</p>
            )}
          </div>

          {/* ── Billetero: 2 columnas (billetes | monedas) ── */}
          <div className="billetero">
            <div className="billetero-col">
              {[1000, 500, 200, 100, 50, 20].map(val => (
                <button key={val} type="button" className="btn-billete"
                  onClick={() => setMontoRecibido(prev => String((parseFloat(prev) || 0) + val))}
                >${val}</button>
              ))}
            </div>
            <div className="billetero-col billetero-col--monedas">
              {[10, 5, 2, 1].map(val => (
                <button key={val} type="button" className="btn-moneda"
                  onClick={() => setMontoRecibido(prev => String((parseFloat(prev) || 0) + val))}
                >${val}</button>
              ))}
            </div>
          </div>

          {/* ── COBRAR ── */}
          <button
            className="btn-cobrar"
            onClick={handleSubmit}
            disabled={items.length === 0 || registrando}
          >
            {registrando ? 'Registrando...' : '✅ COBRAR'}
            <span className="btn-cobrar-shortcut">Ctrl+Enter</span>
          </button>
        </div>
      </div>
    </>
  );
};

export default VentaForm;
