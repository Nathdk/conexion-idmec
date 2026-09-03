const mongoose = require('mongoose');
require('dotenv').config();

const conectarMongo = async () => {
  try {
    await mongoose.connect(process.env.MONGO_URI);
    console.log('Conexión a MongoDB exitosa');
  } catch (error) {
    console.error('Error al conectar con MongoDB:', error.message);
  }
};

module.exports = conectarMongo;