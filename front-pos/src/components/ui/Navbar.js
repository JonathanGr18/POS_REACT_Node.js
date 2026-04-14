import React, { useEffect, useState, useCallback } from 'react';
import './Navbar.css';
import { NavLink, useLocation } from 'react-router-dom';
import { FaTachometerAlt, FaBoxOpen, FaShoppingCart, FaClipboardList, FaChartBar, FaStore, FaShoppingBasket, FaCog, FaBell, FaBars, FaTimes } from 'react-icons/fa';
import useDarkMode from '../../hooks/useDarkMode';
import api from '../../services/api';
import { useReminders } from '../../context/RemindersContext';
import { useSettings } from '../../context/SettingsContext';

const Navbar = () => {
  const { darkMode, toggle } = useDarkMode();
  const [stockCritico, setStockCritico] = useState(0);
  const [menuOpen, setMenuOpen] = useState(false);
  const { pendientes, abrirDrawer } = useReminders();
  const { settings } = useSettings();
  const location = useLocation();
  const umbral = settings.stockUmbral || 10;

  // Recargar stockCritico al cambiar de ruta y cuando el tab vuelve a ser visible
  // Usa un ref de "version" para descartar respuestas obsoletas en cambios rapidos
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

  const cerrarMenu = () => setMenuOpen(false);

  return (
    <nav className='navbar'>
      <a href="#main" className="skip-link">Saltar al contenido</a>
      <div className='navbar-brand'>
        <img src='/Logo.png' alt=''/>
        PapeAmistad
      </div>

      <div className={`navbar-links${menuOpen ? ' open' : ''}`} onClick={cerrarMenu}>
        <NavLink to="/" end className={({ isActive }) => isActive ? 'nav-activo' : ''}>
          <FaTachometerAlt aria-hidden="true" /> Dashboard
        </NavLink>
        <NavLink to="/productos" className={({ isActive }) => isActive ? 'nav-activo' : ''}>
          <FaBoxOpen aria-hidden="true" /> Productos
        </NavLink>
        <NavLink to="/ventas" className={({ isActive }) => isActive ? 'nav-activo' : ''}>
          <FaShoppingCart aria-hidden="true" /> Ventas
        </NavLink>
        <NavLink to="/faltantes" className={({ isActive }) => isActive ? 'nav-activo' : ''}>
          <FaClipboardList aria-hidden="true" /> Faltantes
          {settings.notifStockCritico && stockCritico > 0 && (
            <span className="navbar-badge" aria-label={`${stockCritico} productos con stock bajo`}>
              {stockCritico}
            </span>
          )}
        </NavLink>
        <NavLink to="/reportes" className={({ isActive }) => isActive ? 'nav-activo' : ''}>
          <FaChartBar aria-hidden="true" /> Reportes
        </NavLink>
        <NavLink to="/tiendas" className={({ isActive }) => isActive ? 'nav-activo' : ''}>
          <FaStore aria-hidden="true" /> Tiendas
        </NavLink>
        <NavLink to="/lista-compras" className={({ isActive }) => isActive ? 'nav-activo' : ''}>
          <FaShoppingBasket aria-hidden="true" /> Lista compras
        </NavLink>
        <NavLink to="/settings" className={({ isActive }) => isActive ? 'nav-activo' : ''}>
          <FaCog aria-hidden="true" /> Config
        </NavLink>
      </div>

      <div className="navbar-right">
        <button
          className="navbar-bell"
          onClick={abrirDrawer}
          aria-label={`Recordatorios${pendientes.length > 0 ? ` (${pendientes.length} pendientes)` : ''}`}
        >
          <FaBell aria-hidden="true" />
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
        </button>
        <button
          className="navbar-hamburger"
          onClick={() => setMenuOpen(o => !o)}
          aria-label="Menú"
          aria-expanded={menuOpen}
        >
          {menuOpen ? <FaTimes aria-hidden="true" /> : <FaBars aria-hidden="true" />}
        </button>
      </div>
    </nav>
  );
};

export default Navbar;
