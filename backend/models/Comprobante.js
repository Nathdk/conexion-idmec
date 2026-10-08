const mongoose = require('mongoose');

const comprobanteSchema = new mongoose.Schema({
  nombre: { type: String, required: true },
  tipo: { type: String, required: true },
  datos: { type: Buffer, required: true },
  fecha: { type: Date, default: Date.now },
});

module.exports = mongoose.model('Comprobante', comprobanteSchema);