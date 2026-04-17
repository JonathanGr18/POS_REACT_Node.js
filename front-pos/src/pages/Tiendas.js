import React from 'react';

const Tiendas = () => {
  return (
    <div style={{
      display: 'flex',
      flexDirection: 'column',
      alignItems: 'center',
      justifyContent: 'center',
      minHeight: '100vh',
      background: 'var(--fondo-principal)',
      padding: '2rem',
      textAlign: 'center',
    }}>
      <span style={{ fontSize: '4rem', marginBottom: '1rem' }}>🏗️</span>
      <h2 style={{ color: 'var(--texto-principal)', margin: '0 0 0.5rem' }}>Próximamente</h2>
      <p style={{ color: 'var(--texto-secundario)', fontSize: '1rem', maxWidth: '400px' }}>
        La sección de Tiendas y Proveedores estará disponible en una próxima actualización.
      </p>
    </div>
  );
};

export default Tiendas;
