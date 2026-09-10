const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const pool = require('../config/db');

// Registrar un nuevo usuario
const registrar = async (req, res) => {
  const { nombre, correo, contrasena, rol } = req.body;

  if (!nombre || !correo || !contrasena || !rol) {
    return res.status(400).json({ mensaje: 'Todos los campos son obligatorios' });
  }

  try {
    // Verificar si el correo ya existe
    const existe = await pool.query('SELECT * FROM usuario WHERE correo = $1', [correo]);
    if (existe.rows.length > 0) {
      return res.status(409).json({ mensaje: 'Ese correo ya está registrado' });
    }

    // Cifrar la contraseña
    const contrasenaCifrada = await bcrypt.hash(contrasena, 10);

    // Insertar el nuevo usuario
    const nuevoUsuario = await pool.query(
      'INSERT INTO usuario (nombre, correo, contrasena, rol) VALUES ($1, $2, $3, $4) RETURNING id_usuario, nombre, correo, rol',
      [nombre, correo, contrasenaCifrada, rol]
    );

    res.status(201).json({
      mensaje: 'Usuario registrado correctamente',
      usuario: nuevoUsuario.rows[0]
    });
  } catch (error) {
    res.status(500).json({ mensaje: 'Error al registrar usuario', error: error.message });
  }
};

// Iniciar sesión
const login = async (req, res) => {
  const { correo, contrasena } = req.body;

  if (!correo || !contrasena) {
    return res.status(400).json({ mensaje: 'Correo y contraseña son obligatorios' });
  }

  try {
    const resultado = await pool.query('SELECT * FROM usuario WHERE correo = $1', [correo]);

    if (resultado.rows.length === 0) {
      return res.status(401).json({ mensaje: 'Correo o contraseña incorrectos' });
    }

    const usuario = resultado.rows[0];
    const contrasenaValida = await bcrypt.compare(contrasena, usuario.contrasena);

    if (!contrasenaValida) {
      return res.status(401).json({ mensaje: 'Correo o contraseña incorrectos' });
    }

    // Generar token JWT
    const token = jwt.sign(
      { id_usuario: usuario.id_usuario, rol: usuario.rol },
      process.env.JWT_SECRET,
      { expiresIn: '8h' }
    );

    res.json({
      mensaje: 'Inicio de sesión exitoso',
      token,
      usuario: {
        id_usuario: usuario.id_usuario,
        nombre: usuario.nombre,
        correo: usuario.correo,
        rol: usuario.rol
      }
    });
  } catch (error) {
    res.status(500).json({ mensaje: 'Error al iniciar sesión', error: error.message });
  }
};

module.exports = { registrar, login };