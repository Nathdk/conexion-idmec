const { initializeApp, cert } = require('firebase-admin/app');
const { getMessaging } = require('firebase-admin/messaging');

let mensajero = null;

try {
  const clave = require('../config/firebase-key.json');
  const app = initializeApp({ credential: cert(clave) });
  mensajero = getMessaging(app);
} catch (error) {
  console.warn('Firebase no está configurado, las notificaciones solo se mostrarán en consola:', error.message);
}

// Punto único de envío: manda la notificación a todos los celulares suscritos al "tema"
const enviar = async ({ tema, titulo, cuerpo }) => {
  if (!mensajero) {
    console.log(`[NOTIFICACIÓN] (${tema}) ${titulo} - ${cuerpo}`);
    return false;
  }

  try {
    await mensajero.send({
      topic: tema,
      notification: { title: titulo, body: cuerpo },
      android: { priority: 'high' },
    });
    console.log(`[NOTIFICACIÓN ENVIADA] (${tema}) ${titulo} - ${cuerpo}`);
    return true;
  } catch (error) {
    console.error('Error al enviar notificación:', error.message);
    return false;
  }
};

module.exports = { enviar };