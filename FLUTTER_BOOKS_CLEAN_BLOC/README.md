# Flutter Books Clean BLoC

Libris es una biblioteca digital para descubrir libros mediante el catálogo abierto de Open Library. El proyecto transforma la base Flutter existente en una experiencia editorial adaptable para móvil, tablet, escritorio y web.

## Funcionalidades

- Catálogo de Open Library con destacados, tendencias, recomendaciones editoriales y descubrimiento.
- Búsqueda por título, autor o tema, con debounce y paginación.
- Categorías funcionales que buscan datos reales.
- Detalle con portada, autoría, año, ediciones, ISBN y temas disponibles.
- Favoritos persistentes en el dispositivo mediante SharedPreferences.
- Modo claro y oscuro, navegación Material 3 y cuadrículas adaptables.
- Estados de carga, error, catálogo vacío y portadas ausentes.

## Tecnologías

- Flutter y Dart del canal stable instalado localmente.
- `flutter_bloc` para el estado de presentación.
- `http` para Open Library Search API.
- `shared_preferences` para favoritos locales, incluida la plataforma web.

## Arquitectura

```text
lib/
  data/
    datasources/       Open Library y almacenamiento local
    repositories/      Implementación del repositorio
  domain/
    entities/          Book
    repositories/      Contrato de catálogo
    use_cases/         Búsqueda y favoritos
  presentation/        Cubit, navegación, páginas y componentes
  main.dart            Composición e inyección de dependencias
```

Los widgets no solicitan datos directamente: la presentación invoca casos de uso, el repositorio coordina las fuentes de datos y el dominio depende de contratos.

## API

- Búsqueda: [Open Library Search API](https://openlibrary.org/search.json)
- Portadas: `https://covers.openlibrary.org/b/id/{COVER_ID}-L.jpg`

Los campos ausentes son opcionales y la interfaz usa placeholders.

## Ejecutar

```bash
flutter pub get
flutter run
```

Para Chrome: `flutter run -d chrome`

## Verificar

```bash
flutter analyze
flutter test
```

El proyecto se verificó con Flutter 3.47.5 (stable) y Dart 3.13.4. `flutter doctor` detectó que faltan los command-line tools y licencias de Android y que Visual Studio no está completo; Chrome está disponible para desarrollo web.
