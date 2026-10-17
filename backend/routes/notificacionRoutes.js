const express = require('express');
const router = express.Router();
const notificador = require('../services/notificador');

// Aviso de stock bajo (lo llama el panel web cuando un artículo baja del mínimo)
router.post('/stock-bajo', async (req, res) => {
  const { articulo, cantidad, minimo } = req.body;

  if (!articulo || cantidad === undefined || minimo === undefined) {
    return res.status(400).json({ mensaje: 'Faltan datos del artículo' });
  }

  const enviado = await notificador.enviar({
    tema: 'inventario',
    titulo: 'Stock bajo',
    cuerpo: `"${articulo}": quedan ${cantidad} (mínimo ${minimo})`,
  });

  res.json({ mensaje: enviado ? 'Notificación enviada' : 'No se pudo enviar', enviado });
});

module.exports = router;