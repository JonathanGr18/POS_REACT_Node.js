import React, { useState } from 'react';
import { FaRobot, FaTimes } from 'react-icons/fa';
import './AsistenteIA.css';

const AsistenteIA = () => {
  const [abierto, setAbierto] = useState(false);

  return (
    <>
      {/* Botón flotante */}
      <button
        className="ia-fab"
        onClick={() => setAbierto(v => !v)}
        title="Asistente IA — Próximamente"
      >
        <FaRobot size={22} />
      </button>

      {/* Panel Próximamente */}
      {abierto && (
        <div className="ia-prox">
          <button className="ia-prox__cerrar" onClick={() => setAbierto(false)}>
            <FaTimes size={14} />
          </button>
          <div className="ia-prox__icono">
            <FaRobot size={32} />
          </div>
          <h3 className="ia-prox__titulo">Asistente IA</h3>
          <p className="ia-prox__badge">🚀 Próximamente</p>
          <p className="ia-prox__desc">
            Tu consultor inteligente de papelería estará disponible muy pronto.
          </p>
        </div>
      )}
    </>
  );
};

export default AsistenteIA;
