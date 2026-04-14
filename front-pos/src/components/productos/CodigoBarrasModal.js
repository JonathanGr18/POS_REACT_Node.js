import React, { useEffect, useRef } from 'react';
import JsBarcode from 'jsbarcode';
import { QRCodeSVG } from 'qrcode.react';
import './CodigoBarrasModal.css';

const CodigoBarrasModal = ({ producto, onCerrar }) => {
  const barcodeSvgRef = useRef(null);
  const closeBtnRef = useRef(null);
  const previouslyFocusedRef = useRef(null);

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
  }, [producto?.codigo]);

  // ESC para cerrar + bloqueo de scroll + restore focus
  useEffect(() => {
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
  }, [onCerrar]);

  const handleImprimir = () => {
    const svgEl = barcodeSvgRef.current;
    const svgString = svgEl ? new XMLSerializer().serializeToString(svgEl) : '';
    const ventana = window.open('', '_blank');
    if (!ventana) return;

    // Construir DOM seguro usando textContent (anti-XSS)
    const doc = ventana.document;
    doc.open();
    doc.write('<!DOCTYPE html><html><head></head><body></body></html>');
    doc.close();

    const head = doc.head;
    const titleEl = doc.createElement('title');
    titleEl.textContent = `Etiqueta - ${producto.nombre}`;
    head.appendChild(titleEl);

    const styleEl = doc.createElement('style');
    styleEl.textContent = `
      body { font-family: 'Courier New', monospace; text-align: center; padding: 20px; width: 280px; margin: auto; }
      h3 { font-size: 14px; margin: 0 0 8px; }
      .precio { font-size: 18px; font-weight: bold; margin: 8px 0; }
      .codigo { font-size: 11px; color: #555; margin-bottom: 6px; }
      svg { max-width: 100%; }
    `;
    head.appendChild(styleEl);

    const body = doc.body;
    const h3 = doc.createElement('h3');
    h3.textContent = producto.nombre;
    body.appendChild(h3);

    const codigoP = doc.createElement('p');
    codigoP.className = 'codigo';
    codigoP.textContent = `Código: ${producto.codigo}`;
    body.appendChild(codigoP);

    // SVG: parsear como SVG real (no html injection)
    const svgWrapper = doc.createElement('div');
    const parser = new ventana.DOMParser();
    const svgDoc = parser.parseFromString(svgString, 'image/svg+xml');
    if (svgDoc.documentElement) {
      svgWrapper.appendChild(doc.importNode(svgDoc.documentElement, true));
    }
    body.appendChild(svgWrapper);

    const precioP = doc.createElement('p');
    precioP.className = 'precio';
    precioP.textContent = `$${Number(producto.precio).toFixed(2)}`;
    body.appendChild(precioP);

    ventana.onload = () => { ventana.print(); ventana.close(); };
    // Si ya está cargada
    setTimeout(() => { try { ventana.print(); ventana.close(); } catch {} }, 100);
  };

  return (
    <div className="barcode-overlay" onClick={onCerrar} aria-hidden="true">
      <div
        className="barcode-box"
        onClick={e => e.stopPropagation()}
        role="dialog"
        aria-modal="true"
        aria-labelledby="barcode-title"
      >
        <div className="barcode-header">
          <h3 id="barcode-title">{producto.nombre}</h3>
          <button
            ref={closeBtnRef}
            className="barcode-close"
            onClick={onCerrar}
            aria-label="Cerrar"
          >✕</button>
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
