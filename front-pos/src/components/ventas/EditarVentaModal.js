import React, { useState, useEffect, useMemo, useCallback } from 'react';
import { createPortal } from 'react-dom';
import api from '../../services/api';
import { getProductosCache, invalidarProductosCache } from '../../services/productosCache';
import { useToast } from '../ui/Toast';
import useDebounce from '../../hooks/useDebounce';
import './EditarVentaModal.css';

const EditarVentaModal = ({ venta, onCerrar, onActualizado }) => {
  const { addToast } = useToast();
  const [metodoPago, setMetodoPago] = useState(venta?.metodo_pago || 'efectivo');
  const [descuento, setDescuento] = useState(Number(venta?.descuento || 0));
  const [items, setItems] = useState(
    (venta?.productos || []).map(p => ({
      nombre: p.producto,
      cantidad: Number(p.cantidad) || 1,
      precio: Number(p.precio) || 0,
      id: p.id ?? null,
    }))
  );
  const [motivo, setMotivo] = useState('');
  const [busqueda, setBusqueda] = useState('');
  const busquedaDebounced = useDebounce(busqueda, 300);
  const [productosCatalogo, setProductosCatalogo] = useState([]);

  // Clave preferida: id (único). Fallback: nombre (para ventas legacy sin id).
  const claveItem = (it) => (it?.id != null ? `id:${it.id}` : `n:${it?.nombre || it?.producto || ''}`);

  // Snapshot original de cantidades por clave
  const originalQtyMap = useMemo(() => {
    const map = {};
    (venta?.productos || []).forEach(p => {
      const k = p.id != null ? `id:${p.id}` : `n:${p.producto}`;
      map[k] = (map[k] || 0) + Number(p.cantidad || 0);
    });
    return map;
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  // Stock del catálogo por clave (id preferido, nombre como fallback)
  const stockCatalogoMap = useMemo(() => {
    const map = {};
    productosCatalogo.forEach(p => {
      map[`id:${p.id}`] = Number(p.stock) || 0;
      // también guardamos por nombre para legacy lookup
      if (p.nombre && !(`n:${p.nombre}` in map)) {
        map[`n:${p.nombre}`] = Number(p.stock) || 0;
      }
    });
    return map;
  }, [productosCatalogo]);

  // Máximo permitido en la venta para un producto (por clave)
  // = stock actual del catálogo + lo que ya estaba en esta venta
  const maxQty = useCallback((item) => {
    const k = claveItem(item);
    const catalog = stockCatalogoMap[k];
    if (catalog == null) return originalQtyMap[k] || 0;
    return catalog + (originalQtyMap[k] || 0);
  }, [stockCatalogoMap, originalQtyMap]);

  // Estados de confirmación
  const [accion, setAccion] = useState(null); // 'editar' | 'anular'
  const [password, setPassword] = useState('');
  const [procesando, setProcesando] = useState(false);

  // Cargar catálogo desde cache (TTL 60s) para evitar fetch de miles de productos en cada apertura
  useEffect(() => {
    let cancelado = false;
    getProductosCache().then(data => {
      if (!cancelado) setProductosCatalogo(data);
    }).catch(() => {});
    return () => { cancelado = true; };
  }, []);

  const folio = `#${String(venta?.id || 0).padStart(4, '0')}`;
  const fecha = venta ? new Date(venta.fecha).toLocaleString('es-MX') : '';

  const subtotal = useMemo(
    () => items.reduce((a, it) => a + it.precio * it.cantidad, 0),
    [items]
  );
  const totalNuevo = Math.max(0, subtotal - descuento);
  const totalOriginal = Number(venta?.total || 0);
  const delta = totalNuevo - totalOriginal;

  // Map de cantidades en el carrito actual por producto id para calcular stock disponible real
  const cantidadEnVenta = useMemo(() => {
    const map = {};
    items.forEach(it => {
      if (it.id != null) map[it.id] = (map[it.id] || 0) + it.cantidad;
    });
    return map;
  }, [items]);

  const sugerencias = useMemo(() => {
    const v = busquedaDebounced.trim().toLowerCase();
    if (!v) return [];
    const tokens = v.split(/\s+/).filter(Boolean);
    return productosCatalogo
      .filter(p => {
        const full = `${(p.nombre || '').toLowerCase()} ${(p.descripcion || '').toLowerCase()} ${p.codigo || ''}`;
        return tokens.every(t => full.includes(t));
      })
      .map(p => {
        // Stock disponible = stock catálogo - cantidad ya en esta venta + lo que ya estaba originalmente
        const enVenta = cantidadEnVenta[p.id] || 0;
        const original = originalQtyMap[`id:${p.id}`] || 0;
        const disponible = Number(p.stock) - enVenta + original;
        return { ...p, _disponible: disponible };
      })
      .slice(0, 10);
  }, [busquedaDebounced, productosCatalogo, cantidadEnVenta, originalQtyMap]);

  const agregarProducto = (p) => {
    // Compara por id (no por nombre) — así dos productos distintos con igual nombre son distintos ítems
    const existente = p.id != null
      ? items.findIndex(it => it.id === p.id)
      : items.findIndex(it => it.id == null && it.nombre === p.nombre);
    const actual = existente >= 0 ? items[existente].cantidad : 0;
    const max = maxQty(p);
    if (actual + 1 > max) {
      addToast(`Stock máximo: ${max} (no puedes agregar más "${p.nombre}")`, 'aviso');
      return;
    }
    if (existente >= 0) {
      setItems(items.map((it, i) =>
        i === existente ? { ...it, cantidad: it.cantidad + 1 } : it
      ));
    } else {
      setItems([...items, {
        id: p.id,
        nombre: p.nombre,
        descripcion: p.descripcion,
        cantidad: 1,
        precio: Number(p.precio),
      }]);
    }
    setBusqueda('');
  };

  const cambiarCantidad = (idx, delta) => {
    setItems(items.map((it, i) => {
      if (i !== idx) return it;
      const nueva = it.cantidad + delta;
      const max = maxQty(it);
      if (nueva > max) {
        addToast(`Stock máximo: ${max} para "${it.nombre}"`, 'aviso');
        return it;
      }
      return { ...it, cantidad: Math.max(1, nueva) };
    }));
  };

  const setCantidadDirecta = (idx, val) => {
    const n = parseInt(val, 10);
    if (isNaN(n) || n < 1) return;
    setItems(items.map((it, i) => {
      if (i !== idx) return it;
      const max = maxQty(it);
      if (n > max) {
        addToast(`Stock máximo: ${max} para "${it.nombre}"`, 'aviso');
        return { ...it, cantidad: max };
      }
      return { ...it, cantidad: n };
    }));
  };

  const eliminarItem = (idx) => {
    setItems(items.filter((_, i) => i !== idx));
  };

  const cambiosDetectados = useMemo(() => {
    if (metodoPago !== venta?.metodo_pago) return true;
    if (Math.abs(descuento - Number(venta?.descuento || 0)) > 0.009) return true;
    const original = (venta?.productos || []).map(p => `${p.producto}:${p.cantidad}:${p.precio}`).sort().join('|');
    const actual = items.map(it => `${it.nombre}:${it.cantidad}:${it.precio}`).sort().join('|');
    return original !== actual;
  }, [items, metodoPago, descuento, venta]);

  const hayItems = items.length > 0;

  // Popup de confirmación con contraseña
  const solicitarConfirmacion = (accionElegida) => {
    if (accionElegida === 'editar') {
      if (!hayItems) { addToast('La venta debe tener al menos un producto', 'aviso'); return; }
      if (!cambiosDetectados) { addToast('No hay cambios para guardar', 'aviso'); return; }
    }
    setPassword('');
    setAccion(accionElegida);
  };

  const cancelarConfirmacion = () => {
    setAccion(null);
    setPassword('');
  };

  const ejecutarEdicion = useCallback(async () => {
    if (!password.trim()) {
      addToast('Ingresa la contraseña de administrador', 'aviso');
      return;
    }
    setProcesando(true);
    try {
      await api.patch(`/ventas/${venta.id}`, {
        password,
        metodo_pago: metodoPago,
        descuento,
        productos: items.map(({ id, nombre, cantidad, precio }) => ({ id, nombre, cantidad, precio })),
        motivo: motivo.trim() || null,
      });
      invalidarProductosCache(); // stock cambió
      addToast(`Venta ${folio} actualizada`, 'exito');
      onActualizado?.();
      onCerrar();
    } catch (err) {
      addToast(err?.response?.data?.error || 'Error al editar venta', 'error');
    } finally {
      setProcesando(false);
    }
  }, [password, metodoPago, descuento, items, motivo, venta, folio, addToast, onActualizado, onCerrar]);

  const ejecutarAnulacion = useCallback(async () => {
    if (!password.trim()) {
      addToast('Ingresa la contraseña de administrador', 'aviso');
      return;
    }
    setProcesando(true);
    try {
      const res = await api.post(`/ventas/${venta.id}/anular`, {
        password,
        motivo: motivo.trim() || null,
      });
      invalidarProductosCache(); // stock devuelto
      addToast(`Venta ${folio} anulada. ${res.data.productos_devueltos} producto(s) devueltos.`, 'exito');
      onActualizado?.();
      onCerrar();
    } catch (err) {
      addToast(err?.response?.data?.error || 'Error al anular venta', 'error');
    } finally {
      setProcesando(false);
    }
  }, [password, motivo, venta, folio, addToast, onActualizado, onCerrar]);

  if (!venta) return null;

  return createPortal((
    <div className="evm-overlay" onClick={onCerrar}>
      <div className="evm-box" onClick={e => e.stopPropagation()} role="dialog" aria-modal="true">
        <div className="evm-header">
          <h3>Modificar Venta {folio}</h3>
          <button className="evm-close" onClick={onCerrar} aria-label="Cerrar">✕</button>
        </div>

        <div className="evm-body">
          <div className="evm-info">
            <p><strong>Fecha:</strong> {fecha}</p>
            <p><strong>Total original:</strong> ${totalOriginal.toFixed(2)}</p>
          </div>

          {/* ── Productos ── */}
          <div className="evm-productos-editor">
            <div className="evm-productos-header">
              <span className="evm-label">Productos ({items.length})</span>
            </div>

            {items.length === 0 ? (
              <p className="evm-sin-productos">
                ⚠️ Sin productos. Agrega al menos uno o anula la venta.
              </p>
            ) : (
              <ul className="evm-items-lista">
                {items.map((it, idx) => {
                  const max = maxQty(it);
                  const enMax = it.cantidad >= max;
                  return (
                    <li key={idx} className="evm-item">
                      <span className="evm-item-nombre" title={`${it.nombre}${it.descripcion ? ' — ' + it.descripcion : ''}`}>
                        {it.nombre}
                        {it.descripcion && it.descripcion !== 'Sin descripcion' && (
                          <span className="evm-item-desc"> · {it.descripcion}</span>
                        )}
                        <span className="evm-item-stock">máx {max}</span>
                      </span>
                      <div className="evm-item-qty">
                        <button type="button" onClick={() => cambiarCantidad(idx, -1)} disabled={it.cantidad <= 1}>−</button>
                        <input
                          type="number"
                          min="1"
                          max={max}
                          value={it.cantidad}
                          onChange={e => setCantidadDirecta(idx, e.target.value)}
                        />
                        <button
                          type="button"
                          onClick={() => cambiarCantidad(idx, +1)}
                          disabled={enMax}
                          title={enMax ? `Stock máximo: ${max}` : ''}
                        >+</button>
                      </div>
                      <span className="evm-item-precio">${it.precio.toFixed(2)}</span>
                      <span className="evm-item-subtotal">${(it.precio * it.cantidad).toFixed(2)}</span>
                      <button
                        type="button"
                        className="evm-item-eliminar"
                        onClick={() => eliminarItem(idx)}
                        title="Quitar producto"
                      >✕</button>
                    </li>
                  );
                })}
              </ul>
            )}

            {/* Buscador para agregar productos */}
            <div className="evm-agregar">
              <input
                type="text"
                className="evm-buscador"
                placeholder="🔍 Buscar producto para agregar..."
                value={busqueda}
                onChange={e => setBusqueda(e.target.value)}
              />
              {sugerencias.length > 0 && (
                <ul className="evm-sugerencias">
                  {sugerencias.map(p => {
                    const agotado = (p._disponible ?? p.stock) <= 0;
                    return (
                      <li
                        key={p.id}
                        className={agotado ? 'sug-agotado' : ''}
                        onClick={() => !agotado && agregarProducto(p)}
                        title={agotado ? 'Sin stock disponible' : ''}
                      >
                        <span className="sug-nombre">{p.nombre}</span>
                        {p.descripcion && p.descripcion !== 'Sin descripcion' && (
                          <span className="sug-desc">{p.descripcion}</span>
                        )}
                        <span className="sug-precio">${Number(p.precio).toFixed(2)}</span>
                        <span className={`sug-stock${agotado ? ' sug-stock--agotado' : ''}`}>
                          {agotado ? '⛔ Sin stock' : `Stock: ${p._disponible ?? p.stock}`}
                        </span>
                      </li>
                    );
                  })}
                </ul>
              )}
            </div>
          </div>

          {/* ── Descuento + Método pago ── */}
          <div className="evm-opciones">
            <label className="evm-campo">
              <span className="evm-label">Descuento ($)</span>
              <input
                type="number"
                min="0"
                step="0.01"
                value={descuento}
                onChange={e => setDescuento(Math.max(0, parseFloat(e.target.value) || 0))}
                className="evm-input"
              />
            </label>
            <label className="evm-campo">
              <span className="evm-label">Método de pago</span>
              <select
                className="evm-input"
                value={metodoPago}
                onChange={e => setMetodoPago(e.target.value)}
              >
                <option value="efectivo">💵 Efectivo</option>
                <option value="tarjeta">💳 Tarjeta</option>
                <option value="transferencia">🏦 Transferencia</option>
              </select>
            </label>
          </div>

          {/* ── Motivo (opcional) ── */}
          <label className="evm-campo">
            <span className="evm-label">Motivo <span className="evm-opcional">(opcional)</span></span>
            <input
              type="text"
              className="evm-input"
              placeholder="Ej: error al cobrar, cliente pidió cambio..."
              value={motivo}
              onChange={e => setMotivo(e.target.value)}
              maxLength={200}
            />
          </label>

          {/* ── Resumen diff ── */}
          <div className="evm-resumen">
            <div className="evm-resumen-row">
              <span>Subtotal</span>
              <strong>${subtotal.toFixed(2)}</strong>
            </div>
            {descuento > 0 && (
              <div className="evm-resumen-row">
                <span>Descuento</span>
                <strong>-${descuento.toFixed(2)}</strong>
              </div>
            )}
            <div className="evm-resumen-row evm-resumen-total">
              <span>Total nuevo</span>
              <strong>${totalNuevo.toFixed(2)}</strong>
            </div>
            {Math.abs(delta) > 0.009 && (
              <div className={`evm-resumen-delta ${delta < 0 ? 'positivo' : 'negativo'}`}>
                {delta < 0
                  ? `💰 Reducción de $${Math.abs(delta).toFixed(2)} (ingresos se ajustan)`
                  : `⬆ Aumento de $${delta.toFixed(2)}`}
              </div>
            )}
          </div>
        </div>

        <div className="evm-footer">
          <button
            className="evm-btn evm-btn--anular"
            onClick={() => solicitarConfirmacion('anular')}
            disabled={procesando}
          >
            🗑 Anular venta
          </button>
          <div className="evm-footer-right">
            <button className="evm-btn evm-btn--cancelar" onClick={onCerrar} disabled={procesando}>
              Cancelar
            </button>
            <button
              className="evm-btn evm-btn--guardar"
              onClick={() => solicitarConfirmacion('editar')}
              disabled={procesando || !cambiosDetectados || !hayItems}
            >
              💾 Guardar cambios
            </button>
          </div>
        </div>

        {/* ── Popup de confirmación con contraseña ── */}
        {accion && (
          <div className="evm-confirm-overlay" onClick={cancelarConfirmacion}>
            <div className="evm-confirm-box" onClick={e => e.stopPropagation()}>
              <div className={`evm-confirm-icono${accion === 'anular' ? ' danger' : ''}`}>
                {accion === 'anular' ? '⚠️' : '🔐'}
              </div>
              <h4>
                {accion === 'anular'
                  ? `¿Anular venta ${folio}?`
                  : `Confirmar cambios`}
              </h4>
              <p className="evm-confirm-msg">
                {accion === 'anular' ? (
                  <>
                    Esta acción devolverá {items.length} producto(s) al stock, restará
                    <strong> ${totalOriginal.toFixed(2)}</strong> de los ingresos y registrará la
                    devolución en reportes. <strong>No se puede deshacer.</strong>
                  </>
                ) : (
                  <>
                    Para modificar esta venta necesitas la
                    <strong> contraseña de administrador</strong>. Los cambios se registran en
                    el historial de devoluciones.
                  </>
                )}
              </p>
              <input
                type="password"
                className="evm-confirm-input"
                placeholder="Contraseña de administrador"
                value={password}
                onChange={e => setPassword(e.target.value)}
                onKeyDown={e => {
                  if (e.key === 'Enter') accion === 'anular' ? ejecutarAnulacion() : ejecutarEdicion();
                  if (e.key === 'Escape') cancelarConfirmacion();
                }}
                autoFocus
              />
              <div className="evm-confirm-actions">
                <button
                  className="evm-btn evm-btn--cancelar"
                  onClick={cancelarConfirmacion}
                  disabled={procesando}
                >
                  Cancelar
                </button>
                <button
                  className={`evm-btn ${accion === 'anular' ? 'evm-btn--anular' : 'evm-btn--guardar'}`}
                  onClick={accion === 'anular' ? ejecutarAnulacion : ejecutarEdicion}
                  disabled={procesando || !password.trim()}
                >
                  {procesando
                    ? 'Procesando...'
                    : accion === 'anular'
                    ? 'Anular venta'
                    : 'Guardar cambios'}
                </button>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  ), document.body);
};

export default EditarVentaModal;
