const express = require('express');
const router = express.Router();
const {
  registrar,
  login,
  listarUsuarios,
  obtenerUsuario,
  actualizarUsuario,
  eliminarUsuario
} = require('../controllers/authController');

router.post('/registrar', registrar);
router.post('/login', login);
router.get('/usuarios', listarUsuarios);
router.get('/usuarios/:id', obtenerUsuario);
router.put('/usuarios/:id', actualizarUsuario);
router.delete('/usuarios/:id', eliminarUsuario);

module.exports = router;