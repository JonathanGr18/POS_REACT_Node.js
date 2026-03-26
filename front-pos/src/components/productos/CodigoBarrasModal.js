import React, { useEffect, useRef } from 'react';
import JsBarcode from 'jsbarcode';
import { QRCodeSVG } from 'qrcode.react';
import './CodigoBarrasModal.css';

const CodigoBarrasModal = ({ producto, onCerrar }) => {
  const barcodeSvgRef = useRef(null);

  useEffect(() => {
    if (barcodeSvgRef.current && producto?.codigo) {
      try {
        JsBarcode(barcodeSvgRef.current, producto.codigo.toString(), {
          format: 'CODE128',
          width: 2,
          height: 60,
          displayValue: true,
          fontSize: 14,
          margin: 10,
        });
      } catch (e) {
        console.error('Error generando barcode:', e);
      }
    }
  }, [producto]);

  const handleImprimir = () => {
    const svgEl = barcodeSvgRef.current;
    const svgString = svgEl ? new XMLSerializer().serializeToString(svgEl) : '';
    const ventana = window.open('', '_blank');
    if (!ventana) return;

    ventana.document.write(`
      <html>
        <head>
          <title>Etiqueta - ${producto.nombre}</title>
          <style>
            body { font-family: 'Courier New', monospace; text-align: center; padding: 20px; width: 280px; margin: auto; }
            h3 { font-size: 14px; margin: 0 0 8px; }
            .precio { font-size: 18px; font-weight: bold; margin: 8px 0; }
            .codigo { font-size: 11px; color: #555; margin-bottom: 6px; }
            svg { max-width: 100%; }
          </style>
        </head>
        <body>
          <h3>${producto.nombre}</h3>
          <p class="codigo">Código: ${producto.codigo}</p>
          ${svgString}
          <p class="precio">$${Number(producto.precio).toFixed(2)}</p>
          <script>window.onload = () => { window.print(); window.close(); }</script>
        </body>
      </html>
    `);
    ventana.document.close();
  };

  return (
    <div className="barcode-overlay" onClick={onCerrar}>
      <div className="barcode-box" onClick={e => e.stopPropagation()}>
        <div className="barcode-header">
          <h3>{producto.nombre}</h3>
          <button className="barcode-close" onClick={onCerrar}>✕</button>
        </div>

        <div className="barcode-content">
          <div className="barcode-section">
            <h4>Código de Barras</h4>
            <svg ref={barcodeSvgRef} />
          </div>

          <div className="qr-section">
            <h4>Código QR</h4>
            <QRCodeSVG
              value={`${producto.codigo} - ${producto.nombre} - $${Number(producto.precio).toFixed(2)}`}
              size={120}
              level="M"
            />
          </div>

          <div className="barcode-info">
            <span>Código: <strong>{producto.codigo}</strong></span>
            <span>Precio: <strong>${Number(producto.precio).toFixed(2)}</strong></span>
            <span>Stock: <strong>{producto.stock}</strong></span>
          </div>
        </div>

        <div className="barcode-actions">
          <button className="btn btn-primary" onClick={handleImprimir}>
            🖨️ Imprimir Etiqueta
          </button>
          <button className="btn btn-secondary" onClick={onCerrar}>
            Cerrar
          </button>
        </div>
      </div>
    </div>
  );
};

export default CodigoBarrasModal;
