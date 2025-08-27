import React from 'react';

const InputBusqueda = ({ value, onChange, sugerencias = [], onSeleccionar, placeholder = 'Buscar...' }) => {
  return (
    <div className="input-busqueda-container">
      <input
        type="text"
        className="input"
        placeholder={placeholder}
        value={value}
        onChange={onChange}
      />

      {value && sugerencias.length > 0 && (
        <ul className="sugerencias">
          {sugerencias.slice(0, 5).map((item) => (
            <li key={item.id} onClick={() => onSeleccionar(item)}>
              {item.codigo} - {item.nombre}
            </li>
          ))}
        </ul>
      )}
    </div>
  );
};

export default InputBusqueda;
