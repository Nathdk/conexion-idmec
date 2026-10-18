const pool = require('../config/db');
const notificador = require('./notificador');

// Fecha de hoy en hora de México, formato YYYY-MM-DD
const hoy = () => new Date().toLocaleDateString('en-CA', { timeZone: 'America/Mexico_City' });

// Avisa quién limpia esta semana (si hay asignaciones)
const enviarLimpiezaDeLaSemana = async () => {
  const resultado = await pool.query(
    `SELECT m.nombre, l.tarea
     FROM limpieza l
     JOIN miembro m ON m.id_miembro = l.id_miembro
     WHERE l.semana = date_trunc('week', $1::date)::date
     ORDER BY l.tarea, m.nombre`,
    [hoy()]
  );

  if (resultado.rows.length === 0) return 0;

  const lista = resultado.rows.map((r) => `${r.nombre} (${r.tarea})`).join(', ');
  await notificador.enviar({
    tema: 'limpieza',
    titulo: 'Limpieza de esta semana',
    cuerpo: lista,
  });

  return resultado.rows.length;
};

module.exports = { enviarLimpiezaDeLaSemana };