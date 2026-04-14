const express = require('express');
const router = express.Router();
const productosCon = require('../controllers/productosCon');

router.post('/', productosCon.agregarEgreso);

module.exports = router;
