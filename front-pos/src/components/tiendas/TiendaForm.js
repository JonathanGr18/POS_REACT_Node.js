import React, { useEffect, useState } from 'react';

const estadoInicial = {
  nombre: '',
  direccion: '',
  telefono: '',
  notas: '',
};

const TiendaForm = ({ visible, tienda, onGuardar, onCerrar }) => {
  const [form, setForm] = useState(estadoInicial);
  const [guardando, setGuardando] = useState(false);

  // Pre-llenar cuando se abre para editar, limpiar cuando es nueva
  useEffect(() => {
    if (tienda) {
      setForm({
        nombre: tienda.nombre ?? '',
        direccion: tienda.direccion ?? '',
        telefono: tienda.telefono ?? '',
        notas: tienda.notas ?? '',
      });
    } else {
      setForm(estadoInicial);
    }
  }, [tienda, visible]);

  const handleChange = (e) => {
    const { name, value } = e.target;
    setForm((prev) => ({ ...prev, [name]: value }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    if (!form.nombre.trim()) return;

    setGuardando(true);
    try {
      const datos = {
        nombre: form.nombre.trim(),
        direccion: form.direccion.trim(),
        telefono: form.telefono.trim(),
        notas: form.notas.trim(),
      };
      if (tienda?.id) {
        datos.id = tienda.id;
      }
      await onGuardar(datos);
    } finally {
      setGuardando(false);
    }
  };

  if (!visible) return null;

  return (
    <div className="modal-overlay" onClick={onCerrar}>
      <div className="modal-box tienda-form-box" onClick={(e) => e.stopPropagation()}>
        <div className="modal-header">
          <h3>{tienda ? 'Editar Tienda' : 'Nueva Tienda'}</h3>
          <button type="button" onClick={onCerrar} aria-label="Cerrar">
            ✕
          </button>
        </div>

        <form onSubmit={handleSubmit} className="tienda-form">
          <div>
            <label htmlFor="tf-nombre">Nombre *</label>
            <input
              id="tf-nombre"
              className="input"
              type="text"
              name="nombre"
              placeholder="Nombre de la tienda"
              value={form.nombre}
              onChange={handleChange}
              required
              autoFocus
            />
          </div>

          <div>
            <label htmlFor="tf-direccion">Dirección</label>
            <textarea
              id="tf-direccion"
              className="input"
              name="direccion"
              placeholder="Dirección (opcional)"
              value={form.direccion}
              onChange={handleChange}
              rows={2}
            />
          </div>

          <div>
            <label htmlFor="tf-telefono">Teléfono</label>
            <input
              id="tf-telefono"
              className="input"
              type="text"
              name="telefono"
              placeholder="Teléfono (opcional)"
              value={form.telefono}
              onChange={handleChange}
            />
          </div>

          <div>
            <label htmlFor="tf-notas">Notas</label>
            <textarea
              id="tf-notas"
              className="input"
              name="notas"
              placeholder="Notas adicionales (opcional)"
              value={form.notas}
              onChange={handleChange}
              rows={3}
            />
          </div>

          <div className="tienda-form-footer">
            <button
              type="submit"
              className="btn btn-primary"
              disabled={guardando || !form.nombre.trim()}
            >
              {guardando ? 'Guardando...' : tienda ? 'Guardar cambios' : 'Crear tienda'}
            </button>
            <button
              type="button"
              className="btn btn-secondary"
              onClick={onCerrar}
              disabled={guardando}
            >
              Cancelar
            </button>
          </div>
        </form>
      </div>
    </div>
  );
};

export default TiendaForm;
