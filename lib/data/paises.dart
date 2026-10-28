/// Lo que cambia de un país a otro al crear colegios y cursos. Por ahora solo
/// Perú; para sumar un país basta con agregar su ficha a [paises].
class Pais {
  final String codigo;
  final String nombre;
  final String bandera;
  final String curriculo;

  /// Grados de cada nivel, en orden.
  final Map<String, List<String>> grados;

  /// Áreas curriculares de cada nivel. "Otro" se agrega al final al mostrarlas.
  final Map<String, List<String>> areas;

  const Pais({
    required this.codigo,
    required this.nombre,
    required this.bandera,
    required this.curriculo,
    required this.grados,
    required this.areas,
  });
}

/// "Otro" deja escribir lo que no está en la lista (área o sección).
const opcionOtro = 'Otro';

/// "Otro" deja escribir la sección (hay colegios con muchas secciones).
const secciones = ['Única', 'A', 'B', 'C', 'D', 'E', 'F', 'G', opcionOtro];

const peru = Pais(
  codigo: 'PE',
  nombre: 'Perú',
  bandera: '🇵🇪',
  curriculo: 'Currículo Nacional de Perú',
  grados: {
    'Inicial': ['3 años', '4 años', '5 años'],
    'Primaria': [
      '1.° grado',
      '2.° grado',
      '3.° grado',
      '4.° grado',
      '5.° grado',
      '6.° grado',
    ],
    'Secundaria': ['1.° año', '2.° año', '3.° año', '4.° año', '5.° año'],
  },
  // Currículo Nacional de la Educación Básica (CNEB, Minedu).
  areas: {
    'Inicial': [
      'Personal Social',
      'Psicomotriz',
      'Comunicación',
      'Castellano como segunda lengua',
      'Matemática',
      'Ciencia y Tecnología',
      'Tutoría',
    ],
    'Primaria': [
      'Personal Social',
      'Educación Física',
      'Comunicación',
      'Arte y Cultura',
      'Castellano como segunda lengua',
      'Inglés como lengua extranjera',
      'Matemática',
      'Ciencia y Tecnología',
      'Educación Religiosa',
      'Tutoría',
    ],
    'Secundaria': [
      'Desarrollo Personal, Ciudadanía y Cívica',
      'Ciencias Sociales',
      'Educación Física',
      'Comunicación',
      'Arte y Cultura',
      'Castellano como segunda lengua',
      'Inglés como lengua extranjera',
      'Matemática',
      'Ciencia y Tecnología',
      'Educación para el Trabajo',
      'Educación Religiosa',
      'Tutoría',
    ],
  },
);

const paises = [peru];

Pais paisPorCodigo(String? codigo) =>
    paises.firstWhere((p) => p.codigo == codigo, orElse: () => peru);
