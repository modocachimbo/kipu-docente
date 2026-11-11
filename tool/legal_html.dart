// Genera web/privacidad.html y web/terminos.html desde lib/data/legal.dart.
// Uso: dart run tool/legal_html.dart
import 'dart:io';

import 'package:kipu/data/legal.dart';

String _esc(String s) => s
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;');

String _pagina(DocumentoLegal d, String otro, String otroTitulo) {
  final b = StringBuffer()
    ..writeln('<!DOCTYPE html>')
    ..writeln('<html lang="es"><head><meta charset="utf-8">')
    ..writeln(
      '<meta name="viewport" content="width=device-width, initial-scale=1">',
    )
    ..writeln('<title>${_esc(d.titulo)} · Kipu Docente</title>')
    ..writeln('<style>')
    ..writeln(
      'body{font-family:system-ui,-apple-system,"Segoe UI",Roboto,sans-serif;'
      'background:#F3F4FB;color:#1F1B2E;margin:0;line-height:1.6}'
      'main{max-width:760px;margin:0 auto;padding:32px 20px 64px}'
      'h1{font-size:30px;margin:8px 0 4px}h2{font-size:19px;margin:28px 0 6px}'
      '.f{color:#6E6A80;font-size:14px}.logo{font-weight:700;color:#4F5BD5}'
      'a{color:#4F5BD5}.card{background:#fff;border-radius:18px;padding:24px 26px;'
      'margin-top:20px}',
    )
    ..writeln('</style></head><body><main>')
    ..writeln('<div class="logo">Kipu Docente</div>')
    ..writeln('<h1>${_esc(d.titulo)}</h1>')
    ..writeln('<div class="f">Última actualización: $actualizacionLegal</div>')
    ..writeln('<div class="card"><p>${_esc(d.intro)}</p>');
  for (final s in d.secciones) {
    b.writeln('<h2>${_esc(s.titulo)}</h2>');
    for (final p in s.parrafos) {
      b.writeln('<p>${_esc(p)}</p>');
    }
  }
  b
    ..writeln('</div>')
    ..writeln('<p class="f">Ver también: <a href="$otro">$otroTitulo</a></p>')
    ..writeln('</main></body></html>');
  return b.toString();
}

void main() {
  File('web/privacidad.html').writeAsStringSync(
    _pagina(politicaPrivacidad, 'terminos.html', 'Términos de uso'),
  );
  File('web/terminos.html').writeAsStringSync(
    _pagina(terminosUso, 'privacidad.html', 'Política de privacidad'),
  );
  stdout.writeln('Listo: web/privacidad.html y web/terminos.html');
}
