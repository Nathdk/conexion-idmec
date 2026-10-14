const express = require('express');
const cors = require('cors');
require('dotenv').config();
const pool = require('./config/db');
const conectarMongo = require('./config/mongo');
const authRoutes = require('./routes/authRoutes');

const miembroRoutes = require('./routes/miembroRoutes');
const visitanteRoutes = require('./routes/visitanteRoutes');
const asistenciaRoutes = require('./routes/asistenciaRoutes');
const comprobanteRoutes = require('./routes/comprobanteRoutes');
const eventoRoutes = require('./routes/eventoRoutes');
const recordatorioRoutes = require('./routes/recordatorioRoutes');
const cron = require('node-cron');
const { enviarRecordatoriosDelDia } = require('./services/recordatorioService');

conectarMongo();

const app = express();
app.use(cors());
app.use(express.json());
app.use('/api/auth', authRoutes);

app.use('/api/miembros', miembroRoutes);
app.use('/api/visitantes', visitanteRoutes);
app.use('/api/asistencia', asistenciaRoutes);
app.use('/api/comprobantes', comprobanteRoutes);
app.use('/api/eventos', eventoRoutes);
app.use('/api/recordatorios', recordatorioRoutes);

// Todos los días a las 8:00 AM (hora de México) se envían los recordatorios del día
cron.schedule('0 8 * * *', async () => {
  try {
    const total = await enviarRecordatoriosDelDia();
    console.log(`Recordatorios enviados: ${total}`);
  } catch (error) {
    console.error('Error en el envío diario de recordatorios:', error.message);
  }
}, { timezone: 'America/Mexico_City' });

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