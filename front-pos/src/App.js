import React from 'react';
import './styles/global.css';
import { BrowserRouter as Router, Route, Routes } from 'react-router-dom';
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
        <Route path='/productos' element={<Productos />}/>
        {/* Codigo, Nombre, precio, stock, descripcion  */}
        <Route path='/ventas' element={<Ventas />}/>
        {/* Ventas */}
        <Route path='/faltantes' element={<Faltantes />}/>
        {/* Faltantes */}
        <Route path='/reportes' element={<Reportes />}/>
        {/* Reportes */}

      </Routes>
    </Router>
  )
}

export default App;
