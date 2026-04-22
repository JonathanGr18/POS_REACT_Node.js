import React, { useState } from 'react';
import { createPortal } from 'react-dom';
import jsPDF from 'jspdf';
import { useSettings } from '../../context/SettingsContext';
import { useToast } from '../ui/Toast';
import EditarVentaModal from '../ventas/EditarVentaModal';
import './TicketPreviewModal.css';

// Carga dinámica de html2canvas (evita problemas de interop ESM/CJS con webpack)
let _html2canvasPromise = null;
const loadHtml2Canvas = () => {
  if (!_html2canvasPromise) {
    _html2canvasPromise = import('html2canvas').then(mod => mod.default || mod);
  }
  return _html2canvasPromise;
};

const TicketPreviewModal = ({ venta, onCerrar, onVentaModificada }) => {
  const { settings } = useSettings();
  const { addToast } = useToast();
  const [editarVisible, setEditarVisible] = useState(false);

  // Cerrar con Enter o Escape
  React.useEffect(() => {
    const handler = (e) => {
      if (e.key === 'Enter' || e.key === 'Escape') { e.preventDefault(); onCerrar(); }
    };
    window.addEventListener('keydown', handler);
    return () => window.removeEventListener('keydown', handler);
  }, [onCerrar]);
  const EMPRESA = {
    nombre:    settings.nombre,
    direccion: settings.direccion,
    colonia:   settings.colonia,
    whatsapp:  settings.whatsapp,
    rfc:       settings.rfc,
    footer:    settings.ticketFooter,
  };
  const [tamano, setTamano] = useState(settings.ticketTamano || '80mm');

  const folio = `#${String(venta.id).padStart(4, '0')}`;
  const fecha = new Date(venta.fecha).toLocaleString('es-MX');
  const total = parseFloat(venta.total);
  const descuento = parseFloat(venta.descuento || 0);
  const montoRecibido = parseFloat(venta.monto_recibido || 0);
  const cambio = montoRecibido > total ? montoRecibido - total : 0;
  const anchoTicket = tamano === '58mm' ? '200px' : '272px';

  const generarTexto = () => {
    // Formato amigable para WhatsApp/Email: líneas cortas, emojis sutiles
    const sep = '━━━━━━━━━━━━━━━';
    const lineas = [
      `🧾 *${EMPRESA.nombre}*`,
      EMPRESA.direccion,
      EMPRESA.colonia,
      `📱 ${EMPRESA.whatsapp}`,
      sep,
      `Folio: *${folio}*`,
      `Fecha: ${fecha}`,
      `Pago: ${venta.metodo_pago || 'efectivo'}`,
      sep,
      ...(venta.productos || []).map(
        p => `• ${p.cantidad}× ${p.producto} — $${(p.precio * p.cantidad).toFixed(2)}`
      ),
      sep,
    ];
    if (descuento > 0) lineas.push(`Descuento: -$${descuento.toFixed(2)}`);
    lineas.push(`*TOTAL: $${total.toFixed(2)}*`);
    if (montoRecibido > 0) {
      lineas.push(`Recibido: $${montoRecibido.toFixed(2)}`);
      lineas.push(`Cambio: $${cambio.toFixed(2)}`);
    }
    lineas.push(sep);
    if (EMPRESA.rfc) lineas.push(`RFC: ${EMPRESA.rfc}`);
    lineas.push(`✨ ${EMPRESA.footer || '¡Gracias por su compra!'}`);
    return lineas.join('\n');
  };

  const [procesandoImg, setProcesandoImg] = useState(false);

  // Captura el ticket como imagen (idéntico al preview)
  const capturarTicket = async () => {
    const el = document.getElementById('ticket-print-area');
    if (!el) throw new Error('Ticket no encontrado');
    const html2canvas = await loadHtml2Canvas();
    const canvas = await html2canvas(el, {
      backgroundColor: '#ffffff',
      scale: 2,           // retina para nitidez
      useCORS: true,
      logging: false,
    });
    return canvas;
  };

  // Imprimir usando imagen rasterizada (pixel-perfect con el preview)
  const handleImprimir = async () => {
    setProcesandoImg(true);
    try {
      const canvas = await capturarTicket();
      const anchoMM = tamano === '58mm' ? '58mm' : '80mm';
      const dataUrl = canvas.toDataURL('image/png');

      const ventana = window.open('', '_blank', 'width=400,height=600');
      if (!ventana) {
        addToast('El navegador bloqueó la ventana. Permite pop-ups para imprimir.', 'aviso');
        return;
      }

      ventana.document.write(`
        <!DOCTYPE html>
        <html>
        <head>
          <title>Ticket ${folio}</title>
          <style>
            @page { margin: 2mm; size: ${anchoMM} auto; }
            html, body { margin: 0; padding: 0; background: #fff; }
            img { display: block; width: 100%; height: auto; }
          </style>
        </head>
        <body>
          <img src="${dataUrl}" alt="Ticket" />
          <script>
            window.onload = function() {
              setTimeout(function() {
                window.print();
                setTimeout(function() { window.close(); }, 300);
              }, 150);
            };
          </script>
        </body>
        </html>
      `);
      ventana.document.close();
      ventana.focus();
    } catch (err) {
      addToast('Error al imprimir: ' + err.message, 'error');
    } finally {
      setProcesandoImg(false);
    }
  };

  // PDF pixel-perfect: rasteriza el preview y lo inserta en el PDF
  const handlePDF = async () => {
    setProcesandoImg(true);
    try {
      const canvas = await capturarTicket();
      const anchoMM = tamano === '58mm' ? 58 : 80;
      const altoMM = (canvas.height / canvas.width) * anchoMM;
      const doc = new jsPDF({ unit: 'mm', format: [anchoMM, altoMM + 4] });
      const imgData = canvas.toDataURL('image/png');
      doc.addImage(imgData, 'PNG', 0, 2, anchoMM, altoMM);
      doc.save(`ticket-${folio}.pdf`);
      addToast('PDF generado', 'exito');
    } catch (err) {
      addToast('Error al generar PDF: ' + err.message, 'error');
    } finally {
      setProcesandoImg(false);
    }
  };

  // Descarga el ticket como imagen PNG (para adjuntar manualmente a WhatsApp/Email)
  const handleImagen = async () => {
    setProcesandoImg(true);
    try {
      const canvas = await capturarTicket();
      const link = document.createElement('a');
      link.download = `ticket-${folio}.png`;
      link.href = canvas.toDataURL('image/png');
      link.click();
      addToast('Imagen descargada. Ya puedes adjuntarla a WhatsApp/Email.', 'exito');
    } catch (err) {
      addToast('Error al generar imagen: ' + err.message, 'error');
    } finally {
      setProcesandoImg(false);
    }
  };

  const handleWhatsApp = () => {
    const texto = generarTexto();
    window.open(`https://wa.me/?text=${encodeURIComponent(texto)}`, '_blank');
    addToast('Tip: usa "🖼 Imagen" para adjuntar el ticket gráfico en WhatsApp', 'aviso');
  };

  const handleEmail = () => {
    const asunto = `Ticket ${folio} - ${EMPRESA.nombre}`;
    const cuerpo = generarTexto().replace(/\*/g, '');
    window.open(`mailto:?subject=${encodeURIComponent(asunto)}&body=${encodeURIComponent(cuerpo)}`);
    addToast('Tip: usa "🖼 Imagen" para adjuntar el ticket gráfico al correo', 'aviso');
  };

  return createPortal(
    <div className="tpm-overlay" onClick={onCerrar}>
      <div className="tpm-box" onClick={e => e.stopPropagation()}>

        <div className="tpm-header">
          <h3>Vista previa del ticket</h3>
          <div className="tpm-tamano">
            <span>Papel:</span>
            <button className={tamano === '58mm' ? 'activo' : ''} onClick={() => setTamano('58mm')}>58 mm</button>
            <button className={tamano === '80mm' ? 'activo' : ''} onClick={() => setTamano('80mm')}>80 mm</button>
          </div>
        </div>

        <div className="tpm-scroll">
          <div id="ticket-print-area" className="tpm-ticket" style={{ width: anchoTicket }}>
            <img src="/Logo.png" className="tpm-logo" alt="Logo" />
            <h2 className="tpm-empresa">{EMPRESA.nombre}</h2>
            <p className="tpm-dir">
              {EMPRESA.direccion}<br />
              {EMPRESA.colonia}<br />
              {EMPRESA.whatsapp}
            </p>
            <div className="tpm-linea" />
            <p className="tpm-folio">Folio: {folio}</p>
            <p className="tpm-fecha">Fecha: {fecha}</p>
            {venta.metodo_pago && (
              <p className="tpm-metodo">
                {venta.metodo_pago === 'efectivo' ? '💵' : venta.metodo_pago === 'tarjeta' ? '💳' : '🏦'}{' '}
                {venta.metodo_pago.charAt(0).toUpperCase() + venta.metodo_pago.slice(1)}
              </p>
            )}
            <div className="tpm-linea" />

            <table className="tpm-tabla">
              <thead>
                <tr>
                  <th>Cant</th>
                  <th>Producto</th>
                  <th>P.Unit</th>
                  <th className="derecha">Subtotal</th>
                </tr>
              </thead>
              <tbody>
                {(venta.productos || []).map((p, i) => (
                  <tr key={i}>
                    <td>{p.cantidad}</td>
                    <td>{p.producto}</td>
                    <td>${parseFloat(p.precio).toFixed(2)}</td>
                    <td className="derecha">${(p.precio * p.cantidad).toFixed(2)}</td>
                  </tr>
                ))}
              </tbody>
            </table>

            <div className="tpm-linea" />
            {descuento > 0 && <p className="tpm-descuento">Descuento: -${descuento.toFixed(2)}</p>}
            <p className="tpm-total">TOTAL: ${total.toFixed(2)}</p>
            {montoRecibido > 0 && (
              <>
                <p className="tpm-pago">Pago: ${montoRecibido.toFixed(2)}</p>
                <p className="tpm-cambio">Cambio: ${cambio.toFixed(2)}</p>
              </>
            )}
            <div className="tpm-linea" />
            {EMPRESA.rfc && <p className="tpm-footer" style={{ fontSize: '0.7rem' }}>RFC: {EMPRESA.rfc}</p>}
            <p className="tpm-footer">{EMPRESA.footer || '¡Gracias por su compra!'}</p>
          </div>
        </div>

        <div className="tpm-acciones">
          <button className="btn btn-primary" onClick={handleImprimir} disabled={procesandoImg}>🖨️ Imprimir</button>
          <button className="btn btn-secondary" onClick={handlePDF} disabled={procesandoImg}>
            {procesandoImg ? '...' : '📄 PDF'}
          </button>
          <button className="tpm-btn-img" onClick={handleImagen} disabled={procesandoImg}>
            {procesandoImg ? '...' : '🖼 Imagen'}
          </button>
          <button className="tpm-btn-wa" onClick={handleWhatsApp}>💬 WhatsApp</button>
          <button className="tpm-btn-email" onClick={handleEmail}>✉️ Email</button>
          {venta.id && (
            <button className="tpm-btn-editar" onClick={() => setEditarVisible(true)}>✏️ Modificar</button>
          )}
          <button className="tpm-btn-cerrar" onClick={onCerrar}>✕ Cerrar</button>
        </div>

        {editarVisible && (
          <EditarVentaModal
            venta={venta}
            onCerrar={() => setEditarVisible(false)}
            onActualizado={() => {
              setEditarVisible(false);
              onVentaModificada?.();
              onCerrar();
            }}
          />
        )}

      </div>
    </div>,
    document.body
  );
};

export default TicketPreviewModal;
