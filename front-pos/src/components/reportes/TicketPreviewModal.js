import React, { useState } from 'react';
import jsPDF from 'jspdf';
import autoTable from 'jspdf-autotable';
import { useSettings } from '../../context/SettingsContext';
import './TicketPreviewModal.css';

const TicketPreviewModal = ({ venta, onCerrar }) => {
  const { settings } = useSettings();

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
    const lineas = [
      `*${EMPRESA.nombre}*`,
      EMPRESA.direccion,
      EMPRESA.colonia,
      EMPRESA.whatsapp,
      '--------------------------------',
      `Folio: ${folio}`,
      `Fecha: ${fecha}`,
      `Pago: ${venta.metodo_pago || 'efectivo'}`,
      '--------------------------------',
      ...(venta.productos || []).map(
        p => `${p.cantidad}x ${p.producto}  $${(p.precio * p.cantidad).toFixed(2)}`
      ),
      '--------------------------------',
    ];
    if (descuento > 0) lineas.push(`Descuento: -$${descuento.toFixed(2)}`);
    lineas.push(`TOTAL: $${total.toFixed(2)}`);
    if (montoRecibido > 0) {
      lineas.push(`Pago: $${montoRecibido.toFixed(2)}`);
      lineas.push(`Cambio: $${cambio.toFixed(2)}`);
    }
    lineas.push('--------------------------------');
    if (EMPRESA.rfc) lineas.push(`RFC: ${EMPRESA.rfc}`);
    lineas.push(EMPRESA.footer || '¡Gracias por su compra!');
    return lineas.join('\n');
  };

  const handleImprimir = () => {
    window.print();
  };

  const handlePDF = () => {
    const anchoMM = tamano === '58mm' ? 58 : 80;
    const doc = new jsPDF({ unit: 'mm', format: [anchoMM, 200] });
    const margen = 4;
    let y = 8;

    doc.setFontSize(11);
    doc.setFont('helvetica', 'bold');
    doc.text(EMPRESA.nombre, anchoMM / 2, y, { align: 'center' });
    y += 5;
    doc.setFontSize(7);
    doc.setFont('helvetica', 'normal');
    doc.text(EMPRESA.direccion, anchoMM / 2, y, { align: 'center' }); y += 4;
    doc.text(EMPRESA.colonia, anchoMM / 2, y, { align: 'center' }); y += 4;
    doc.text(EMPRESA.whatsapp, anchoMM / 2, y, { align: 'center' }); y += 5;

    doc.setFontSize(8);
    doc.text(`Folio: ${folio}`, margen, y); y += 4;
    doc.text(`Fecha: ${fecha}`, margen, y); y += 5;

    autoTable(doc, {
      startY: y,
      margin: { left: margen, right: margen },
      head: [['Cant', 'Producto', 'P.Unit', 'Subtotal']],
      body: (venta.productos || []).map(p => [
        p.cantidad,
        p.producto,
        `$${parseFloat(p.precio).toFixed(2)}`,
        `$${(p.precio * p.cantidad).toFixed(2)}`,
      ]),
      styles: { fontSize: 7, cellPadding: 1 },
      headStyles: { fillColor: [50, 50, 50], fontSize: 7 },
      columnStyles: { 3: { halign: 'right' } },
    });

    y = doc.lastAutoTable.finalY + 4;
    doc.setFontSize(8);
    if (descuento > 0) {
      doc.text(`Descuento: -$${descuento.toFixed(2)}`, anchoMM - margen, y, { align: 'right' }); y += 4;
    }
    doc.setFont('helvetica', 'bold');
    doc.setFontSize(10);
    doc.text(`TOTAL: $${total.toFixed(2)}`, anchoMM - margen, y, { align: 'right' }); y += 5;
    doc.setFont('helvetica', 'normal');
    doc.setFontSize(8);
    if (venta.metodo_pago) {
      doc.text(`Método: ${venta.metodo_pago}`, margen, y); y += 4;
    }
    if (montoRecibido > 0) {
      doc.text(`Pago: $${montoRecibido.toFixed(2)}`, anchoMM - margen, y, { align: 'right' }); y += 4;
      doc.text(`Cambio: $${cambio.toFixed(2)}`, anchoMM - margen, y, { align: 'right' }); y += 5;
    }
    doc.setFontSize(7);
    if (EMPRESA.rfc) {
      doc.text(`RFC: ${EMPRESA.rfc}`, anchoMM / 2, y + 2, { align: 'center' }); y += 4;
    }
    doc.text(EMPRESA.footer || '¡Gracias por su compra!', anchoMM / 2, y + 2, { align: 'center' });

    doc.save(`ticket-${folio}.pdf`);
  };

  const handleWhatsApp = () => {
    const texto = generarTexto();
    window.open(`https://wa.me/?text=${encodeURIComponent(texto)}`, '_blank');
  };

  const handleEmail = () => {
    const asunto = `Ticket ${folio} - ${EMPRESA.nombre}`;
    const cuerpo = generarTexto().replace(/\*/g, '');
    window.open(`mailto:?subject=${encodeURIComponent(asunto)}&body=${encodeURIComponent(cuerpo)}`);
  };

  return (
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
          <button className="btn btn-primary" onClick={handleImprimir}>🖨️ Imprimir</button>
          <button className="btn btn-secondary" onClick={handlePDF}>📄 PDF</button>
          <button className="tpm-btn-wa" onClick={handleWhatsApp}>💬 WhatsApp</button>
          <button className="tpm-btn-email" onClick={handleEmail}>✉️ Email</button>
          <button className="btn" onClick={onCerrar}>Cerrar</button>
        </div>

      </div>
    </div>
  );
};

export default TicketPreviewModal;
