import React, { useState, useEffect } from 'react';
import api from '../../services/api';
import './ResumenCaja.css';

const ResumenCaja = ({ refreshKey = 0, productosCache = null }) => {
  const [datos, setDatos] = useState(null);

  useEffect(() => {
    let cancelado = false;
    const cargar = async () => {
      if (document.visibilityState === 'hidden') return;
      try {
        // Usa productos del padre si estan disponibles para evitar fetch duplicado
        const ventasRes = await api.get('/ventas/hoy');
        if (cancelado) return;
        const productosDB = productosCache && productosCache.length > 0
          ? productosCache
          : (await api.get('/productos')).data || [];
        if (cancelado) return;
        const ventas = ventasRes.data || [];

        // Mapa de precio_costo por id (más confiable que por nombre)
        const costoMap = {};
        productosDB.forEach(p => {
          costoMap[p.id] = Number(p.precio_costo) || 0;
        });
        // Fallback: también guardar por nombre normalizado por si la venta no trae id
        const costoMapNombre = {};
        productosDB.forEach(p => {
          if (p.nombre) costoMapNombre[p.nombre.toLowerCase().trim()] = Number(p.precio_costo) || 0;
        });

        const totalVentas = ventas.length;
        const totalMonto = ventas.reduce((acc, v) => acc + Number(v.total), 0);
        const promedio = totalVentas > 0 ? totalMonto / totalVentas : 0;

        const efectivo = ventas.filter(v => v.metodo_pago === 'efectivo').reduce((a, v) => a + Number(v.total), 0);
        const tarjeta = ventas.filter(v => v.metodo_pago === 'tarjeta').reduce((a, v) => a + Number(v.total), 0);
        const transferencia = ventas.filter(v => v.metodo_pago === 'transferencia').reduce((a, v) => a + Number(v.total), 0);

        // Artículos vendidos (total unidades)
        let articulos = 0;
        let costoTotal = 0;
        ventas.forEach(v => {
          if (Array.isArray(v.productos)) {
            v.productos.forEach(p => {
              const qty = Number(p.cantidad) || 0;
              articulos += qty;
              // Match por id si existe, sino por nombre normalizado
              const costo = (p.id != null && costoMap[p.id] != null)
                ? costoMap[p.id]
                : (costoMapNombre[(p.producto || '').toLowerCase().trim()] || 0);
              costoTotal += costo * qty;
            });
          }
        });

        const ganancia = totalMonto - costoTotal;

        // Última venta (ordenar por fecha para garantizar)
        let ultimaVenta = null;
        if (ventas.length > 0) {
          const ultimaFecha = ventas.reduce((max, v) => {
            const t = new Date(v.fecha).getTime();
            return t > max ? t : max;
          }, 0);
          if (ultimaFecha > 0) {
            ultimaVenta = new Date(ultimaFecha).toLocaleTimeString('es-MX', { hour: '2-digit', minute: '2-digit' });
          }
        }

        setDatos({ totalVentas, totalMonto, promedio, efectivo, tarjeta, transferencia, articulos, ganancia, ultimaVenta });
      } catch (err) {
        if (!cancelado) console.warn('[ResumenCaja] Error cargando datos:', err?.message);
      }
    };
    cargar();
    const interval = setInterval(cargar, 60000);
    const onVisibility = () => { if (document.visibilityState === 'visible') cargar(); };
    document.addEventListener('visibilitychange', onVisibility);
    return () => {
      cancelado = true;
      clearInterval(interval);
      document.removeEventListener('visibilitychange', onVisibility);
    };
  // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [refreshKey]);

  if (!datos) return null;

  return (
    <div className="resumen-caja">
      <div className="rc-item">
        <span className="rc-valor">{datos.totalVentas}</span>
        <span className="rc-label">Ventas hoy</span>
      </div>
      <div className="rc-item rc-item--principal">
        <span className="rc-valor">${datos.totalMonto.toFixed(2)}</span>
        <span className="rc-label">Total del día</span>
      </div>
      <div className="rc-item rc-hide-mobile">
        <span className="rc-valor">${datos.promedio.toFixed(2)}</span>
        <span className="rc-label">Promedio</span>
      </div>
      <div className="rc-item rc-hide-mobile">
        <span className="rc-valor">{datos.articulos}</span>
        <span className="rc-label">Artículos vendidos</span>
      </div>
      <div className={`rc-item ${datos.ganancia >= 0 ? 'rc-item--ganancia' : 'rc-item--perdida'}`}>
        <span className="rc-valor">${datos.ganancia.toFixed(2)}</span>
        <span className="rc-label">Ganancia estimada</span>
      </div>
    </div>
  );
};

export default ResumenCaja;
