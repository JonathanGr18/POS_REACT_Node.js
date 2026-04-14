import React, { useEffect, useRef } from 'react';
import './ConfirmModal.css';

const ConfirmModal = ({
  visible,
  mensaje,
  onConfirm,
  onCancel,
  textoConfirmar = 'Confirmar',
  tipoBtnConfirmar = 'btn-danger',
}) => {
  const confirmBtnRef = useRef(null);
  const cancelBtnRef = useRef(null);
  const previouslyFocusedRef = useRef(null);

  useEffect(() => {
    if (!visible) return;
    previouslyFocusedRef.current = document.activeElement;
    setTimeout(() => confirmBtnRef.current?.focus(), 0);

    const prevOverflow = document.body.style.overflow;
    document.body.style.overflow = 'hidden';

    const handler = (e) => {
      if (e.key === 'Escape') { e.preventDefault(); onCancel(); return; }
      // Focus trap con Tab
      if (e.key === 'Tab') {
        const focused = document.activeElement;
        if (e.shiftKey) {
          if (focused === confirmBtnRef.current) {
            e.preventDefault();
            cancelBtnRef.current?.focus();
          }
        } else {
          if (focused === cancelBtnRef.current) {
            e.preventDefault();
            confirmBtnRef.current?.focus();
          }
        }
      }
      // Enter solo dispara si el confirm button tiene foco
      if (e.key === 'Enter' && document.activeElement === confirmBtnRef.current) {
        e.preventDefault();
        onConfirm();
      }
    };
    window.addEventListener('keydown', handler);
    return () => {
      window.removeEventListener('keydown', handler);
      document.body.style.overflow = prevOverflow;
      previouslyFocusedRef.current?.focus?.();
    };
  }, [visible, onConfirm, onCancel]);

  if (!visible) return null;

  return (
    <div className="modal-overlay" onClick={onCancel} aria-hidden="true">
      <div
        className="modal-box"
        onClick={e => e.stopPropagation()}
        role="dialog"
        aria-modal="true"
        aria-labelledby="confirm-modal-msg"
      >
        <p id="confirm-modal-msg" className="modal-mensaje">{mensaje}</p>
        <div className="modal-acciones">
          <button
            ref={confirmBtnRef}
            className={`btn ${tipoBtnConfirmar}`}
            onClick={onConfirm}
          >
            {textoConfirmar}
          </button>
          <button
            ref={cancelBtnRef}
            className="btn btn-secondary"
            onClick={onCancel}
          >
            Cancelar
          </button>
        </div>
      </div>
    </div>
  );
};

export default ConfirmModal;
