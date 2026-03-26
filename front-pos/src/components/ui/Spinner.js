import React from 'react';
import './Spinner.css';

const Spinner = ({ texto = 'Cargando...' }) => (
  <div className="spinner-wrapper">
    <div className="spinner" />
    {texto && <p className="spinner-texto">{texto}</p>}
  </div>
);

export default Spinner;
