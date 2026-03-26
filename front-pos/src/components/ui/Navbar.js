import React, { useEffect, useState } from 'react';
import './Navbar.css';
import { Link } from 'react-router-dom';
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

  useEffect(() => {
    api.get('/dashboard/resumen')
      .then(res => setStockCritico(res.data.stockCritico ?? 0))
      .catch(() => {});
  }, []);

  const cerrarMenu = () => setMenuOpen(false);

  return (
    <nav className='navbar'>
      <div className='navbar-brand'>
        <img src='/Logo.png' alt='Logo Papeleria'/>
        PapeAmistad
      </div>

      <div className={`navbar-links${menuOpen ? ' open' : ''}`} onClick={cerrarMenu}>
        <Link to="/"><FaTachometerAlt /> Dashboard</Link>
        <Link to="/productos"><FaBoxOpen /> Productos</Link>
        <Link to="/ventas"><FaShoppingCart /> Ventas</Link>
        <Link to="/faltantes">
          <FaClipboardList /> Faltantes
          {settings.notifStockCritico && stockCritico > 0 && (
            <span className="navbar-badge">{stockCritico}</span>
          )}
        </Link>
        <Link to="/reportes"><FaChartBar /> Reportes</Link>
        <Link to="/tiendas"><FaStore /> Tiendas</Link>
        <Link to="/lista-compras"><FaShoppingBasket /> Compras</Link>
        <Link to="/settings"><FaCog /> Config</Link>
      </div>

      <div className="navbar-right">
        <button className="navbar-bell" onClick={abrirDrawer} title="Recordatorios">
          <FaBell />
          {pendientes.length > 0 && (
            <span className="navbar-badge navbar-badge--bell">{pendientes.length}</span>
          )}
        </button>
        <button onClick={toggle} className="btn-dark-toggle" title="Cambiar tema">
          {darkMode ? '☀️' : '🌙'}
        </button>
        <button
          className="navbar-hamburger"
          onClick={() => setMenuOpen(o => !o)}
          aria-label="Menú"
        >
          {menuOpen ? <FaTimes /> : <FaBars />}
        </button>
      </div>
    </nav>
  );
};

export default Navbar;
