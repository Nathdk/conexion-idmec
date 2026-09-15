const pool = require('../config/db');

// Crear miembro
const crearMiembro = async (req, res) => {
  const { nombre, telefono, departamento, fecha_ingreso } = req.body;

  if (!nombre || !telefono || !departamento || !fecha_ingreso) {
    return res.status(400).json({ mensaje: 'Todos los campos son obligatorios' });
  }

  try {
    const existe = await pool.query('SELECT * FROM miembro WHERE telefono = $1', [telefono]);
    if (existe.rows.length > 0) {
      return res.status(409).json({ mensaje: 'Ese teléfono ya está registrado' });
    }

    const nuevoMiembro = await pool.query(
      'INSERT INTO miembro (nombre, telefono, departamento, fecha_ingreso) VALUES ($1, $2, $3, $4) RETURNING *',
      [nombre, telefono, departamento, fecha_ingreso]
    );

    res.status(201).json({ mensaje: 'Miembro registrado correctamente', miembro: nuevoMiembro.rows[0] });
  } catch (error) {
    res.status(500).json({ mensaje: 'Error al registrar miembro', error: error.message });
  }
};

// Listar miembros
const listarMiembros = async (req, res) => {
  try {
    const resultado = await pool.query('SELECT * FROM miembro ORDER BY id_miembro');
    res.json(resultado.rows);
  } catch (error) {
    res.status(500).json({ mensaje: 'Error al listar miembros', error: error.message });
  }
};

// Obtener un miembro
const obtenerMiembro = async (req, res) => {
  const { id } = req.params;
  try {
    const resultado = await pool.query('SELECT * FROM miembro WHERE id_miembro = $1', [id]);
    if (resultado.rows.length === 0) {
      return res.status(404).json({ mensaje: 'Miembro no encontrado' });
    }
    res.json(resultado.rows[0]);
  } catch (error) {
    res.status(500).json({ mensaje: 'Error al obtener miembro', error: error.message });
  }
};

// Actualizar miembro
const actualizarMiembro = async (req, res) => {
  const { id } = req.params;
  const { nombre, telefono, departamento, fecha_ingreso } = req.body;

  if (!nombre || !telefono || !departamento || !fecha_ingreso) {
    return res.status(400).json({ mensaje: 'Todos los campos son obligatorios' });
  }

  try {
    const resultado = await pool.query(
      'UPDATE miembro SET nombre = $1, telefono = $2, departamento = $3, fecha_ingreso = $4 WHERE id_miembro = $5 RETURNING *',
      [nombre, telefono, departamento, fecha_ingreso, id]
    );
    if (resultado.rows.length === 0) {
      return res.status(404).json({ mensaje: 'Miembro no encontrado' });
    }
    res.json({ mensaje: 'Miembro actualizado correctamente', miembro: resultado.rows[0] });
  } catch (error) {
    res.status(500).json({ mensaje: 'Error al actualizar miembro', error: error.message });
  }
};

// Eliminar (desactivar) miembro
const eliminarMiembro = async (req, res) => {
  const { id } = req.params;
  try {
    const resultado = await pool.query('DELETE FROM miembro WHERE id_miembro = $1 RETURNING id_miembro', [id]);
    if (resultado.rows.length === 0) {
      return res.status(404).json({ mensaje: 'Miembro no encontrado' });
    }
    res.json({ mensaje: 'Miembro eliminado correctamente' });
  } catch (error) {
    res.status(500).json({ mensaje: 'Error al eliminar miembro', error: error.message });
  }
};

module.exports = { crearMiembro, listarMiembros, obtenerMiembro, actualizarMiembro, eliminarMiembro };