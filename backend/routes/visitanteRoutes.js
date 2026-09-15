const express = require('express');
const router = express.Router();
const {
  crearVisitante,
  listarVisitantes,
  obtenerVisitante,
  actualizarVisitante,
  eliminarVisitante
} = require('../controllers/visitanteController');

router.post('/', crearVisitante);
router.get('/', listarVisitantes);
router.get('/:id', obtenerVisitante);
router.put('/:id', actualizarVisitante);
router.delete('/:id', eliminarVisitante);

module.exports = router;