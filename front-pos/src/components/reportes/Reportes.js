// src/components/Reportes.js
import React, { useEffect, useState } from 'react';
import axios from 'axios';

const Reportes = () => {
  const [ventas, setVentas] = useState([]);

  useEffect(() => {
    const fetchVentas = async () => {
      try {
        const res = await axios.get('http://localhost:3001/api/ventas');
        setVentas(res.data);
      } catch (error) {
        console.error('Error al cargar las ventas:', error);
      }
    };

    fetchVentas();
  }, []);

  return (
    <div>
      <h2>Historial de Ventas</h2>
      {ventas.length === 0 ? (
        <p>No hay ventas registradas.</p>
      ) : (
        <table>
          <thead>
            <tr>
              <th>Fecha</th>
              <th>Productos</th>
              <th>Total</th>
            </tr>
          </thead>
          <tbody>
            {ventas.map((venta) => (
              <tr key={venta.id}>
                <td>{new Date(venta.fecha).toLocaleString()}</td>
                <td>
                  <ul>
                    {venta.productos.map((p, i) => (
                      <li key={i}>{p.nombre} (x{p.cantidad})</li>
                    ))}
                  </ul>
                </td>
                <td>${venta.total.toFixed(2)}</td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
    </div>
  );
};

export default Reportes;
