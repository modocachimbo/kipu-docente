# Kipu Docente

Registro digital del docente: colegios, cursos, estudiantes, asistencia y notas con la escala AD/A/B/C del MINEDU. Funciona sin internet: todo se guarda en el dispositivo (SQLite).

- **Probar en el navegador:** https://modocachimbo.github.io/kipu-docente/
- **Descargar el APK de prueba (Android):** [última versión](https://github.com/modocachimbo/kipu-docente/releases/tag/ultima)

## Desarrollo

Hecho con Flutter.

```bash
flutter pub get
dart run build_runner build   # genera lib/data/database.g.dart
flutter run
```

Para la versión web, `web/sqlite3.wasm` y `web/drift_worker.js` deben estar en la carpeta `web/`.
