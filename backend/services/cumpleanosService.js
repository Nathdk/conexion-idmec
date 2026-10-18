const pool = require('../config/db');
const notificador = require('./notificador');

// Fecha de hoy en hora de México, formato YYYY-MM-DD
const hoy = () => new Date().toLocaleDateString('en-CA', { timeZone: 'America/Mexico_City' });

// Cumpleaños de un mes (1 a 12), ordenados por día
const cumpleanosDelMes = async (mes) => {
  const resultado = await pool.query(
    `SELECT id_miembro, nombre, departamento,
            to_char(fecha_nacimiento, 'YYYY-MM-DD') AS fecha_nacimiento,
            EXTRACT(DAY FROM fecha_nacimiento)::int AS dia
     FROM miembro
     WHERE fecha_nacimiento IS NOT NULL
       AND EXTRACT(MONTH FROM fecha_nacimiento) = $1::int
     ORDER BY dia, nombre`,
    [mes]
  );
  return resultado.rows;
};

// Avisa los cumpleaños de hoy (si hay)
const enviarCumpleanosDeHoy = async () => {
  const [anio, mes, dia] = hoy().split('-').map(Number);

  const resultado = await pool.query(
    `SELECT nombre, EXTRACT(YEAR FROM fecha_nacimiento)::int AS anio_nacimiento
     FROM miembro
     WHERE fecha_nacimiento IS NOT NULL
       AND EXTRACT(MONTH FROM fecha_nacimiento) = $1::int
       AND EXTRACT(DAY FROM fecha_nacimiento) = $2::int
     ORDER BY nombre`,
    [mes, dia]
  );

  if (resultado.rows.length === 0) return 0;

  const lista = resultado.rows
    .map((r) => `${r.nombre} (${anio - r.anio_nacimiento} años)`)
    .join(', ');

  await notificador.enviar({
    tema: 'cumpleanos',
    titulo: resultado.rows.length === 1 ? 'Cumpleaños de hoy' : 'Cumpleaños de hoy',
    cuerpo: lista,
  });

  return resultado.rows.length;
};

module.exports = { cumpleanosDelMes, enviarCumpleanosDeHoy };