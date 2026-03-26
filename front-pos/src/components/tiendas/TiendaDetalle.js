import React, { useEffect, useState, useCallback } from 'react';
import api from '../../services/api';
import { useToast } from '../ui/Toast';
import Spinner from '../ui/Spinner';
import ConfirmModal from '../ui/ConfirmModal';

const formInicial = { nombre: '', precio: '', notas: '' };

const TiendaDetalle = ({ tienda, onAgregarALista, onTiendaActualizada }) => {
  const { addToast } = useToast();

  const [productos, setProductos] = useState([]);
  const [cargando, setCargando] = useState(false);
  const [formProducto, setFormProducto] = useState(formInicial);
  const [guardando, setGuardando] = useState(false);
  const [modalEliminarProd, setModalEliminarProd] = useState({ visible: false, id: null });

  // Estado para edición inline de productos
  const [editandoId, setEditandoId] = useState(null);
  const [formEdicion, setFormEdicion] = useState(formInicial);
  const [guardandoEdicion, setGuardandoEdicion] = useState(false);

  const cargarProductos = useCallback(async () => {
    setCargando(true);
    try {
      const res = await api.get(`/tiendas/${tienda.id}/productos`);
      setProductos(res.data);
    } catch (err) {
      addToast('Error al cargar productos de la tienda', 'error');
    } finally {
      setCargando(false);
    }
  }, [tienda.id, addToast]);

  // Recargar productos cada vez que cambie la tienda seleccionada
  useEffect(() => {
    setProductos([]);
    setFormProducto(formInicial);
    setEditandoId(null);
    cargarProductos();
  }, [cargarProductos]);

  const handleChangeForm = (e) => {
    const { name, value } = e.target;
    setFormProducto((prev) => ({ ...prev, [name]: value }));
  };

  const handleAgregarProducto = async (e) => {
    e.preventDefault();
    if (!formProducto.nombre.trim()) return;

    setGuardando(true);
    try {
      await api.post(`/tiendas/${tienda.id}/productos`, {
        nombre: formProducto.nombre.trim(),
        precio: formProducto.precio !== '' ? Number(formProducto.precio) : null,
        notas: formProducto.notas.trim(),
      });
      addToast(`Producto "${formProducto.nombre.trim()}" agregado`, 'exito');
      setFormProducto(formInicial);
      await cargarProductos();
      if (onTiendaActualizada) onTiendaActualizada();
    } catch (err) {
      addToast('Error al agregar el producto', 'error');
    } finally {
      setGuardando(false);
    }
  };

  const iniciarEdicion = (p) => {
    setEditandoId(p.id);
    setFormEdicion({
      nombre: p.nombre ?? '',
      precio: p.precio != null ? String(p.precio) : '',
      notas: p.notas ?? '',
    });
  };

  const cancelarEdicion = () => {
    setEditandoId(null);
    setFormEdicion(formInicial);
  };

  const handleChangeEdicion = (e) => {
    const { name, value } = e.target;
    setFormEdicion((prev) => ({ ...prev, [name]: value }));
  };

  const guardarEdicion = async (e) => {
    e.preventDefault();
    if (!formEdicion.nombre.trim()) return;

    setGuardandoEdicion(true);
    try {
      await api.put(`/tiendas/productos/${editandoId}`, {
        nombre: formEdicion.nombre.trim(),
        precio: formEdicion.precio !== '' ? Number(formEdicion.precio) : null,
        notas: formEdicion.notas.trim() || null,
      });
      addToast('Producto actualizado', 'exito');
      cancelarEdicion();
      await cargarProductos();
    } catch (err) {
      addToast('Error al actualizar el producto', 'error');
    } finally {
      setGuardandoEdicion(false);
    }
  };

  const confirmarEliminarProducto = (id) => {
    setModalEliminarProd({ visible: true, id });
  };

  const eliminarProducto = async () => {
    const { id } = modalEliminarProd;
    try {
      await api.delete(`/tiendas/productos/${id}`);
      addToast('Producto eliminado', 'exito');
      await cargarProductos();
      if (onTiendaActualizada) onTiendaActualizada();
    } catch (err) {
      addToast('Error al eliminar el producto', 'error');
    } finally {
      setModalEliminarProd({ visible: false, id: null });
    }
  };

  return (
    <div className="tienda-detalle-container">
      {/* Encabezado de la tienda */}
      <div className="tienda-detalle-header">
        <h2>🏪 {tienda.nombre}</h2>
        {tienda.direccion && (
          <p className="detalle-dir">📍 {tienda.direccion}</p>
        )}
        {tienda.telefono && (
          <p className="detalle-dir">📞 {tienda.telefono}</p>
        )}
        {tienda.notas && (
          <p className="detalle-notas">📝 {tienda.notas}</p>
        )}
      </div>

      {/* Formulario para agregar producto */}
      <div className="agregar-producto-tienda">
        <h4>+ Agregar producto a esta tienda</h4>
        <form onSubmit={handleAgregarProducto} className="form-inline-producto">
          <input
            className="input"
            type="text"
            name="nombre"
            placeholder="Nombre del producto"
            value={formProducto.nombre}
            onChange={handleChangeForm}
            required
          />
          <input
            className="input"
            type="number"
            name="precio"
            placeholder="Precio ref. ($)"
            value={formProducto.precio}
            onChange={handleChangeForm}
            min="0"
            step="0.01"
          />
          <input
            className="input"
            type="text"
            name="notas"
            placeholder="Notas (opcional)"
            value={formProducto.notas}
            onChange={handleChangeForm}
          />
          <button
            className="btn btn-success"
            type="submit"
            disabled={guardando || !formProducto.nombre.trim()}
          >
            {guardando ? 'Agregando...' : 'Agregar'}
          </button>
        </form>
      </div>

      {/* Lista de productos registrados */}
      <div className="productos-tienda-lista">
        <h4>Productos registrados ({productos.length})</h4>

        {cargando ? (
          <Spinner />
        ) : productos.length === 0 ? (
          <p className="no-data">Sin productos registrados. Agrega el primero.</p>
        ) : (
          <div className="productos-tienda-grid">
            {productos.map((p) =>
              editandoId === p.id ? (
                /* Formulario de edición inline */
                <div key={p.id} className="producto-tienda-card">
                  <form
                    onSubmit={guardarEdicion}
                    className="producto-edicion-form"
                    style={{ width: '100%', display: 'flex', flexDirection: 'column', gap: '0.4rem' }}
                  >
                    <input
                      className="input"
                      type="text"
                      name="nombre"
                      placeholder="Nombre del producto"
                      value={formEdicion.nombre}
                      onChange={handleChangeEdicion}
                      required
                      autoFocus
                    />
                    <input
                      className="input"
                      type="number"
                      name="precio"
                      placeholder="Precio ref. ($)"
                      value={formEdicion.precio}
                      onChange={handleChangeEdicion}
                      min="0"
                      step="0.01"
                    />
                    <input
                      className="input"
                      type="text"
                      name="notas"
                      placeholder="Notas (opcional)"
                      value={formEdicion.notas}
                      onChange={handleChangeEdicion}
                    />
                    <div style={{ display: 'flex', gap: '0.4rem', justifyContent: 'flex-end' }}>
                      <button
                        type="submit"
                        className="btn btn-primary btn-sm"
                        disabled={guardandoEdicion || !formEdicion.nombre.trim()}
                      >
                        {guardandoEdicion ? 'Guardando...' : 'Guardar'}
                      </button>
                      <button
                        type="button"
                        className="btn btn-secondary btn-sm"
                        onClick={cancelarEdicion}
                        disabled={guardandoEdicion}
                      >
                        Cancelar
                      </button>
                    </div>
                  </form>
                </div>
              ) : (
                /* Vista normal del producto */
                <div key={p.id} className="producto-tienda-card">
                  <div className="producto-tienda-info">
                    <strong>{p.nombre}</strong>
                    {p.precio != null && p.precio !== '' && (
                      <span className="precio-ref">${Number(p.precio).toFixed(2)}</span>
                    )}
                    {p.notas && <span className="prod-notas">{p.notas}</span>}
                  </div>
                  <div className="producto-tienda-actions">
                    <button
                      className="btn btn-success btn-sm"
                      onClick={() =>
                        onAgregarALista({
                          tienda_id: tienda.id,
                          nombre_producto: p.nombre,
                          precio_ref: p.precio,
                        })
                      }
                      title="Agregar a lista de compras"
                    >
                      🛒 A la lista
                    </button>
                    <button
                      className="btn btn-secondary btn-sm"
                      onClick={() => iniciarEdicion(p)}
                      title="Editar producto"
                    >
                      ✏️ Editar
                    </button>
                    <button
                      className="btn btn-danger btn-sm"
                      onClick={() => confirmarEliminarProducto(p.id)}
                      title="Eliminar producto"
                    >
                      🗑️ Eliminar
                    </button>
                  </div>
                </div>
              )
            )}
          </div>
        )}
      </div>

      {/* Modal confirmar eliminación de producto */}
      <ConfirmModal
        visible={modalEliminarProd.visible}
        mensaje="¿Eliminar este producto de la tienda?"
        tipoBtnConfirmar="btn-danger"
        onConfirm={eliminarProducto}
        onCancel={() => setModalEliminarProd({ visible: false, id: null })}
      />
    </div>
  );
};

export default TiendaDetalle;
