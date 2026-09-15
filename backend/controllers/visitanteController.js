const pool = require('../config/db');

// Crear visitante
const crearVisitante = async (req, res) => {
  const { nombre, telefono, fecha_visita, servicio } = req.body;

  if (!nombre || !telefono || !fecha_visita || !servicio) {
    return res.status(400).json({ mensaje: 'Todos los campos son obligatorios' });
  }

  try {
    const nuevoVisitante = await pool.query(
      'INSERT INTO visitante (nombre, telefono, fecha_visita, servicio) VALUES ($1, $2, $3, $4) RETURNING *',
      [nombre, telefono, fecha_visita, servicio]
    );
    res.status(201).json({ mensaje: 'Visitante registrado correctamente', visitante: nuevoVisitante.rows[0] });
  } catch (error) {
    res.status(500).json({ mensaje: 'Error al registrar visitante', error: error.message });
  }
};

// Listar visitantes
const listarVisitantes = async (req, res) => {
  try {
    const resultado = await pool.query('SELECT * FROM visitante ORDER BY id_visitante DESC');
    res.json(resultado.rows);
  } catch (error) {
    res.status(500).json({ mensaje: 'Error al listar visitantes', error: error.message });
  }
};

// Obtener un visitante
const obtenerVisitante = async (req, res) => {
  const { id } = req.params;
  try {
    const resultado = await pool.query('SELECT * FROM visitante WHERE id_visitante = $1', [id]);
    if (resultado.rows.length === 0) {
      return res.status(404).json({ mensaje: 'Visitante no encontrado' });
    }
    res.json(resultado.rows[0]);
  } catch (error) {
    res.status(500).json({ mensaje: 'Error al obtener visitante', error: error.message });
  }
};

// Actualizar visitante
const actualizarVisitante = async (req, res) => {
  const { id } = req.params;
  const { nombre, telefono, fecha_visita, servicio } = req.body;

  if (!nombre || !telefono || !fecha_visita || !servicio) {
    return res.status(400).json({ mensaje: 'Todos los campos son obligatorios' });
  }

  try {
    const resultado = await pool.query(
      'UPDATE visitante SET nombre = $1, telefono = $2, fecha_visita = $3, servicio = $4 WHERE id_visitante = $5 RETURNING *',
      [nombre, telefono, fecha_visita, servicio, id]
    );
    if (resultado.rows.length === 0) {
      return res.status(404).json({ mensaje: 'Visitante no encontrado' });
    }
    res.json({ mensaje: 'Visitante actualizado correctamente', visitante: resultado.rows[0] });
  } catch (error) {
    res.status(500).json({ mensaje: 'Error al actualizar visitante', error: error.message });
  }
};

// Eliminar visitante
const eliminarVisitante = async (req, res) => {
  const { id } = req.params;
  try {
    const resultado = await pool.query('DELETE FROM visitante WHERE id_visitante = $1 RETURNING id_visitante', [id]);
    if (resultado.rows.length === 0) {
      return res.status(404).json({ mensaje: 'Visitante no encontrado' });
    }
    res.json({ mensaje: 'Visitante eliminado correctamente' });
  } catch (error) {
    res.status(500).json({ mensaje: 'Error al eliminar visitante', error: error.message });
  }
};

module.exports = { crearVisitante, listarVisitantes, obtenerVisitante, actualizarVisitante, eliminarVisitante };