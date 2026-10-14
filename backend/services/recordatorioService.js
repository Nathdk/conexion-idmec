const pool = require('../config/db');
const notificador = require('./notificador');

// Días antes del evento en los que se envía un recordatorio.
// Cámbialos a tu criterio (tu documento dice 14 días antes y "cada cierto día").
const DIAS_ANTES = [14, 7, 1];

// Fecha de hoy en hora de México, formato YYYY-MM-DD
const hoy = () => new Date().toLocaleDateString('en-CA', { timeZone: 'America/Mexico_City' });

const armarMensaje = (evento, dias) =>
  dias === 1
    ? `Mañana es "${evento.titulo}" (${evento.fecha})`
    : `Faltan ${dias} días para "${evento.titulo}" (${evento.fecha})`;

// Crea los recordatorios de un evento (omite los que caerían en una fecha que ya pasó)
const programarRecordatorios = async (evento) => {
  for (const dias of DIAS_ANTES) {
    await pool.query(
      `INSERT INTO recordatorio (id_evento, fecha_envio, mensaje)
       SELECT $1::int, ($2::date - $3::int), $4::text
       WHERE ($2::date - $3::int) >= $5::date`,
      [evento.id_evento, evento.fecha, dias, armarMensaje(evento, dias), hoy()]
    );
  }
};

// Envía los recordatorios que corresponden a hoy
const enviarRecordatoriosDelDia = async () => {
  const resultado = await pool.query(
    `SELECT r.id_recordatorio, r.mensaje, e.titulo
     FROM recordatorio r
     JOIN evento e ON e.id_evento = r.id_evento
     WHERE r.fecha_envio = $1::date`,
    [hoy()]
  );

  for (const r of resultado.rows) {
    await notificador.enviar({ tema: 'eventos', titulo: r.titulo, cuerpo: r.mensaje });
  }
  return resultado.rows.length;
};

module.exports = { programarRecordatorios, enviarRecordatoriosDelDia };