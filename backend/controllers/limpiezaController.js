const pool = require('../config/db');

const COLUMNAS = `l.id_limpieza, to_char(l.semana, 'YYYY-MM-DD') AS semana, l.id_miembro,
                  m.nombre AS nombre_miembro, l.tarea, l.id_lider`;

// Asignar una persona y una tarea a la semana de la fecha indicada
const crearAsignacion = async (req, res) => {
  const { fecha, id_miembro, tarea, id_lider } = req.body;

  if (!fecha || !id_miembro || !tarea || !id_lider) {
    return res.status(400).json({ mensaje: 'Todos los campos son obligatorios' });
  }

  try {
    const nueva = await pool.query(
      `INSERT INTO limpieza (semana, id_miembro, tarea, id_lider)
       VALUES (date_trunc('week', $1::date)::date, $2, $3, $4)
       RETURNING id_limpieza`,
      [fecha, id_miembro, tarea, id_lider]
    );
    res.status(201).json({ mensaje: 'Asignación registrada', id_limpieza: nueva.rows[0].id_limpieza });
  } catch (error) {
    if (error.code === '23503') {
      return res.status(400).json({ mensaje: 'El miembro o el líder indicado no existe' });
    }
    res.status(500).json({ mensaje: 'Error al registrar asignación', error: error.message });
  }
};

// Asignaciones de la semana que contiene la fecha indicada
const listarPorSemana = async (req, res) => {
  const { fecha } = req.params;
  try {
    const resultado = await pool.query(
      `SELECT ${COLUMNAS}
       FROM limpieza l
       JOIN miembro m ON m.id_miembro = l.id_miembro
       WHERE l.semana = date_trunc('week', $1::date)::date
       ORDER BY l.tarea, m.nombre`,
      [fecha]
    );
    res.json(resultado.rows);
  } catch (error) {
    res.status(500).json({ mensaje: 'Error al listar asignaciones', error: error.message });
  }
};

// Historial completo, de la semana más reciente a la más antigua
const historial = async (req, res) => {
  try {
    const resultado = await pool.query(
      `SELECT ${COLUMNAS}
       FROM limpieza l
       JOIN miembro m ON m.id_miembro = l.id_miembro
       ORDER BY l.semana DESC, l.tarea, m.nombre`
    );
    res.json(resultado.rows);
  } catch (error) {
    res.status(500).json({ mensaje: 'Error al obtener el historial', error: error.message });
  }
};

// Modificar una asignación (persona y tarea)
const actualizarAsignacion = async (req, res) => {
  const { id } = req.params;
  const { id_miembro, tarea } = req.body;

  if (!id_miembro || !tarea) {
    return res.status(400).json({ mensaje: 'Miembro y tarea son obligatorios' });
  }

  try {
    const resultado = await pool.query(
      `UPDATE limpieza SET id_miembro = $1, tarea = $2
       WHERE id_limpieza = $3 RETURNING id_limpieza`,
      [id_miembro, tarea, id]
    );
    if (resultado.rows.length === 0) {
      return res.status(404).json({ mensaje: 'Asignación no encontrada' });
    }
    res.json({ mensaje: 'Asignación actualizada correctamente' });
  } catch (error) {
    if (error.code === '23503') {
      return res.status(400).json({ mensaje: 'El miembro indicado no existe' });
    }
    res.status(500).json({ mensaje: 'Error al actualizar asignación', error: error.message });
  }
};

const eliminarAsignacion = async (req, res) => {
  const { id } = req.params;
  try {
    const resultado = await pool.query(
      'DELETE FROM limpieza WHERE id_limpieza = $1 RETURNING id_limpieza',
      [id]
    );
    if (resultado.rows.length === 0) {
      return res.status(404).json({ mensaje: 'Asignación no encontrada' });
    }
    res.json({ mensaje: 'Asignación eliminada correctamente' });
  } catch (error) {
    res.status(500).json({ mensaje: 'Error al eliminar asignación', error: error.message });
  }
};

module.exports = {
  crearAsignacion,
  listarPorSemana,
  historial,
  actualizarAsignacion,
  eliminarAsignacion,
};