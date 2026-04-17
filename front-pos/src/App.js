import React, { lazy, Suspense } from 'react';
import './styles/global.css';
import { BrowserRouter as Router, Route, Routes } from 'react-router-dom';
import Navbar from './components/ui/Navbar';
import Spinner from './components/ui/Spinner';
import ErrorBoundary from './components/ui/ErrorBoundary';
import { ToastProvider } from './components/ui/Toast';
import { SettingsProvider } from './context/SettingsContext';
import { RemindersProvider } from './context/RemindersContext';
import RecordatoriosDrawer from './components/recordatorios/RecordatoriosDrawer';
import RecordatoriosBanner from './components/recordatorios/RecordatoriosBanner';
import { useReminders } from './context/RemindersContext';
import useDarkMode from './hooks/useDarkMode';

const Dashboard    = lazy(() => import('./pages/Dashboard'));
const Productos    = lazy(() => import('./pages/Productos'));
const Ventas       = lazy(() => import('./pages/Ventas'));
const Faltantes    = lazy(() => import('./pages/Faltantes'));
const Reportes     = lazy(() => import('./pages/Reportes'));
const Tiendas      = lazy(() => import('./pages/Tiendas'));
const ListaCompras = lazy(() => import('./pages/ListaCompras'));
const Settings     = lazy(() => import('./pages/Settings'));

const NotFound = () => (
  <div style={{ textAlign: 'center', padding: '4rem 2rem' }}>
    <h2>404 — Página no encontrada</h2>
    <p>La ruta que buscas no existe.</p>
  </div>
);

const AppInner = () => {
  useDarkMode();
  const { drawerAbierto } = useReminders();

  return (
    <Router>
      <Navbar />
      <div className="app-main">
        <RecordatoriosBanner />
        {drawerAbierto && <RecordatoriosDrawer />}
        <ErrorBoundary>
          <Suspense fallback={<Spinner texto="Cargando..." />}>
            <Routes>
              <Route path="/"              element={<Dashboard />} />
              <Route path="/productos"     element={<Productos />} />
              <Route path="/ventas"        element={<Ventas />} />
              <Route path="/faltantes"     element={<Faltantes />} />
              <Route path="/reportes"      element={<Reportes />} />
              <Route path="/tiendas"       element={<Tiendas />} />
              <Route path="/lista-compras" element={<ListaCompras />} />
              <Route path="/settings"      element={<Settings />} />
              <Route path="*"              element={<NotFound />} />
            </Routes>
          </Suspense>
        </ErrorBoundary>
      </div>
    </Router>
  );
};

function App() {
  return (
    <SettingsProvider>
      <RemindersProvider>
        <ToastProvider>
          <AppInner />
        </ToastProvider>
      </RemindersProvider>
    </SettingsProvider>
  );
}

export default App;
