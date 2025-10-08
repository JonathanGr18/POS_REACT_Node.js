import React from 'react';
import './Tabla.css';

const Tabla = ({ columnas = [], datos = [], renderFila }) => {
  return (
    <div className="tabla-responsive">
      <table className="tabla">
        <thead>
          <tr>
            {columnas.map((col, idx) => (
              <th key={idx}>{col}</th>
            ))}
          </tr>
        </thead>
        <tbody>
          {datos.length === 0 ? (
            <tr>
              <td colSpan={columnas.length} className="no-data">
                No hay datos disponibles.
              </td>
            </tr>
          ) : (
            datos.map(renderFila)
          )}
        </tbody>
      </table>
    </div>
  );
};

export default Tabla;
