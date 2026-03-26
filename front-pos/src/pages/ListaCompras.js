import React, { useEffect, useState, useMemo } from 'react';
import api from '../services/api';
import { useToast } from '../components/ui/Toast';
import Spinner from '../components/ui/Spinner';
import ConfirmModal from '../components/ui/ConfirmModal';
import './ListaCompras.css';

const ListaCompras = () => {
  const [items, setItems] = useState([]);
  const [cargando, setCargando] = useState(true);
  const [modalLimpiar, setModalLimpiar] = useState(false);
  // FIX #4: estado para deshabilitar botón durante limpiarCompletados y evitar doble clic
  const [limpiando, setLimpiando] = useState(false);
  // FIX #5: modal de confirmación antes de eliminar un item individual
  const [modalEliminar, setModalEliminar] = useState({ visible: false, id: null });
  const { addToast } = useToast();

  const cargarLista = async () => {
    try {
      setCargando(true);
      const res = await api.get('/lista-compras');
      setItems(res.data);
    } catch (err) {
      addToast('Error al cargar la lista de compras', 'error');
    } finally {
      setCargando(false);
    }
  };

  useEffect(() => {
    cargarLista();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const toggleItem = async (id) => {
    // Optimistic update
    setItems(prev =>
      prev.map(item => item.id === id ? { ...item, completado: !item.completado } : item)
    );
    try {
      await api.patch(`/lista-compras/${id}/toggle`);
    } catch (err) {
      // Revert on failure
      setItems(prev =>
        prev.map(item => item.id === id ? { ...item, completado: !item.completado } : item)
      );
      addToast('Error al actualizar el item', 'error');
    }
  };

  // FIX #5: eliminarItem ahora requiere confirmación via modal antes de ejecutarse
  const confirmarEliminar = (id) => {
    setModalEliminar({ visible: true, id });
  };

  const eliminarItem = async () => {
    const id = modalEliminar.id;
    setModalEliminar({ visible: false, id: null });
    // Optimistic update
    setItems(prev => prev.filter(item => item.id !== id));
    try {
      await api.delete(`/lista-compras/${id}`);
      // FIX #1: notificar al usuario cuando el item se elimina exitosamente
      addToast('Item eliminado', 'exito');
    } catch (err) {
      addToast('Error al eliminar el item', 'error');
      await cargarLista();
    }
  };

  const limpiarCompletados = async () => {
    // FIX #4: marcar como "limpiando" para deshabilitar el botón y evitar doble envío
    setLimpiando(true);
    try {
      await api.delete('/lista-compras/completados');
      await cargarLista();
      setModalLimpiar(false);
      addToast('Items completados eliminados', 'exito');
    } catch (err) {
      setModalLimpiar(false);
      addToast('Error al limpiar completados', 'error');
    } finally {
      setLimpiando(false);
    }
  };

  const actualizarCantidad = async (id, cantidad) => {
    if (cantidad <= 0) return;
    const cantidadAnterior = items.find(item => item.id === id)?.cantidad;
    // FIX #3: no hacer petición PATCH si la cantidad no cambió
    if (cantidadAnterior === cantidad) return;
    // Optimistic update
    setItems(prev =>
      prev.map(item => item.id === id ? { ...item, cantidad } : item)
    );
    try {
      await api.patch(`/lista-compras/${id}`, { cantidad });
    } catch (err) {
      // Revertir el estado local y notificar al usuario si la petición falla
      if (cantidadAnterior !== undefined) {
        setItems(prev =>
          prev.map(item => item.id === id ? { ...item, cantidad: cantidadAnterior } : item)
        );
      }
      addToast('Error al actualizar la cantidad', 'error');
    }
  };

  const itemsPorTienda = useMemo(() => {
    const grupos = {};
    items.forEach(item => {
      const key = item.tienda_id || 'sin-tienda';
      const label = item.nombre_tienda || 'Sin tienda asignada';
      const dir = item.direccion_tienda || '';
      if (!grupos[key]) grupos[key] = { label, dir, items: [] };
      grupos[key].items.push(item);
    });
    return Object.values(grupos);
  }, [items]);

  const handleImprimir = () => {
    const fecha = new Date().toLocaleDateString('es-MX', {
      weekday: 'long',
      year: 'numeric',
      month: 'long',
      day: 'numeric'
    });

    const gruposHTML = itemsPorTienda.map(grupo => {
      const filasHTML = grupo.items.map(item => `
        <tr>
          <td>${item.nombre_producto}</td>
          <td style="text-align:center">${item.cantidad}</td>
          <td style="text-align:right">${item.precio_ref ? '$' + Number(item.precio_ref).toFixed(2) : '—'}</td>
          <td style="text-align:center">☐</td>
        </tr>
      `).join('');

      return `
        <div class="grupo-print">
          <h3>${grupo.label}</h3>
          ${grupo.dir ? `<p class="dir-print">📍 ${grupo.dir}</p>` : ''}
          <table>
            <thead>
              <tr>
                <th>Producto</th>
                <th>Cantidad</th>
                <th>Precio Ref.</th>
                <th>✓</th>
              </tr>
            </thead>
            <tbody>
              ${filasHTML}
            </tbody>
          </table>
        </div>
      `;
    }).join('');

    const html = `
      <!DOCTYPE html>
      <html lang="es">
      <head>
        <meta charset="UTF-8" />
        <title>Lista de Compras</title>
        <style>
          body { font-family: 'Segoe UI', sans-serif; padding: 24px; color: #2c3e50; }
          h1 { font-size: 1.4rem; margin-bottom: 4px; }
          .fecha { color: #7f8c8d; font-size: 0.9rem; margin-bottom: 24px; }
          .grupo-print { margin-bottom: 28px; page-break-inside: avoid; }
          .grupo-print h3 { font-size: 1.05rem; background: #9967CE; color: white; padding: 6px 10px; border-radius: 6px 6px 0 0; margin: 0; }
          .dir-print { font-size: 0.82rem; color: #7f8c8d; margin: 4px 0 8px; }
          table { width: 100%; border-collapse: collapse; font-size: 0.88rem; }
          th { background: #f1f1f1; padding: 6px 10px; text-align: left; border-bottom: 2px solid #ddd; }
          td { padding: 6px 10px; border-bottom: 1px solid #eee; }
          tr:last-child td { border-bottom: none; }
          @media print { body { padding: 0; } }
        </style>
      </head>
      <body>
        <h1>🛒 Lista de Compras</h1>
        <p class="fecha">${fecha}</p>
        ${gruposHTML}
      </body>
      </html>
    `;

    // FIX #6: manejar el caso en que el navegador bloquea el popup (ventana === null)
    const ventana = window.open('', '_blank', 'width=800,height=600');
    if (!ventana) {
      addToast('El navegador bloqueó la ventana emergente. Permite popups para imprimir.', 'error');
      return;
    }
    ventana.document.write(html);
    ventana.document.close();
    ventana.focus();
    ventana.print();
  };

  return (
    <div className="lista-compras-page">
      <div className="lista-header">
        <h2>🛒 Lista de Compras</h2>
        <div className="lista-acciones">
          <button
            className="btn btn-secondary"
            onClick={handleImprimir}
            disabled={items.length === 0}
          >
            🖨️ Imprimir ruta
          </button>
          <button
            className="btn btn-danger"
            onClick={() => setModalLimpiar(true)}
            disabled={!items.some(i => i.completado)}
          >
            🧹 Limpiar completados
          </button>
        </div>
      </div>

      {cargando ? (
        <Spinner />
      ) : items.length === 0 ? (
        <div className="lista-vacia">
          <p>📋 La lista está vacía.</p>
          <p>Ve a <strong>Tiendas</strong> y agrega productos a la lista.</p>
        </div>
      ) : (
        <div className="lista-grupos">
          {itemsPorTienda.map((grupo, gi) => (
            <div key={gi} className="grupo-tienda">
              <div className="grupo-header">
                <div>
                  <h3>🏪 {grupo.label}</h3>
                  {grupo.dir && <p className="grupo-dir">📍 {grupo.dir}</p>}
                </div>
                <span className="grupo-badge">
                  {grupo.items.filter(i => !i.completado).length} pendientes
                </span>
              </div>
              <div className="grupo-items">
                {grupo.items.map(item => (
                  <div
                    key={item.id}
                    className={`lista-item ${item.completado ? 'completado' : ''}`}
                  >
                    <input
                      type="checkbox"
                      checked={item.completado}
                      onChange={() => toggleItem(item.id)}
                      className="lista-check"
                    />
                    <div className="lista-item-info">
                      <span className="lista-item-nombre">{item.nombre_producto}</span>
                      {item.precio_ref && (
                        <span className="lista-precio">
                          ~${Number(item.precio_ref).toFixed(2)}
                        </span>
                      )}
                      {item.notas && (
                        <span className="lista-notas">{item.notas}</span>
                      )}
                    </div>
                    <div className="lista-item-cantidad">
                      <button
                        onClick={() => actualizarCantidad(item.id, Math.max(1, item.cantidad - 1))}
                      >
                        −
                      </button>
                      <span>{item.cantidad}</span>
                      <button
                        onClick={() => actualizarCantidad(item.id, item.cantidad + 1)}
                      >
                        +
                      </button>
                    </div>
                    {/* FIX #5: ahora abre modal de confirmación en lugar de eliminar directo */}
                    <button
                      className="btn-eliminar-item"
                      onClick={() => confirmarEliminar(item.id)}
                      title="Eliminar"
                    >
                      ✕
                    </button>
                  </div>
                ))}
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Modal confirmación: limpiar completados */}
      <ConfirmModal
        visible={modalLimpiar}
        mensaje="¿Eliminar todos los items completados?"
        textoConfirmar={limpiando ? 'Limpiando...' : 'Sí, limpiar'}
        tipoBtnConfirmar="btn-danger"
        onConfirm={limpiarCompletados}
        onCancel={() => { if (!limpiando) setModalLimpiar(false); }}
      />

      {/* FIX #5: Modal confirmación antes de eliminar un item individual */}
      <ConfirmModal
        visible={modalEliminar.visible}
        mensaje="¿Eliminar este producto de la lista?"
        textoConfirmar="Sí, eliminar"
        tipoBtnConfirmar="btn-danger"
        onConfirm={eliminarItem}
        onCancel={() => setModalEliminar({ visible: false, id: null })}
      />
    </div>
  );
};

export default ListaCompras;
