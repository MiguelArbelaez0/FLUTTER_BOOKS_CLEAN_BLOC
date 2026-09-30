# FLUTTER BOOKS CLEAN BLOC

Aplicación de biblioteca digital desarrollada con Flutter para descubrir, buscar y consultar libros del catálogo real de Open Library. El proyecto utiliza una separación inspirada en Clean Architecture, el patrón Repository, casos de uso y `flutter_bloc` mediante un `Cubit`. La composición de dependencias se realiza manualmente en `main.dart`.

## Características

- Inicio con secciones de libros destacados, en tendencia, recomendaciones editoriales y más para descubrir. Cada sección carga resultados reales mediante búsquedas en Open Library.
- Búsqueda por texto libre con debounce y resultados paginados.
- Categorías que inician una búsqueda en la API.
- Detalle con portada, título, autor, año de publicación, cantidad de ediciones, ISBN y temas cuando esos datos están disponibles.
- Añadir y quitar libros de favoritos desde las tarjetas y el detalle.
- Favoritos guardados localmente con `shared_preferences`.
- Mensajes de confirmación al cambiar favoritos, con opción para deshacer desde las tarjetas.
- Estados de carga, error y resultados vacíos.
- Interfaz adaptable, navegación inferior y temas claro y oscuro.
- Placeholders para libros sin portada o con metadatos ausentes.

Las búsquedas de las secciones de inicio son consultas editoriales al catálogo; la aplicación no afirma ofrecer recomendaciones personalizadas ni datos de tendencias en tiempo real.

## API

La aplicación consulta la [Open Library Search API](https://openlibrary.org/search.json) para buscar libros y obtener metadatos. Las solicitudes incluyen paginación (`page` y `limit`).

Las portadas se cargan desde Open Library Covers con el identificador de portada:

```text
https://covers.openlibrary.org/b/id/{COVER_ID}-L.jpg
```

Los campos del catálogo son opcionales. Cuando Open Library no proporciona un dato, la interfaz muestra un valor o placeholder alternativo.

## Arquitectura

El flujo principal es:

```text
Presentation → Domain → Data
```

- **Presentation:** aplicación, navegación, widgets y `LibraryCubit` con su estado de carga, resultados, favoritos y errores. No contiene llamadas HTTP.
- **Domain:** entidad `Book`, contrato `BookRepository` y casos de uso para buscar libros y gestionar favoritos.
- **Data:** acceso remoto a Open Library, acceso local a favoritos y la implementación de `BookRepository`.

`main.dart` crea las fuentes de datos, el repositorio y el `Cubit`, y los conecta con `BlocProvider`. El modelo JSON de libro está integrado en la entidad `Book`; el proyecto no tiene una carpeta independiente de modelos. Tampoco hay una carpeta `core/` ni clases de eventos BLoC separadas.

## Estructura actual

```text
lib/
├── data/
│   ├── datasources/
│   │   ├── book_local_data_source.dart
│   │   └── book_remote_data_source.dart
│   └── repositories/
│       └── book_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── book.dart
│   ├── repositories/
│   │   └── book_repository.dart
│   └── use_cases/
│       ├── manage_favorites.dart
│       └── search_books.dart
├── presentation/
│   ├── library_app.dart
│   └── library_cubit.dart
└── main.dart

test/
├── book_test.dart
└── library_cubit_test.dart
```

## Tecnologías

- Flutter 3.47.x, canal stable.
- Dart compatible con la versión de Flutter utilizada.
- `flutter_bloc` para el estado de presentación.
- `http` para las solicitudes REST a Open Library.
- `shared_preferences` para persistir favoritos localmente.
- `flutter_test` para pruebas de la entidad y del `LibraryCubit`.

La inyección de dependencias es manual; no se utiliza un paquete de DI. La persistencia usa SharedPreferences; no se utiliza Hive.

## Requisitos

- Flutter 3.47.x en el canal stable.
- Dart incluido con la versión de Flutter correspondiente.

## Instalación y ejecución

Clona el repositorio y entra en el directorio del proyecto:

```bash
git clone <URL_DEL_REPOSITORIO>
cd <DIRECTORIO_DEL_PROYECTO>
flutter pub get
flutter run
```

Para ejecutar en Chrome:

```bash
flutter run -d chrome
```

## Pruebas y análisis

Ejecuta las pruebas automatizadas:

```bash
flutter test
```

Ejecuta el análisis estático:

```bash
flutter analyze
```

Las pruebas actuales verifican el mapeo de campos presentes y ausentes en `Book`, la búsqueda paginada sin duplicados en el `LibraryCubit` y el cambio de favoritos.

## Diseño

La interfaz organiza el catálogo en secciones y tarjetas, con navegación entre inicio, búsqueda, favoritos y ajustes. La cuadrícula adapta el número de columnas al ancho disponible; el tema claro y el oscuro usan esquemas de color distintos.

## Valor para portafolio

El proyecto demuestra integración de Flutter y `flutter_bloc`, consumo de una API REST, separación por capas, uso de Repository y Use Cases, persistencia local, manejo de estados, interfaz responsive y pruebas automatizadas.
