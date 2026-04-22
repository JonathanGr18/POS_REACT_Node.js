import React, { useEffect, useState, useCallback } from 'react';
import './Navbar.css';
import { NavLink, useLocation } from 'react-router-dom';
import {
  FaTachometerAlt, FaBoxOpen, FaShoppingCart, FaClipboardList,
  FaChartBar, FaStore, FaShoppingBasket, FaCog, FaBell, FaBars, FaTimes
} from 'react-icons/fa';
import useDarkMode from '../../hooks/useDarkMode';
import api from '../../services/api';
import { useReminders } from '../../context/RemindersContext';
import { useSettings } from '../../context/SettingsContext';

const Navbar = () => {
  const { darkMode, toggle } = useDarkMode();
  const [stockCritico, setStockCritico] = useState(0);
  const [expandido, setExpandido] = useState(false);
  const { pendientes, abrirDrawer } = useReminders();
  const { settings } = useSettings();
  const location = useLocation();
  const umbral = settings.stockUmbral || 10;

  const versionRef = React.useRef(0);
  const cargarStockCritico = useCallback(() => {
    const myVersion = ++versionRef.current;
    api.get(`/dashboard/resumen?umbral=${umbral}`)
      .then(res => {
        if (myVersion === versionRef.current) {
          setStockCritico(res.data.stockCritico ?? 0);
        }
      })
      .catch(() => {});
  }, [umbral]);

  useEffect(() => {
    cargarStockCritico();
  }, [cargarStockCritico, location.pathname]);

  useEffect(() => {
    const onFocus = () => {
      if (document.visibilityState === 'visible') cargarStockCritico();
    };
    document.addEventListener('visibilitychange', onFocus);
    return () => document.removeEventListener('visibilitychange', onFocus);
  }, [cargarStockCritico]);

  // Al cambiar de ruta, colapsar (útil cuando se clickea un link)
  useEffect(() => {
    setExpandido(false);
  }, [location.pathname]);

  // Escape cierra el menú
  useEffect(() => {
    if (!expandido) return;
    const onKey = (e) => { if (e.key === 'Escape') setExpandido(false); };
    window.addEventListener('keydown', onKey);
    return () => window.removeEventListener('keydown', onKey);
  }, [expandido]);

  const toggleNav = () => setExpandido(v => !v);

  return (
    <>
      {/* Overlay para cerrar haciendo click afuera cuando está expandido */}
      {expandido && <div className="navbar-overlay" onClick={() => setExpandido(false)} />}

      <nav className={`navbar${expandido ? ' navbar--expandido' : ''}`} aria-label="Navegación principal">
        <button
          className="navbar-toggle"
          onClick={toggleNav}
          aria-label={expandido ? 'Colapsar menú' : 'Expandir menú'}
          aria-expanded={expandido}
        >
          {expandido ? <FaTimes aria-hidden="true" /> : <FaBars aria-hidden="true" />}
        </button>

        <div className="navbar-brand">
          <img src="/Logo.png" alt="" />
          <span className="navbar-brand-texto">PapeAmistad</span>
        </div>

        <div className="navbar-links">
          <NavLink to="/" end className={({ isActive }) => isActive ? 'nav-activo' : ''}>
            <FaTachometerAlt aria-hidden="true" />
            <span className="navbar-label">Dashboard</span>
          </NavLink>
          <NavLink to="/productos" className={({ isActive }) => isActive ? 'nav-activo' : ''}>
            <FaBoxOpen aria-hidden="true" />
            <span className="navbar-label">Productos</span>
          </NavLink>
          <NavLink to="/ventas" className={({ isActive }) => isActive ? 'nav-activo' : ''}>
            <FaShoppingCart aria-hidden="true" />
            <span className="navbar-label">Ventas</span>
          </NavLink>
          <NavLink to="/faltantes" className={({ isActive }) => isActive ? 'nav-activo' : ''}>
            <FaClipboardList aria-hidden="true" />
            <span className="navbar-label">Faltantes</span>
            {settings.notifStockCritico && stockCritico > 0 && (
              <span className="navbar-badge" aria-label={`${stockCritico} productos con stock bajo`}>
                {stockCritico}
              </span>
            )}
          </NavLink>
          <NavLink to="/reportes" className={({ isActive }) => isActive ? 'nav-activo' : ''}>
            <FaChartBar aria-hidden="true" />
            <span className="navbar-label">Reportes</span>
          </NavLink>
          <NavLink to="/tiendas" className={({ isActive }) => isActive ? 'nav-activo' : ''}>
            <FaStore aria-hidden="true" />
            <span className="navbar-label">Tiendas</span>
          </NavLink>
          <NavLink to="/lista-compras" className={({ isActive }) => isActive ? 'nav-activo' : ''}>
            <FaShoppingBasket aria-hidden="true" />
            <span className="navbar-label">Lista compras</span>
          </NavLink>
          <NavLink to="/settings" className={({ isActive }) => isActive ? 'nav-activo' : ''}>
            <FaCog aria-hidden="true" />
            <span className="navbar-label">Config</span>
          </NavLink>
        </div>

        <div className="navbar-bottom">
          <button
            className="navbar-bell"
            onClick={abrirDrawer}
            aria-label={`Recordatorios${pendientes.length > 0 ? ` (${pendientes.length} pendientes)` : ''}`}
          >
            <FaBell aria-hidden="true" />
            <span className="navbar-label">Recordatorios</span>
            {pendientes.length > 0 && (
              <span className="navbar-badge navbar-badge--bell">{pendientes.length}</span>
            )}
          </button>
          <button
            onClick={toggle}
            className="btn-dark-toggle"
            aria-label={darkMode ? 'Cambiar a tema claro' : 'Cambiar a tema oscuro'}
            aria-pressed={darkMode}
          >
            <span aria-hidden="true">{darkMode ? '☀️' : '🌙'}</span>
            <span className="navbar-label">{darkMode ? 'Tema claro' : 'Tema oscuro'}</span>
          </button>
        </div>
      </nav>
    </>
  );
};

export default Navbar;
