import React, { useState } from 'react';
import Faltantes from '../components/faltantes/Faltantes';
import AgregarEgresoForm from '../components/faltantes/Egresos';

const FaltantesPage = () => {
  const [mostrarEgresos, setMostrarEgresos] = useState(false);

  return (
    <div className="pagina-faltantes">
      <Faltantes />

      <div style={{ padding: '0 2rem 1.5rem' }}>
        <button
          onClick={() => setMostrarEgresos(v => !v)}
          style={{
            padding: '8px 16px',
            border: '1.5px solid var(--fondo-borde)',
            borderRadius: '8px',
            background: 'var(--fondo-tarjeta)',
            color: 'var(--texto-principal)',
            fontWeight: 600,
            fontSize: '0.85rem',
            cursor: 'pointer',
            marginBottom: mostrarEgresos ? '0.75rem' : 0,
          }}
        >
          {mostrarEgresos ? '▲ Ocultar egresos' : '▼ Registrar egreso'}
        </button>
        {mostrarEgresos && <AgregarEgresoForm />}
      </div>
    </div>
  );
};

export default FaltantesPage;
