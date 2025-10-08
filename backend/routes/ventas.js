const express = require('express');
const router = express.Router();
const ventasCon = require('../controllers/ventasCon');

// Endpoints de ventas
router.post('/', ventasCon.registrarVenta);              // Registrar venta
router.get('/', ventasCon.obtenerVentas);                // Obtener todas las ventas
router.get('/hoy', ventasCon.obtenerVentasDelDia);       // Ventas de hoy
router.get('/anteriores', ventasCon.obtenerVentasAnteriores); // Ventas anteriores
router.get('/reportes', ventasCon.obtenerVentasPorFecha);     // Ventas por fechas

module.exports = router;
