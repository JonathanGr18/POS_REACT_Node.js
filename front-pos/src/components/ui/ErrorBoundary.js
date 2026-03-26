import React from 'react';

class ErrorBoundary extends React.Component {
  constructor(props) {
    super(props);
    this.state = { hasError: false, error: null };
  }

  static getDerivedStateFromError(error) {
    return { hasError: true, error };
  }

  componentDidCatch(error, info) {
    console.error('[ErrorBoundary]', error, info);
  }

  render() {
    if (this.state.hasError) {
      return (
        <div style={{
          padding: '2rem',
          textAlign: 'center',
          background: 'var(--fondo-tarjeta)',
          borderRadius: '12px',
          margin: '2rem',
          border: '1px solid var(--boton-peligro)'
        }}>
          <h2 style={{ color: 'var(--boton-peligro)' }}>⚠️ Algo salió mal</h2>
          <p style={{ color: 'var(--texto-secundario)', margin: '1rem 0' }}>
            Ocurrió un error inesperado en esta sección.
          </p>
          <button
            className="btn btn-primary"
            onClick={() => this.setState({ hasError: false, error: null })}
          >
            🔄 Reintentar
          </button>
        </div>
      );
    }
    return this.props.children;
  }
}

export default ErrorBoundary;
