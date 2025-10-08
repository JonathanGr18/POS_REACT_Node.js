const express = require('express');
const router = express.Router();
const reportesCon = require('../controllers/reportesCon');

// Reportes por día
router.get('/dias', reportesCon.obtenerResumenDias);                  // Últimos 30 días
router.get('/detalle/:fecha', reportesCon.obtenerDetalleDelDia);      // Detalle de un día
router.get('/buscar/:fecha', reportesCon.buscarPorFecha);             // Buscar por fecha exacta

// Reportes mensuales
router.get('/mensual/:mes', reportesCon.obtenerReporteMensualPorMes); // Ingresos/egresos del mes
router.get('/dias-no-abiertos/:mes', reportesCon.obtenerDiasNoAbiertos); // Días sin ventas del mes

module.exports = router;
