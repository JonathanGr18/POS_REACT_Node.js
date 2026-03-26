const express = require('express');
const router = express.Router();
const c = require('../controllers/tiendasCon');

// Rutas de productos con path fijo ANTES de /:id para evitar conflictos
router.put('/productos/:productoId', c.updateProductoTienda);
router.delete('/productos/:productoId', c.deleteProductoTienda);

// Rutas de tiendas
router.get('/', c.getTiendas);
router.post('/', c.createTienda);
router.get('/:id', c.getTienda);
router.put('/:id', c.updateTienda);
router.delete('/:id', c.deleteTienda);
router.get('/:id/productos', c.getProductosTienda);
router.post('/:id/productos', c.addProductoTienda);

module.exports = router;
