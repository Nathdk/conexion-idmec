const express = require('express');
const cors = require('cors');
require('dotenv').config();
const pool = require('./config/db');
const conectarMongo = require('./config/mongo');

conectarMongo();

const app = express();
app.use(cors());
app.use(express.json());

// Ruta de prueba
app.get('/', (req, res) => {
  res.json({ mensaje: 'API CONEXIÓN IDMEC funcionando correctamente' });
});

// Ruta de prueba de conexión a la base de datos
app.get('/api/test-db', async (req, res) => {
  try {
    const resultado = await pool.query('SELECT NOW()');
    res.json({
      mensaje: 'Conexión a PostgreSQL exitosa',
      hora_servidor: resultado.rows[0].now
    });
  } catch (error) {
    res.status(500).json({
      mensaje: 'Error al conectar con la base de datos',
      error: error.message
    });
  }
});

// Ruta de prueba general del sistema
app.get('/api/status', async (req, res) => {
  res.json({
    api: 'CONEXIÓN IDMEC',
    estado: 'activo',
    postgresql: 'conectado',
    mongodb: 'conectado'
  });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Servidor corriendo en http://localhost:${PORT}`);
});