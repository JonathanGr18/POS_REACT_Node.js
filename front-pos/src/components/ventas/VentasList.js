import React, { useState, useCallback, lazy, Suspense, memo } from 'react';
import './VentasList.css';

// Lazy-load los modales pesados (html2canvas, jsPDF solo cargan al abrirlos)
const TicketPreviewModal = lazy(() => import('../reportes/TicketPreviewModal'));
const EditarVentaModal = lazy(() => import('./EditarVentaModal'));

// Fila memoizada: solo re-renderiza si cambia la venta o los handlers
const VentaFila = memo(({ venta, onTicket, onEditar }) => (
  <tr>
    <td>{venta.id}</td>
    <td className="col-prod-cell">
      <ul className="venta-productos">
        {(venta.productos || []).map((p, idx) => (
          <li key={idx}>
            {p.producto} × {p.cantidad} — ${Number(p.precio).toFixed(2)}
          </li>
        ))}
      </ul>
    </td>
    <td>${Number(venta.total).toFixed(2)}</td>
    <td>{new Date(venta.fecha).toLocaleDateString()}</td>
    <td>
      <div className="venta-acciones">
        <button
          className="btn-imprimir"
          onClick={() => onTicket(venta)}
          title="Ver ticket"
        >
          🧾 Ticket
        </button>
        <button
          className="btn-editar"
          onClick={() => onEditar(venta)}
          title="Editar venta"
        >
          ✏️ Editar
        </button>
      </div>
    </td>
  </tr>
));

const VentaList = ({ ventas = [], onVentaModificada }) => {
  const [ventaTicket, setVentaTicket] = useState(null);
  const [ventaEditar, setVentaEditar] = useState(null);

  // Handlers estables: evitan re-render de VentaFila al cambiar paginación
  const handleTicket = useCallback((v) => setVentaTicket(v), []);
  const handleEditar = useCallback((v) => setVentaEditar(v), []);
  const cerrarTicket = useCallback(() => setVentaTicket(null), []);
  const cerrarEditar = useCallback(() => setVentaEditar(null), []);
  const actualizado = useCallback(() => {
    setVentaTicket(null);
    setVentaEditar(null);
    onVentaModificada?.();
  }, [onVentaModificada]);

  return (
    <div className="venta-list-container">
      <div className="tabla-responsive">
        <table className="venta-table">
          <colgroup>
            <col className="col-id" />
            <col className="col-prod" />
            <col className="col-total" />
            <col className="col-fecha" />
            <col className="col-acciones" />
          </colgroup>
          <thead>
            <tr>
              <th>ID</th>
              <th className="col-prod-head">Productos</th>
              <th>Total</th>
              <th>Fecha</th>
              <th>Acciones</th>
            </tr>
          </thead>
          <tbody>
            {ventas.length === 0 ? (
              <tr>
                <td colSpan="5" className="no-data">No hay ventas registradas.</td>
              </tr>
            ) : (
              ventas.map((venta) => (
                <VentaFila
                  key={venta.id}
                  venta={venta}
                  onTicket={handleTicket}
                  onEditar={handleEditar}
                />
              ))
            )}
          </tbody>
        </table>
      </div>

      {/* Modales solo se cargan cuando se abren */}
      <Suspense fallback={null}>
        {ventaTicket && (
          <TicketPreviewModal
            venta={ventaTicket}
            onCerrar={cerrarTicket}
            onVentaModificada={actualizado}
          />
        )}
        {ventaEditar && (
          <EditarVentaModal
            venta={ventaEditar}
            onCerrar={cerrarEditar}
            onActualizado={actualizado}
          />
        )}
      </Suspense>
    </div>
  );
};

export default memo(VentaList);
