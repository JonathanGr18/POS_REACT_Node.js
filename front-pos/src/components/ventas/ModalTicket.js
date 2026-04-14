import React, { useEffect, useRef } from 'react';
import './ModalTicket.css';

const ModalTicket = ({ venta, onCerrar }) => {
  const closeBtnRef = useRef(null);
  const previouslyFocusedRef = useRef(null);

  useEffect(() => {
    if (!venta) return;
    previouslyFocusedRef.current = document.activeElement;
    setTimeout(() => closeBtnRef.current?.focus(), 0);
    const prevOverflow = document.body.style.overflow;
    document.body.style.overflow = 'hidden';
    const onKey = (e) => { if (e.key === 'Escape') onCerrar(); };
    window.addEventListener('keydown', onKey);
    return () => {
      window.removeEventListener('keydown', onKey);
      document.body.style.overflow = prevOverflow;
      previouslyFocusedRef.current?.focus?.();
    };
  }, [venta, onCerrar]);

  if (!venta) return null;

  return (
    <div className="modal-overlay" onClick={onCerrar} aria-hidden="true">
      <div
        className="ticket-box"
        onClick={e => e.stopPropagation()}
        role="dialog"
        aria-modal="true"
        aria-labelledby="ticket-title"
      >
        <div className="ticket-header">
          <h3 id="ticket-title">Venta Registrada</h3>
          <span className="ticket-check" aria-hidden="true">✓</span>
        </div>

        <table className="ticket-tabla">
          <thead>
            <tr>
              <th>Producto</th>
              <th>Cant.</th>
              <th>Subtotal</th>
            </tr>
          </thead>
          <tbody>
            {venta.productos.map((p, i) => (
              <tr key={p.id ?? `${p.producto || p.nombre}-${i}`}>
                {/* BUG FIX: el campo es p.producto (no p.nombre) según el esquema de detalle_venta */}
                <td>{p.producto || p.nombre}</td>
                <td style={{ textAlign: 'center' }}>{p.cantidad}</td>
                {/* BUG FIX: Convertir a Number para evitar concatenación de strings */}
                <td style={{ textAlign: 'right' }}>${(Number(p.precio) * Number(p.cantidad)).toFixed(2)}</td>
              </tr>
            ))}
          </tbody>
        </table>

        {/* BUG FIX: Convertir total a Number ya que puede llegar como string desde la API */}
        <p className="ticket-total">Total: <strong>${Number(venta.total).toFixed(2)}</strong></p>
        {venta.metodo_pago && (
          <p className="ticket-metodo">
            {venta.metodo_pago === 'efectivo' ? '💵' : venta.metodo_pago === 'tarjeta' ? '💳' : '🏦'}{' '}
            {venta.metodo_pago.charAt(0).toUpperCase() + venta.metodo_pago.slice(1)}
          </p>
        )}

        <button
          ref={closeBtnRef}
          className="btn btn-primary ticket-cerrar"
          onClick={onCerrar}
        >
          Cerrar
        </button>
      </div>
    </div>
  );
};

export default ModalTicket;
