const express = require('express');
const multer = require('multer');
const mongoose = require('mongoose');
const Comprobante = require('../models/Comprobante');

const router = express.Router();

const TIPOS_PERMITIDOS = ['application/pdf', 'image/jpeg', 'image/png'];

const upload = multer({
  storage: multer.memoryStorage(),
  limits: { fileSize: 5 * 1024 * 1024 }, // máximo 5 MB
  fileFilter: (req, file, cb) => {
    if (TIPOS_PERMITIDOS.includes(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error('Solo se permiten archivos PDF, JPG o PNG'));
    }
  },
});

// Subir comprobante
router.post('/', (req, res) => {
  upload.single('archivo')(req, res, async (err) => {
    if (err) {
      return res.status(400).json({ mensaje: err.message });
    }
    if (!req.file) {
      return res.status(400).json({ mensaje: 'Debes enviar un archivo en el campo "archivo"' });
    }

    try {
      const comprobante = await Comprobante.create({
        nombre: req.file.originalname,
        tipo: req.file.mimetype,
        datos: req.file.buffer,
      });
      res.status(201).json({ mensaje: 'Comprobante guardado', id: comprobante._id });
    } catch (error) {
      res.status(500).json({ mensaje: 'Error al guardar comprobante', error: error.message });
    }
  });
});

// Ver o descargar comprobante
router.get('/:id', async (req, res) => {
  if (!mongoose.Types.ObjectId.isValid(req.params.id)) {
    return res.status(400).json({ mensaje: 'ID inválido' });
  }

  try {
    const comprobante = await Comprobante.findById(req.params.id);
    if (!comprobante) {
      return res.status(404).json({ mensaje: 'Comprobante no encontrado' });
    }
    res.set('Content-Type', comprobante.tipo);
    res.set('Content-Disposition', `inline; filename="${encodeURIComponent(comprobante.nombre)}"`);
    res.send(comprobante.datos);
  } catch (error) {
    res.status(500).json({ mensaje: 'Error al obtener comprobante', error: error.message });
  }
});

module.exports = router;