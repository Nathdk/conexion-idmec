// Punto único de envío de notificaciones.
// Por ahora solo escribe en consola; en el siguiente paso se conecta a Firebase (FCM).
const enviar = async ({ tema, titulo, cuerpo }) => {
  console.log(`[NOTIFICACIÓN] (${tema}) ${titulo} - ${cuerpo}`);
  return true;
};

module.exports = { enviar };