import 'package:flutter_test/flutter_test.dart';
import 'package:kipu/data/instrumentos.dart';
import 'package:kipu/data/instrumentos_ejemplos.dart';

void main() {
  final carpetas = [for (final (c, _) in carpetasIniciales) c];
  Instrumento ej(String id) => ejemplosInstrumentos.firstWhere((e) => e.id == id);

  test('cada ejemplo cae en la carpeta que corresponde', () {
    expect(carpetaSugerida(ej('ej-cuaderno'), carpetas), 'cuadernos');
    expect(carpetaSugerida(ej('ej-tareas'), carpetas), 'cuadernos');
    expect(carpetaSugerida(ej('ej-exposicion'), carpetas), 'exposiciones');
    expect(carpetaSugerida(ej('ej-debate'), carpetas), 'exposiciones');
    expect(carpetaSugerida(ej('ej-informe-lab'), carpetas), 'trabajos');
    expect(carpetaSugerida(ej('ej-proyecto'), carpetas), 'trabajos');
    expect(carpetaSugerida(ej('ej-bimestral'), carpetas), 'examenes');
    expect(carpetaSugerida(ej('ej-quiz-vf'), carpetas), 'examenes');
    expect(carpetaSugerida(ej('ej-actitudinal'), carpetas), 'actitudes');
    expect(carpetaSugerida(ej('ej-participacion'), carpetas), 'actitudes');
  });

  test('solo sugiere carpetas que existen, también las del docente', () {
    expect(carpetaSugerida(ej('ej-bimestral'), const []), '');
    final mias = [const Carpeta('x1', 'Laboratorio de química', 0xFF000000)];
    final ins = Instrumento(
      id: 'i',
      tipo: TipoInstrumento.cotejo,
      nombre: 'Lista para laboratorio de química',
      escala: etiquetasCotejo.first.niveles,
      items: const [ItemInstrumento(id: 'a', texto: 'Usa mandil')],
    );
    expect(carpetaSugerida(ins, mias), 'x1');
  });

  test('carpeta y origen se guardan en JSON', () {
    final c = duplicar(ej('ej-cuaderno'), ejemplo: true).copiar(carpeta: 'cuadernos');
    final x = Instrumento.deJson(c.aJson());
    expect(x.carpeta, 'cuadernos');
    expect(x.origen, 'ej-cuaderno');
    final l = Carpeta.listaDeJson(Carpeta.listaAJson(carpetas));
    expect([for (final c in l) (c.id, c.nombre, c.color)],
        [for (final c in carpetas) (c.id, c.nombre, c.color)]);
    expect(Carpeta.listaDeJson('no es json'), isEmpty);
  });
}
