const express = require('express');
const router = express.Router();
const dashboardCon = require('../controllers/dashboardCon');

router.get('/resumen', dashboardCon.getResumen);

module.exports = router;
