const express = require('express');
const router = express.Router();
const c = require('../controllers/listaComprasCon');

router.get('/', c.getLista);
router.post('/', c.addItem);
router.patch('/:id/toggle', c.toggleItem);
router.patch('/:id', c.updateItem);
router.delete('/completados', c.clearCompletados);
router.delete('/:id', c.deleteItem);


module.exports = router;
