// components/Faltantes.js
import React, { useEffect, useState, useMemo } from 'react';
import jsPDF from 'jspdf';
import autoTable from 'jspdf-autotable';
import axios from 'axios';
import './Faltantes.css';

const Faltantes = () => {
  const [productos, setProductos] = useState([]);
  const [busqueda, setBusqueda] = useState('');
  const [ordenarPor, setOrdenarPor] = useState('stock');
  const [ascendente, setAscendente] = useState(true);

  useEffect(() => {
  axios.get('http://localhost:5000/api/productos/faltantes')
    .then(res => {
      const data = Array.isArray(res.data) ? res.data : (res.data?.data || []);
      setProductos(data);
    })
    .catch(err => {
      console.error('Error al obtener productos faltantes:', err);
      setProductos([]);
    });
  }, []);

  const exportarPDF = () => {
   const doc = new jsPDF();
   doc.text('Productos Faltantes o Escasos', 14, 16);

   autoTable(doc, {
      startY: 20,
      head: [['Nombre', 'Código', 'Descripción', 'Stock', 'Estado']],
      body: productosFiltrados.map(p => [
         p.nombre,
         p.codigo || '-',
         p.descripcion || '-',
         p.stock,
         p.stock === 0 ? 'Sin existencia' : (p.stock <= 5 ? 'Muy bajo' : 'Por terminarse')
      ]),
      theme: 'striped',
      styles: {
         fontSize: 10
      }
   });

   doc.save('faltantes.pdf');
   };

   const eliminarProducto = async (id) => {
      const confirmar = window.confirm('¿Estás seguro de eliminar este producto?');
      if (!confirmar) return;

      try {
        await axios.delete(`/api/productos/${id}`);
        setProductos(prev => prev.filter(p => p.id !== id));
      } catch (error) {
        console.error('Error al eliminar producto:', error);
        alert('No se pudo eliminar el producto.');
      }
    };


  const productosFiltrados = useMemo(() => {
    const filtrados = productos.filter(prod =>
      prod.nombre.toLowerCase().includes(busqueda.toLowerCase()) ||
      (prod.codigo && prod.codigo.toLowerCase().includes(busqueda.toLowerCase()))
    );

    return filtrados.sort((a, b) => {
      const valorA = a[ordenarPor];
      const valorB = b[ordenarPor];

      if (typeof valorA === 'string') {
        return ascendente ? valorA.localeCompare(valorB) : valorB.localeCompare(valorA);
      }
      return ascendente ? valorA - valorB : valorB - valorA;
    });
  }, [productos, busqueda, ordenarPor, ascendente]);

  const cambiarOrden = (campo) => {
    if (ordenarPor === campo) {
      setAscendente(!ascendente);
    } else {
      setOrdenarPor(campo);
      setAscendente(true);
    }
  };

  return (
    <div className="faltantes-container">
      <h2>📦 Productos Faltantes o Escasos</h2>

      <div className="buscador-orden">
        <input
          type="text"
          placeholder="Buscar por nombre o código"
          value={busqueda}
          onChange={e => setBusqueda(e.target.value)}
          className="input"
        />
        <button className="btn btn-secondary" onClick={() => cambiarOrden('stock')}>
          Ordenar por Stock {ordenarPor === 'stock' ? (ascendente ? '↑' : '↓') : ''}
        </button>
        <button className="btn btn-secondary" onClick={() => cambiarOrden('nombre')}>
          Ordenar por Nombre {ordenarPor === 'nombre' ? (ascendente ? '↑' : '↓') : ''}
        </button>
        <button className="btn btn-primary" onClick={exportarPDF}>
         📄 Exportar PDF
         </button>
      </div>

      <div className="tabla-responsive">
        <table className="tabla">
          <thead>
            <tr>
              <th>Nombre</th>
              <th>Código</th>
              <th>Descripción</th>
              <th>Stock</th>
              <th>Estado</th>
            </tr>
          </thead>
          <tbody>
            {productosFiltrados.length > 0 ? (
              productosFiltrados.map(producto => (
                <tr key={producto.id}>
                  <td>{producto.codigo || '-'}</td>
                  <td>{producto.nombre}</td>
                  <td>{producto.descripcion || '-'}</td>
                  <td>{producto.stock}</td>
                  <td>
                    {producto.stock === 0 ? (
                      <>
                        <span className="status status-rojo">Sin existencia</span>
                        <button
                          className="btn btn-danger btn-mini"
                          style={{ marginLeft: '10px' }}
                          onClick={() => eliminarProducto(producto.id)}
                        >
                          🗑️
                        </button>
                      </>
                    ) : producto.stock <= 5 ? (
                      <span className="status status-naranja">Muy bajo</span>
                    ) : (
                      <span className="status status-naranja">Por terminarse</span>
                    )}
                  </td>
                </tr>
              ))
            ) : (
              <tr>
                <td colSpan="5" style={{ textAlign: 'center' }}>No hay productos faltantes 🎉</td>
              </tr>
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
};

export default Faltantes;
