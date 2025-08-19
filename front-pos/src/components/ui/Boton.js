import React from 'react';

const Boton = ({
  tipo = 'primario',       // 'primario', 'peligro', 'exito', etc.
  icono = null,            // <FaPlus />, <FaTrash />, etc.
  onClick = () => {},      // función al hacer clic
  children,                // texto del botón
  className = '',          // clases adicionales opcionales
  ...props                 // otros props (type="submit", disabled, etc.)
}) => {
  const clasesBase = 'btn btn-icon';
  const claseTipo = {
    primario: 'btn-primary',
    peligro: 'btn-danger',
    exito: 'btn-success',
    secundario: 'btn-secondary'
  }[tipo] || 'btn-primary';

  return (
    <button onClick={onClick} className={`${clasesBase} ${claseTipo} ${className}`} {...props}>
      {icono && <span style={{ marginRight: '6px' }}>{icono}</span>}
      {children}
    </button>
  );
};

export default Boton;
