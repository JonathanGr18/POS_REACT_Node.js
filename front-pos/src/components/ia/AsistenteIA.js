import React, { useState, useRef, useEffect } from 'react';
import { FaRobot, FaTimes, FaPaperPlane } from 'react-icons/fa';
import api from '../../services/api';
import './AsistenteIA.css';

const AsistenteIA = () => {
  const [abierto, setAbierto] = useState(false);
  const [mensajes, setMensajes] = useState([
    { role: 'assistant', content: '¡Hola! Soy POS Expert, tu consultor especializado en papelerías. Puedo analizar tus ventas, optimizar tu inventario, sugerirte estrategias y ayudarte a hacer crecer tu negocio. ¿En qué te ayudo?' }
  ]);
  const [input, setInput] = useState('');
  const [cargando, setCargando] = useState(false);
  const mensajesRef = useRef(null);
  const inputRef = useRef(null);

  useEffect(() => {
    if (mensajesRef.current) {
      mensajesRef.current.scrollTop = mensajesRef.current.scrollHeight;
    }
  }, [mensajes]);

  useEffect(() => {
    if (abierto && inputRef.current) {
      inputRef.current.focus();
    }
  }, [abierto]);

  const enviarMensaje = async (e) => {
    e.preventDefault();
    const texto = input.trim();
    if (!texto || cargando) return;

    const nuevosMensajes = [...mensajes, { role: 'user', content: texto }];
    setMensajes(nuevosMensajes);
    setInput('');
    setCargando(true);

    try {
      // Enviar historial sin el mensaje de bienvenida
      const historial = nuevosMensajes
        .slice(1, -1) // quitar bienvenida y último mensaje (va como "mensaje")
        .map(m => ({ role: m.role, content: m.content }));

      const { data } = await api.post('/ia/chat', {
        mensaje: texto,
        historial
      });

      setMensajes(prev => [...prev, { role: 'assistant', content: data.respuesta }]);
    } catch (err) {
      const errorMsg = err.response?.data?.error || 'Error al conectar con el asistente';
      setMensajes(prev => [...prev, { role: 'assistant', content: `⚠️ ${errorMsg}` }]);
    } finally {
      setCargando(false);
    }
  };

  return (
    <>
      {/* Botón flotante */}
      <button
        className={`ia-fab ${abierto ? 'ia-fab--oculto' : ''}`}
        onClick={() => setAbierto(true)}
        title="Asistente IA"
      >
        <FaRobot size={24} />
      </button>

      {/* Ventana de chat */}
      {abierto && (
        <div className="ia-chat">
          <div className="ia-chat__header">
            <div className="ia-chat__header-info">
              <FaRobot size={18} />
              <span>POS Expert</span>
              <span className="ia-chat__badge">DeepSeek</span>
            </div>
            <button className="ia-chat__cerrar" onClick={() => setAbierto(false)}>
              <FaTimes size={16} />
            </button>
          </div>

          <div className="ia-chat__mensajes" ref={mensajesRef}>
            {mensajes.map((msg, i) => (
              <div key={i} className={`ia-chat__burbuja ia-chat__burbuja--${msg.role}`}>
                {msg.content}
              </div>
            ))}
            {cargando && (
              <div className="ia-chat__burbuja ia-chat__burbuja--assistant ia-chat__burbuja--cargando">
                <span className="ia-dots"><span>.</span><span>.</span><span>.</span></span>
              </div>
            )}
          </div>

          <form className="ia-chat__form" onSubmit={enviarMensaje}>
            <input
              ref={inputRef}
              type="text"
              className="ia-chat__input"
              placeholder="Escribe tu pregunta..."
              value={input}
              onChange={(e) => setInput(e.target.value)}
              disabled={cargando}
              maxLength={500}
            />
            <button
              type="submit"
              className="ia-chat__enviar"
              disabled={!input.trim() || cargando}
            >
              <FaPaperPlane size={14} />
            </button>
          </form>
        </div>
      )}
    </>
  );
};

export default AsistenteIA;
