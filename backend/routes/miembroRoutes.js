const express = require('express');
const router = express.Router();
const {
  crearMiembro,
  listarMiembros,
  obtenerMiembro,
  actualizarMiembro,
  eliminarMiembro
} = require('../controllers/miembroController');

router.post('/', crearMiembro);
router.get('/', listarMiembros);
router.get('/:id', obtenerMiembro);
router.put('/:id', actualizarMiembro);
router.delete('/:id', eliminarMiembro);

module.exports = router;