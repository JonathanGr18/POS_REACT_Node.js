import React, { useState } from 'react';
import api from '../../services/api';
import { useToast } from '../ui/Toast';
import './EditarVentaModal.css';

const EditarVentaModal = ({ venta, onCerrar, onActualizado }) => {
  const { addToast } = useToast();
  const [password, setPassword] = useState('');
  const [metodoPago, setMetodoPago] = useState(venta?.metodo_pago || 'efectivo');
  const [accion, setAccion] = useState('editar'); // 'editar' | 'anular'
  const [procesando, setProcesando] = useState(false);

  if (!venta) return null;

  const folio = `#${String(venta.id).padStart(4, '0')}`;
  const fecha = new Date(venta.fecha).toLocaleString('es-MX');

  const handleEditar = async () => {
    if (!password.trim()) {
      addToast('Ingresa la contraseña de administrador', 'aviso');
      return;
    }
    setProcesando(true);
    try {
      await api.patch(`/ventas/${venta.id}`, {
        metodo_pago: metodoPago,
        password,
      });
      addToast(`Venta ${folio} actualizada`, 'exito');
      onActualizado?.();
      onCerrar();
    } catch (err) {
      addToast(err?.response?.data?.error || 'Error al editar venta', 'error');
    } finally {
      setProcesando(false);
    }
  };

  const handleAnular = async () => {
    if (!password.trim()) {
      addToast('Ingresa la contraseña de administrador', 'aviso');
      return;
    }
    // eslint-disable-next-line no-alert
    if (!window.confirm(`¿Anular venta ${folio} por $${Number(venta.total).toFixed(2)}?\n\nEsto devolverá el stock de todos los productos y eliminará la venta. Esta acción NO se puede deshacer.`)) {
      return;
    }
    setProcesando(true);
    try {
      const res = await api.post(`/ventas/${venta.id}/anular`, { password });
      addToast(`Venta ${folio} anulada. ${res.data.productos_devueltos} productos devueltos al stock.`, 'exito');
      onActualizado?.();
      onCerrar();
    } catch (err) {
      addToast(err?.response?.data?.error || 'Error al anular venta', 'error');
    } finally {
      setProcesando(false);
    }
  };

  return (
    <div className="evm-overlay" onClick={onCerrar}>
      <div className="evm-box" onClick={e => e.stopPropagation()} role="dialog" aria-modal="true">
        <div className="evm-header">
          <h3>Modificar Venta {folio}</h3>
          <button className="evm-close" onClick={onCerrar}>✕</button>
        </div>

        <div className="evm-body">
          {/* Info de la venta */}
          <div className="evm-info">
            <p><strong>Fecha:</strong> {fecha}</p>
            <p><strong>Total:</strong> ${Number(venta.total).toFixed(2)}</p>
            <p><strong>Método actual:</strong> {venta.metodo_pago}</p>
            {venta.descuento > 0 && <p><strong>Descuento:</strong> ${Number(venta.descuento).toFixed(2)}</p>}
          </div>

          {/* Productos de la venta */}
          <div className="evm-productos">
            <p className="evm-label">Productos:</p>
            <ul>
              {(venta.productos || []).map((p, i) => (
                <li key={i}>{p.cantidad}x {p.producto} — ${(Number(p.precio) * p.cantidad).toFixed(2)}</li>
              ))}
            </ul>
          </div>

          {/* Tabs: Editar / Anular */}
          <div className="evm-tabs">
            <button
              className={`evm-tab${accion === 'editar' ? ' evm-tab--activo' : ''}`}
              onClick={() => setAccion('editar')}
            >
              Editar método de pago
            </button>
            <button
              className={`evm-tab evm-tab--danger${accion === 'anular' ? ' evm-tab--activo' : ''}`}
              onClick={() => setAccion('anular')}
            >
              Anular venta
            </button>
          </div>

          {accion === 'editar' && (
            <div className="evm-editar">
              <p className="evm-label">Nuevo método de pago:</p>
              <div className="evm-metodos">
                {[
                  { value: 'efectivo', label: '💵 Efectivo' },
                  { value: 'tarjeta', label: '💳 Tarjeta' },
                  { value: 'transferencia', label: '🏦 Transferencia' },
                ].map(m => (
                  <button
                    key={m.value}
                    className={`evm-metodo-btn${metodoPago === m.value ? ' activo' : ''}`}
                    onClick={() => setMetodoPago(m.value)}
                  >{m.label}</button>
                ))}
              </div>
            </div>
          )}

          {accion === 'anular' && (
            <div className="evm-anular">
              <p className="evm-warning">
                ⚠️ Al anular esta venta:
              </p>
              <ul className="evm-warning-list">
                <li>Se devuelve el stock de {(venta.productos || []).length} producto(s)</li>
                <li>Se elimina la venta del historial</li>
                <li>Se resta ${Number(venta.total).toFixed(2)} de los ingresos</li>
                <li>Esta acción NO se puede deshacer</li>
              </ul>
            </div>
          )}

          {/* Contraseña admin */}
          <div className="evm-password">
            <label htmlFor="evm-pass" className="evm-label">Contraseña de administrador:</label>
            <input
              id="evm-pass"
              type="password"
              className="evm-input"
              value={password}
              onChange={e => setPassword(e.target.value)}
              placeholder="Ingresa contraseña..."
              onKeyDown={e => {
                if (e.key === 'Enter') {
                  accion === 'editar' ? handleEditar() : handleAnular();
                }
              }}
              autoFocus
            />
          </div>
        </div>

        <div className="evm-footer">
          <button className="btn btn-secondary" onClick={onCerrar} disabled={procesando}>
            Cancelar
          </button>
          {accion === 'editar' ? (
            <button
              className="btn btn-primary"
              onClick={handleEditar}
              disabled={procesando || metodoPago === venta.metodo_pago}
            >
              {procesando ? 'Guardando...' : 'Guardar cambios'}
            </button>
          ) : (
            <button
              className="btn btn-danger"
              onClick={handleAnular}
              disabled={procesando}
            >
              {procesando ? 'Anulando...' : 'Anular venta'}
            </button>
          )}
        </div>
      </div>
    </div>
  );
};

export default EditarVentaModal;
