const pool = require('../config/db');

const COLUMNAS = "id_evento, titulo, to_char(fecha, 'YYYY-MM-DD') AS fecha, descripcion, id_usuario";

// Crear evento
const crearEvento = async (req, res) => {
  const { titulo, fecha, descripcion, id_usuario } = req.body;

  if (!titulo || !fecha || !descripcion || !id_usuario) {
    return res.status(400).json({ mensaje: 'Todos los campos son obligatorios' });
  }

  try {
    const nuevo = await pool.query(
      `INSERT INTO evento (titulo, fecha, descripcion, id_usuario)
       VALUES ($1, $2, $3, $4) RETURNING ${COLUMNAS}`,
      [titulo, fecha, descripcion, id_usuario]
    );
    res.status(201).json({ mensaje: 'Evento creado correctamente', evento: nuevo.rows[0] });
  } catch (error) {
    if (error.code === '23503') {
      return res.status(400).json({ mensaje: 'El usuario indicado no existe' });
    }
    res.status(500).json({ mensaje: 'Error al crear evento', error: error.message });
  }
};

// Listar eventos (primero los próximos, luego los pasados)
const listarEventos = async (req, res) => {
  try {
    const resultado = await pool.query(
      `SELECT ${COLUMNAS} FROM evento
       ORDER BY (fecha < CURRENT_DATE), fecha ASC, id_evento ASC`
    );
    res.json(resultado.rows);
  } catch (error) {
    res.status(500).json({ mensaje: 'Error al listar eventos', error: error.message });
  }
};

// Obtener un evento
const obtenerEvento = async (req, res) => {
  const { id } = req.params;
  try {
    const resultado = await pool.query(
      `SELECT ${COLUMNAS} FROM evento WHERE id_evento = $1`,
      [id]
    );
    if (resultado.rows.length === 0) {
      return res.status(404).json({ mensaje: 'Evento no encontrado' });
    }
    res.json(resultado.rows[0]);
  } catch (error) {
    res.status(500).json({ mensaje: 'Error al obtener evento', error: error.message });
  }
};

// Actualizar evento
const actualizarEvento = async (req, res) => {
  const { id } = req.params;
  const { titulo, fecha, descripcion } = req.body;

  if (!titulo || !fecha || !descripcion) {
    return res.status(400).json({ mensaje: 'Título, fecha y descripción son obligatorios' });
  }

  try {
    const resultado = await pool.query(
      `UPDATE evento SET titulo = $1, fecha = $2, descripcion = $3
       WHERE id_evento = $4 RETURNING ${COLUMNAS}`,
      [titulo, fecha, descripcion, id]
    );
    if (resultado.rows.length === 0) {
      return res.status(404).json({ mensaje: 'Evento no encontrado' });
    }
    res.json({ mensaje: 'Evento actualizado correctamente', evento: resultado.rows[0] });
  } catch (error) {
    res.status(500).json({ mensaje: 'Error al actualizar evento', error: error.message });
  }
};

// Eliminar evento (y sus recordatorios)
const eliminarEvento = async (req, res) => {
  const { id } = req.params;
  try {
    await pool.query('DELETE FROM recordatorio WHERE id_evento = $1', [id]);
    const resultado = await pool.query(
      'DELETE FROM evento WHERE id_evento = $1 RETURNING id_evento',
      [id]
    );
    if (resultado.rows.length === 0) {
      return res.status(404).json({ mensaje: 'Evento no encontrado' });
    }
    res.json({ mensaje: 'Evento eliminado correctamente' });
  } catch (error) {
    res.status(500).json({ mensaje: 'Error al eliminar evento', error: error.message });
  }
};

module.exports = { crearEvento, listarEventos, obtenerEvento, actualizarEvento, eliminarEvento };