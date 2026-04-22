import React, { useState, useEffect, useCallback } from 'react';
import api from '../../services/api';
import { useToast } from '../ui/Toast';
import './BackupSection.css';

const fmtTamano = (bytes) => {
  if (bytes < 1024) return `${bytes} B`;
  if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} KB`;
  return `${(bytes / 1024 / 1024).toFixed(2)} MB`;
};

const fmtFecha = (iso) => {
  try {
    return new Date(iso).toLocaleString('es-MX', {
      day: '2-digit', month: 'short', year: 'numeric',
      hour: '2-digit', minute: '2-digit',
    });
  } catch { return iso; }
};

const BackupSection = () => {
  const { addToast } = useToast();
  const [password, setPassword] = useState('');
  const [autenticado, setAutenticado] = useState(false);
  const [lista, setLista] = useState([]);
  const [cargando, setCargando] = useState(false);
  const [generando, setGenerando] = useState(false);

  const cargarLista = useCallback(async () => {
    if (!password) return;
    setCargando(true);
    try {
      const res = await api.get('/admin/backups', {
        headers: { 'x-admin-password': password },
      });
      setLista(res.data);
      setAutenticado(true);
    } catch (err) {
      if (err?.response?.status === 401) {
        addToast('Contraseña incorrecta', 'error');
        setAutenticado(false);
      } else {
        addToast('Error al cargar respaldos', 'error');
      }
    } finally {
      setCargando(false);
    }
  }, [password, addToast]);

  useEffect(() => {
    if (autenticado) cargarLista();
  }, [autenticado, cargarLista]);

  const handleLogin = (e) => {
    e.preventDefault();
    cargarLista();
  };

  const handleGenerar = async () => {
    setGenerando(true);
    try {
      const res = await api.post('/admin/backups', {}, {
        headers: { 'x-admin-password': password },
      });
      addToast(`Respaldo creado: ${res.data.nombre}`, 'exito');
      cargarLista();
    } catch (err) {
      addToast(err?.response?.data?.error || 'Error al generar respaldo', 'error');
    } finally {
      setGenerando(false);
    }
  };

  const handleDescargar = (nombre) => {
    const url = `${api.defaults.baseURL}/admin/backups/${encodeURIComponent(nombre)}/descargar?password=${encodeURIComponent(password)}`;
    window.open(url, '_blank');
  };

  const handleBorrar = async (nombre) => {
    if (!window.confirm(`¿Eliminar el respaldo "${nombre}"?\nEsta acción no se puede deshacer.`)) return;
    try {
      await api.delete(`/admin/backups/${encodeURIComponent(nombre)}`, {
        headers: { 'x-admin-password': password },
      });
      addToast('Respaldo eliminado', 'exito');
      cargarLista();
    } catch (err) {
      addToast(err?.response?.data?.error || 'Error al eliminar', 'error');
    }
  };

  if (!autenticado) {
    return (
      <form className="backup-auth" onSubmit={handleLogin}>
        <p className="backup-hint">
          Esta sección requiere contraseña de administrador.
        </p>
        <input
          type="password"
          className="settings-input"
          placeholder="Contraseña..."
          value={password}
          onChange={e => setPassword(e.target.value)}
          autoComplete="current-password"
        />
        <button type="submit" className="btn-settings-guardar" disabled={!password || cargando}>
          {cargando ? 'Verificando...' : 'Entrar'}
        </button>
      </form>
    );
  }

  return (
    <div className="backup-section">
      <div className="backup-header">
        <div className="backup-info">
          <span className="backup-count">{lista.length}</span>
          <span className="backup-label">respaldo{lista.length !== 1 ? 's' : ''} guardado{lista.length !== 1 ? 's' : ''}</span>
          <span className="backup-auto">
            Automático diario 3:00 AM · Mantiene últimos 14
          </span>
        </div>
        <button
          className="btn-settings-guardar"
          onClick={handleGenerar}
          disabled={generando}
        >
          {generando ? 'Generando...' : '📦 Generar ahora'}
        </button>
      </div>

      {lista.length === 0 ? (
        <p className="backup-vacio">Aún no hay respaldos. Presiona "Generar ahora" para crear el primero.</p>
      ) : (
        <ul className="backup-lista">
          {lista.map(b => {
            const esAuto = b.nombre.includes('_auto_');
            return (
              <li key={b.nombre} className="backup-item">
                <div className="backup-item-info">
                  <span className={`backup-tipo ${esAuto ? 'auto' : 'manual'}`}>
                    {esAuto ? '⏰ Auto' : '👤 Manual'}
                  </span>
                  <span className="backup-nombre" title={b.nombre}>{b.nombre}</span>
                  <span className="backup-meta">
                    {fmtFecha(b.fecha)} · {fmtTamano(b.tamano)}
                  </span>
                </div>
                <div className="backup-item-actions">
                  <button
                    className="backup-btn backup-btn--download"
                    onClick={() => handleDescargar(b.nombre)}
                    title="Descargar"
                  >⬇️</button>
                  <button
                    className="backup-btn backup-btn--delete"
                    onClick={() => handleBorrar(b.nombre)}
                    title="Eliminar"
                  >🗑️</button>
                </div>
              </li>
            );
          })}
        </ul>
      )}
    </div>
  );
};

export default BackupSection;
