import React from 'react';
import InputBusqueda from '../ui/InputBusqueda';
import Boton from '../ui/Boton';

const FiltrosProducto = ({
  busqueda,
  setBusqueda,
  orden,
  setOrden,
  ascendente,
  setAscendente,
  estadoFiltro,
  setEstadoFiltro
}) => {
  return (
    <div className="filtros-productos">
      <InputBusqueda
        value={busqueda}
        onChange={(e) => setBusqueda(e.target.value)}
        placeholder="Buscar por nombre o descripción..."
      />

      <select className="input" value={orden} onChange={(e) => setOrden(e.target.value)}>
        <option value="codigo">Ordenar por Código</option>
        <option value="nombre">Ordenar por Nombre</option>
        <option value="precio">Ordenar por Precio</option>
        <option value="stock">Ordenar por Stock</option>
      </select>

      <Boton
        tipo="secundario"
        onClick={() => setAscendente(!ascendente)}
      >
        {ascendente ? '⬆️ Ascendente' : '⬇️ Descendente'}
      </Boton>

      <select className="input" value={estadoFiltro} onChange={(e) => setEstadoFiltro(e.target.value)}>
        <option value="todos">Todos</option>
        <option value="ok">Disponibles</option>
        <option value="bajo">Por terminar</option>
        <option value="sin">Sin existencia</option>
      </select>
    </div>
  );
};

export default FiltrosProducto;
