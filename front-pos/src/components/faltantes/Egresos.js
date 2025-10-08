// components/AgregarEgresoForm.js
import React, { useState } from 'react';
import api from '../../services/api';

const AgregarEgresoForm = () => {
  // Estado para manejar el monto del egreso
  const [monto, setMonto] = useState('');

  // Función que maneja el envío del formulario
  const handleSubmit = async (e) => {
    e.preventDefault(); // Evita el comportamiento por defecto del formulario

    // Validación para asegurar que el monto sea un número mayor a 0
    if (!monto || isNaN(monto) || parseFloat(monto) <= 0) {
      return alert('Ingresa un monto válido mayor a cero');
    }

    try {
      // Enviar la información del egreso al backend usando POST
      await api.post('/productos/egresos', { monto });

      // Alerta de éxito y reiniciar campos
      alert('Egreso registrado correctamente');
      setMonto('');
    } catch (err) {
      // En caso de error, mostrar mensaje en consola y alerta al usuario
      console.error('Error al registrar egreso:', err);
      alert('Error al registrar egreso');
    }
  };

  return (
    <div className="form-section">
      <h2>Registrar Egreso</h2>
      {/* Formulario controlado para registrar un nuevo egreso */}
      <form onSubmit={handleSubmit} className="formulario-producto">
        {/* Campo para ingresar el monto */}
        <input
          type="number"
          placeholder="Monto del egreso"
          className="input"
          value={monto}
          onChange={e => setMonto(e.target.value)}
        />

        {/* Botón de envío del formulario */}
        <button type="submit" className="btn btn-danger">➖ Registrar Egreso</button>
      </form>
    </div>
  );
};

export default AgregarEgresoForm;
