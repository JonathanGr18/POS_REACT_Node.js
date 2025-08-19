import React from 'react';
import './Navbar.css';
import { Link } from 'react-router-dom';
import { FaBoxOpen, FaShoppingCart, FaClipboardList, FaChartBar } from 'react-icons/fa';

const Navbar = () => {
  return (
    <nav className='navbar'>
      <div className='navbar-brand'>
        <img src='/Logo.png' alt='Logo Papeleria'/>
        PapeAmistad</div>
      <div className='navbar-links'>
        <Link to="/productos"><FaBoxOpen /> Productos</Link>
        <Link to="/ventas"><FaShoppingCart /> Ventas</Link>
        <Link to="/faltantes"><FaClipboardList /> Faltantes</Link>
        <Link to="/reportes"><FaChartBar /> Reportes</Link>
      </div>
    </nav>
  );
};

export default Navbar;
