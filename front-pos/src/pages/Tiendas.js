import React, { useEffect, useState } from 'react';
import api from '../services/api';
import { useToast } from '../components/ui/Toast';
import Spinner from '../components/ui/Spinner';
import ConfirmModal from '../components/ui/ConfirmModal';
import TiendaForm from '../components/tiendas/TiendaForm';
import TiendaDetalle from '../components/tiendas/TiendaDetalle';
import './Tiendas.css';

const Tiendas = () => {
  const { addToast } = useToast();

  const [tiendas, setTiendas] = useState([]);
  const [cargando, setCargando] = useState(false);
  const [tiendaSeleccionada, setTiendaSeleccionada] = useState(null);
  const [modalForm, setModalForm] = useState({ visible: false, tienda: null });
  const [modalEliminar, setModalEliminar] = useState({ visible: false, id: null });

  useEffect(() => {
    cargarTiendas();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const cargarTiendas = async () => {
    setCargando(true);
    try {
      const res = await api.get('/tiendas');
      setTiendas(res.data);
      // Sincronizar tiendaSeleccionada con los datos frescos para evitar estado obsoleto
      if (tiendaSeleccionada) {
        const actualizada = res.data.find((t) => t.id === tiendaSeleccionada.id);
        setTiendaSeleccionada(actualizada || null);
      }
    } catch (err) {
      addToast('Error al cargar las tiendas', 'error');
    } finally {
      setCargando(false);
    }
  };

  const guardarTienda = async (datos) => {
    try {
      if (datos.id) {
        await api.put(`/tiendas/${datos.id}`, datos);
        addToast('Tienda actualizada correctamente', 'exito');
      } else {
        await api.post('/tiendas', datos);
        addToast('Tienda creada correctamente', 'exito');
      }
      await cargarTiendas();
      setModalForm({ visible: false, tienda: null });
    } catch (err) {
      addToast('Error al guardar la tienda', 'error');
    }
  };

  const eliminarTienda = async () => {
    const { id } = modalEliminar;
    try {
      await api.delete(`/tiendas/${id}`);
      addToast('Tienda eliminada', 'exito');
      if (tiendaSeleccionada?.id === id) {
        setTiendaSeleccionada(null);
      }
      await cargarTiendas();
    } catch (err) {
      addToast('Error al eliminar la tienda', 'error');
    } finally {
      setModalEliminar({ visible: false, id: null });
    }
  };

  const handleAgregarALista = async ({ tienda_id, nombre_producto, precio_ref }) => {
    try {
      await api.post('/lista-compras', {
        tienda_id,
        nombre_producto,
        cantidad: 1,
        precio_ref,
      });
      addToast(`"${nombre_producto}" agregado a la lista de compras`, 'exito');
    } catch (err) {
      addToast('Error al agregar a la lista', 'error');
    }
  };

  return (
    <div className="tiendas-page">
      {/* Sidebar con lista de tiendas */}
      <div className="tiendas-sidebar">
        <div className="tiendas-header">
          <h2>🏪 Tiendas</h2>
          <button
            className="btn btn-primary"
            onClick={() => setModalForm({ visible: true, tienda: null })}
          >
            + Nueva Tienda
          </button>
        </div>

        {cargando ? (
          <Spinner />
        ) : (
          <div className="tiendas-lista">
            {tiendas.length === 0 && (
              <p className="no-data">No hay tiendas registradas</p>
            )}
            {tiendas.map((t) => (
              <div
                key={t.id}
                className={`tienda-card ${tiendaSeleccionada?.id === t.id ? 'activa' : ''}`}
                onClick={() => setTiendaSeleccionada(t)}
              >
                <div className="tienda-card-info">
                  <h3>{t.nombre}</h3>
                  {t.direccion && (
                    <p className="tienda-direccion">📍 {t.direccion}</p>
                  )}
                  {t.telefono && (
                    <p className="tienda-tel">📞 {t.telefono}</p>
                  )}
                  <span className="tienda-badge">{t.total_productos ?? 0} productos</span>
                </div>
                <div className="tienda-card-actions">
                  <button
                    className="btn-icon btn-edit"
                    title="Editar tienda"
                    onClick={(e) => {
                      e.stopPropagation();
                      setModalForm({ visible: true, tienda: t });
                    }}
                  >
                    ✏️
                  </button>
                  <button
                    className="btn-icon btn-danger"
                    title="Eliminar tienda"
                    onClick={(e) => {
                      e.stopPropagation();
                      setModalEliminar({ visible: true, id: t.id });
                    }}
                  >
                    🗑️
                  </button>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Panel de detalle */}
      <div className="tiendas-detalle">
        {tiendaSeleccionada ? (
          <TiendaDetalle
            tienda={tiendaSeleccionada}
            onAgregarALista={handleAgregarALista}
            onTiendaActualizada={cargarTiendas}
          />
        ) : (
          <div className="tienda-placeholder">
            <p>👈 Selecciona una tienda para ver sus productos</p>
          </div>
        )}
      </div>

      {/* Modal crear/editar tienda */}
      <TiendaForm
        visible={modalForm.visible}
        tienda={modalForm.tienda}
        onGuardar={guardarTienda}
        onCerrar={() => setModalForm({ visible: false, tienda: null })}
      />

      {/* Modal confirmar eliminación */}
      <ConfirmModal
        visible={modalEliminar.visible}
        mensaje="¿Eliminar esta tienda? Se perderán todos sus productos registrados."
        tipoBtnConfirmar="btn-danger"
        onConfirm={eliminarTienda}
        onCancel={() => setModalEliminar({ visible: false, id: null })}
      />
    </div>
  );
};

export default Tiendas;
