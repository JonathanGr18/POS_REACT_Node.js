const express = require('express');
const router = express.Router();
const iaCon = require('../controllers/iaCon');

router.post('/chat', iaCon.chat);

module.exports = router;
