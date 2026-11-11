/// Términos de uso y Política de privacidad de Kipu.
///
/// El mismo texto está publicado en web/privacidad.html y web/terminos.html,
/// que son las direcciones que pide Google Play. Si cambias uno, cambia el
/// otro y sube `versionLegal` en cuenta.dart.
library;

/// Correo al que los docentes escriben por privacidad o soporte.
/// TODO(javier): poner el correo definitivo antes de publicar en Play Store.
const correoContacto = '[correo de contacto]';

const urlPrivacidad =
    'https://modocachimbo.github.io/kipu-docente/privacidad.html';
const urlTerminos = 'https://modocachimbo.github.io/kipu-docente/terminos.html';

const actualizacionLegal = '11 de noviembre de 2026';

class SeccionLegal {
  final String titulo;
  final List<String> parrafos;
  const SeccionLegal(this.titulo, this.parrafos);
}

class DocumentoLegal {
  final String titulo;
  final String intro;
  final List<SeccionLegal> secciones;
  const DocumentoLegal(this.titulo, this.intro, this.secciones);
}

const politicaPrivacidad = DocumentoLegal(
  'Política de privacidad',
  'En Kipu cuidamos los datos de los docentes y de sus estudiantes. Aquí '
      'explicamos qué datos usa la app, para qué y qué control tienes sobre '
      'ellos. Esta política sigue la Ley N.° 29733 de Protección de Datos '
      'Personales del Perú.',
  [
    SeccionLegal('1. Qué datos usamos', [
      'Datos de tu cuenta: tu nombre, tu correo y, si entras con Google o '
          'Facebook, el identificador que esa cuenta nos comparte. Si usas '
          'contraseña, solo guardamos una versión cifrada de ella.',
      'Datos que tú registras: colegios, cursos, estudiantes, asistencia, '
          'notas, comentarios, horario, planificación y tu diario.',
      'Datos de tu plan: si estás en la prueba gratis o en un plan de pago y '
          'sus fechas. Los pagos los procesa Google Play; Kipu no ve ni guarda '
          'los datos de tu tarjeta.',
    ]),
    SeccionLegal('2. Dónde se guardan', [
      'Todo lo que registras se guarda en tu dispositivo. Kipu funciona sin '
          'internet.',
      'Si activas la copia de seguridad o la sincronización, la copia se '
          'guarda en tu propio Google Drive, con tu cuenta de Google.',
    ]),
    SeccionLegal('3. Datos de los estudiantes', [
      'Los datos de los estudiantes los registras tú como docente, para tu '
          'trabajo en el aula. Tú y tu institución son responsables de '
          'tenerlos con permiso y de usarlos solo con fines educativos.',
      'Kipu no vende ni comparte los datos de los estudiantes, no los usa para '
          'publicidad y no los envía a ningún servidor de Kipu.',
    ]),
    SeccionLegal('4. Asistente de inteligencia artificial', [
      'El asistente es opcional. Si lo activas con tu propia clave de un '
          'proveedor (Google Gemini, OpenAI, Groq o DeepSeek), el texto que '
          'le pidas se envía a ese proveedor con su propia política de '
          'privacidad.',
      'Por defecto Kipu cambia los nombres de los estudiantes por '
          '«Estudiante 1, 2, 3…» antes de enviar el texto.',
    ]),
    SeccionLegal('5. Para qué los usamos', [
      'Para que la app funcione: mostrar tus cursos, calcular promedios, '
          'hacer reportes, recordarte tus clases y guardar tus copias.',
      'Para saber qué plan tienes y cuántos días te quedan de prueba.',
      'No usamos tus datos para publicidad ni los vendemos a nadie.',
    ]),
    SeccionLegal('6. Tus derechos', [
      'Puedes ver, corregir y descargar tus datos dentro de la app en '
          'cualquier momento.',
      'Puedes borrar tu cuenta y todos tus datos desde Mi cuenta › Borrar mi '
          'cuenta. También puedes pedirlo escribiendo a $correoContacto.',
    ]),
    SeccionLegal('7. Menores de edad', [
      'Kipu es una app para docentes adultos. No está pensada para que la usen '
          'los estudiantes.',
    ]),
    SeccionLegal('8. Cambios y contacto', [
      'Si cambiamos esta política te avisaremos dentro de la app antes de que '
          'el cambio se aplique.',
      'Para cualquier consulta sobre tus datos escríbenos a $correoContacto.',
    ]),
  ],
);

const terminosUso = DocumentoLegal(
  'Términos de uso',
  'Al crear tu cuenta en Kipu aceptas estos términos. Léelos con calma; si no '
      'estás de acuerdo, no uses la app.',
  [
    SeccionLegal('1. Qué es Kipu', [
      'Kipu es una app para que los docentes organicen sus colegios, cursos, '
          'estudiantes, asistencia, notas, horario y planificación.',
    ]),
    SeccionLegal('2. Tu cuenta', [
      'Necesitas una cuenta para usar Kipu. Debes dar datos reales y cuidar el '
          'acceso a tu cuenta y a tu dispositivo.',
      'Puedes cerrar sesión o borrar tu cuenta cuando quieras desde Mi cuenta.',
    ]),
    SeccionLegal('3. Prueba gratis y planes', [
      'Al crear tu cuenta puedes probar Kipu completo gratis durante '
          '$_diasPrueba días, sin tarjeta.',
      'Después necesitas un plan de pago: mensual (S/ 15) o anual (S/ 120). '
          'Los pagos se hacen con Google Play y se renuevan solos hasta que '
          'los canceles desde Google Play.',
      'Las devoluciones siguen las reglas de Google Play.',
      'Si tu prueba o tu plan termina, tus datos no se borran.',
    ]),
    SeccionLegal('4. Tus datos', [
      'Los datos que registras son tuyos. Eres responsable de tener permiso '
          'para registrar los datos de tus estudiantes y de usarlos solo con '
          'fines educativos.',
      'Te recomendamos hacer copias de seguridad. Kipu guarda los datos en tu '
          'dispositivo, y si lo pierdes o lo borras sin copia, no podremos '
          'recuperarlos.',
    ]),
    SeccionLegal('5. Uso correcto', [
      'No uses Kipu para fines ilegales ni para dañar a otras personas, y no '
          'intentes copiar, vender o modificar la app.',
    ]),
    SeccionLegal('6. Asistente de IA', [
      'Las sugerencias del asistente son una ayuda. Revísalas siempre antes de '
          'usarlas con tus estudiantes; la decisión final es tuya.',
    ]),
    SeccionLegal('7. Responsabilidad', [
      'Trabajamos para que Kipu funcione bien, pero no podemos garantizar que '
          'nunca tenga errores. Revisa tus notas y reportes antes de '
          'entregarlos a tu institución.',
    ]),
    SeccionLegal('8. Cambios y contacto', [
      'Podemos actualizar estos términos. Si el cambio es importante te '
          'avisaremos dentro de la app.',
      'Para cualquier consulta escríbenos a $correoContacto.',
    ]),
  ],
);

const _diasPrueba = 7;
