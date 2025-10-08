import React from 'react';
import './styles/global.css';
import { BrowserRouter as Router, Route, Routes, Navigate } from 'react-router-dom';
import Navbar from './components/ui/Navbar';
import Productos from './pages/Productos';
import Ventas from './pages/Ventas'
import Faltantes from './pages/Faltantes'
import Reportes from './pages/Reportes'

function App() {
  return (
    <Router>
      <Navbar/>
      <Routes>
        {/* RUTA PREDETERMINADA */}
        <Route path="/" element={<Navigate to="/ventas" />} />
        {/* Productos */}
        <Route path='/productos' element={<Productos />}/>
        {/* Ventas */}
        <Route path='/ventas' element={<Ventas />}/>
        {/* Faltantes */}
        <Route path='/faltantes' element={<Faltantes />}/>
        {/* Reportes */}
        <Route path='/reportes' element={<Reportes />}/>

      </Routes>
    </Router>
  )
}

export default App;
