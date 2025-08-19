const express = require('express');
const router = express.Router();
const productosCon = require('../controllers/productosCon');

// CRUD de productos
router.get('/', productosCon.getProductos);       // Obtener todos
router.post('/', productosCon.createProducto);    // Crear nuevo
router.put('/:id', productosCon.updateProducto);  // Actualizar
router.delete('/:id', productosCon.deleteProducto); // Eliminar

// Extras
router.get('/faltantes', productosCon.obtenerFaltantes); // Productos con poco o sin stock
router.post('/egresos', productosCon.agregarEgreso);     // Registrar egreso
router.put('/resurtir/:id', productosCon.resurtirProducto); // Resurtir producto

module.exports = router;
