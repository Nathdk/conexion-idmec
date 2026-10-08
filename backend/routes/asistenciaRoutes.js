const express = require('express');
const router = express.Router();
const {
  registrarAsistencia,
  listarPorFecha,
  historialPorMiembro,
  estadisticasGenerales
} = require('../controllers/asistenciaController');

router.post('/', registrarAsistencia);
router.get('/fecha/:fecha', listarPorFecha);
router.get('/miembro/:id_miembro', historialPorMiembro);
router.get('/estadisticas', estadisticasGenerales);

module.exports = router;