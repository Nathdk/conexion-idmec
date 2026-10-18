const express = require('express');
const router = express.Router();
const { cumpleanosDelMes, enviarCumpleanosDeHoy } = require('../services/cumpleanosService');

// Cumpleaños de un mes (1 a 12)
router.get('/mes/:mes', async (req, res) => {
  const mes = parseInt(req.params.mes, 10);
  if (!(mes >= 1 && mes <= 12)) {
    return res.status(400).json({ mensaje: 'El mes debe ser un número del 1 al 12' });
  }

  try {
    res.json(await cumpleanosDelMes(mes));
  } catch (error) {
    res.status(500).json({ mensaje: 'Error al consultar cumpleaños', error: error.message });
  }
});

// Dispara el aviso de hoy manualmente (útil para pruebas y demostraciones)
router.post('/avisar', async (req, res) => {
  try {
    const cumpleaneros = await enviarCumpleanosDeHoy();
    res.json({ mensaje: 'Aviso ejecutado', cumpleaneros });
  } catch (error) {
    res.status(500).json({ mensaje: 'Error al enviar el aviso', error: error.message });
  }
});

module.exports = router;