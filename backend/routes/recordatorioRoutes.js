const express = require('express');
const router = express.Router();
const pool = require('../config/db');
const { enviarRecordatoriosDelDia } = require('../services/recordatorioService');
const notificador = require('../services/notificador');

// Listar recordatorios programados
router.get('/', async (req, res) => {
  try {
    const resultado = await pool.query(
      `SELECT r.id_recordatorio, r.id_evento, e.titulo,
              to_char(r.fecha_envio, 'YYYY-MM-DD') AS fecha_envio, r.mensaje
       FROM recordatorio r
       JOIN evento e ON e.id_evento = r.id_evento
       ORDER BY r.fecha_envio, r.id_recordatorio`
    );
    res.json(resultado.rows);
  } catch (error) {
    res.status(500).json({ mensaje: 'Error al listar recordatorios', error: error.message });
  }
});

// Ejecutar la revisión de hoy manualmente (útil para pruebas y demostraciones)
router.post('/ejecutar', async (req, res) => {
  try {
    const enviados = await enviarRecordatoriosDelDia();
    res.json({ mensaje: 'Revisión ejecutada', enviados });
  } catch (error) {
    res.status(500).json({ mensaje: 'Error al ejecutar recordatorios', error: error.message });
  }
});

// Envía una notificación de prueba a los celulares suscritos
router.post('/prueba', async (req, res) => {
  const enviado = await notificador.enviar({
    tema: 'eventos',
    titulo: 'Prueba CONEXIÓN IDMEC',
    cuerpo: 'Si ves esto, las notificaciones funcionan',
  });
  res.json({ mensaje: enviado ? 'Notificación enviada' : 'No se pudo enviar, revisa la consola del backend' });
});


module.exports = router;