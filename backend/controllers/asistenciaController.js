const pool = require('../config/db');

// Registrar asistencia (uno o varios miembros a la vez)
const registrarAsistencia = async (req, res) => {
  const { fecha, id_lider, ids_miembros } = req.body;

  if (!fecha || !id_lider || !ids_miembros || !Array.isArray(ids_miembros) || ids_miembros.length === 0) {
    return res.status(400).json({ mensaje: 'Fecha, líder y al menos un miembro son obligatorios' });
  }

  try {
    const registros = [];
    for (const id_miembro of ids_miembros) {
      const resultado = await pool.query(
        'INSERT INTO asistencia (fecha, id_miembro, id_lider) VALUES ($1, $2, $3) RETURNING *',
        [fecha, id_miembro, id_lider]
      );
      registros.push(resultado.rows[0]);
    }
    res.status(201).json({ mensaje: 'Asistencia registrada correctamente', registros });
  } catch (error) {
    res.status(500).json({ mensaje: 'Error al registrar asistencia', error: error.message });
  }
};

// Listar asistencia por fecha
const listarPorFecha = async (req, res) => {
  const { fecha } = req.params;
  try {
    const resultado = await pool.query(
      `SELECT a.id_asistencia, a.fecha, m.id_miembro, m.nombre AS nombre_miembro, u.nombre AS nombre_lider
       FROM asistencia a
       JOIN miembro m ON a.id_miembro = m.id_miembro
       JOIN usuario u ON a.id_lider = u.id_usuario
       WHERE a.fecha = $1
       ORDER BY m.nombre`,
      [fecha]
    );
    res.json(resultado.rows);
  } catch (error) {
    res.status(500).json({ mensaje: 'Error al listar asistencia', error: error.message });
  }
};

// Historial de asistencia de un miembro específico
const historialPorMiembro = async (req, res) => {
  const { id_miembro } = req.params;
  try {
    const resultado = await pool.query(
      `SELECT a.id_asistencia, a.fecha, u.nombre AS nombre_lider
       FROM asistencia a
       JOIN usuario u ON a.id_lider = u.id_usuario
       WHERE a.id_miembro = $1
       ORDER BY a.fecha DESC`,
      [id_miembro]
    );
    res.json(resultado.rows);
  } catch (error) {
    res.status(500).json({ mensaje: 'Error al obtener historial', error: error.message });
  }
};

// Estadísticas básicas: total de asistencias por miembro
const estadisticasGenerales = async (req, res) => {
  try {
    const resultado = await pool.query(
      `SELECT m.id_miembro, m.nombre, COUNT(a.id_asistencia) AS total_asistencias
       FROM miembro m
       LEFT JOIN asistencia a ON m.id_miembro = a.id_miembro
       GROUP BY m.id_miembro, m.nombre
       ORDER BY total_asistencias DESC`
    );
    res.json(resultado.rows);
  } catch (error) {
    res.status(500).json({ mensaje: 'Error al obtener estadísticas', error: error.message });
  }
};

module.exports = { registrarAsistencia, listarPorFecha, historialPorMiembro, estadisticasGenerales };