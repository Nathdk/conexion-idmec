const express = require('express');
const router = express.Router();
const {
  crearAsignacion,
  listarPorSemana,
  historial,
  actualizarAsignacion,
  eliminarAsignacion,
} = require('../controllers/limpiezaController');
const { enviarLimpiezaDeLaSemana } = require('../services/limpiezaService');

router.post('/', crearAsignacion);
router.get('/', historial);
router.get('/semana/:fecha', listarPorSemana);

// Dispara el aviso de esta semana manualmente (útil para pruebas y demostraciones)
router.post('/avisar', async (req, res) => {
  try {
    const asignaciones = await enviarLimpiezaDeLaSemana();
    res.json({ mensaje: 'Aviso ejecutado', asignaciones });
  } catch (error) {
    res.status(500).json({ mensaje: 'Error al enviar el aviso', error: error.message });
  }
});

router.put('/:id', actualizarAsignacion);
router.delete('/:id', eliminarAsignacion);

module.exports = router;