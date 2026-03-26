import React, { useEffect } from 'react';
import './ConfirmModal.css';

const ConfirmModal = ({
  visible,
  mensaje,
  onConfirm,
  onCancel,
  textoConfirmar = 'Confirmar',
  tipoBtnConfirmar = 'btn-danger',
}) => {
  useEffect(() => {
    if (!visible) return;
    const handler = (e) => {
      if (e.key === 'Enter') { e.preventDefault(); onConfirm(); }
      if (e.key === 'Escape') { e.preventDefault(); onCancel(); }
    };
    window.addEventListener('keydown', handler);
    return () => window.removeEventListener('keydown', handler);
  }, [visible, onConfirm, onCancel]);

  if (!visible) return null;

  return (
    <div className="modal-overlay" onClick={onCancel}>
      <div className="modal-box" onClick={e => e.stopPropagation()}>
        <p className="modal-mensaje">{mensaje}</p>
        <div className="modal-acciones">
          <button className={`btn ${tipoBtnConfirmar}`} onClick={onConfirm}>
            {textoConfirmar}
          </button>
          <button className="btn btn-secondary" onClick={onCancel}>
            Cancelar
          </button>
        </div>
      </div>
    </div>
  );
};

export default ConfirmModal;
