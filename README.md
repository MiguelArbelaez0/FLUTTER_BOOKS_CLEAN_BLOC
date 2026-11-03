# Flutter Books Clean BLoC — Libris

> **Stack:** Flutter · Dart · Cubit · Open Library API · SharedPreferences
>
> **Funcionalidad:** búsqueda y descubrimiento de libros, favoritos locales y separación de datos, dominio y presentación.
>
> **Código principal:** `lib/domain/use_cases/`, `lib/presentation/library_cubit.dart`, `test/`.
>
> **Calidad:** pruebas unitarias y de widgets, análisis estático y compilaciones de desarrollo verificadas.

Aplicación móvil desarrollada con Flutter y Dart para descubrir, buscar y guardar libros mediante la API de Open Library, utilizando una estructura basada en Clean Architecture y gestión de estado con BLoC/Cubit.

## Funcionalidades

- Inicio con secciones de descubrimiento y catálogo paginado.
- Búsqueda por título, autor o tema, con espera de 450 ms al escribir.
- Categorías, resultados vacíos, indicadores de carga y reintentos.
- Detalle con autores, portada, primera publicación, ediciones, ISBN y temas disponibles.
- Favoritos con SharedPreferences y opción de deshacer desde el catálogo.
- Tema claro y oscuro durante la sesión.
- Portadas de respaldo cuando faltan imágenes o no pueden descargarse.

Los nombres de las secciones de inicio representan consultas de descubrimiento; no son rankings certificados ni recomendaciones personalizadas. No incluye cuentas, sincronización, lectura de libros ni descarga de contenido.

## Arquitectura

```text
lib/
  main.dart                         # Composición e inyección de dependencias
  domain/
    entities/book.dart
    repositories/book_repository.dart
    use_cases/                      # SearchBooks, GetFavorites, ToggleFavorite
  data/
    models/book_model.dart
    datasources/                    # HTTP y almacenamiento local
    repositories/book_repository_impl.dart
  presentation/
    library_cubit.dart              # LibraryState y LibraryCubit
    library_app.dart                # Aplicación, navegación y widgets
```

La presentación depende del dominio; la implementación de los repositorios y los plugins permanecen en data. `main.dart` conecta las capas. El dominio no importa Flutter ni plugins. Se usa Cubit de `flutter_bloc`, sin Equatable ni un contenedor adicional de inyección.

El Cubit descarta respuestas obsoletas y evita emisiones después del cierre. Las operaciones de escritura de favoritos se serializan en el repositorio. El propietario del cliente HTTP lo cierra al desmontar la aplicación. La lista de búsqueda usa un SliverGrid con construcción diferida.

## Requisitos y ejecución

- Flutter con Dart compatible con `sdk: ^3.10.7`.
- Android SDK y JDK compatible con Gradle 8.14 (por ejemplo JDK 17).
- Para iOS/macOS se necesita macOS con Xcode y herramientas de la plataforma.

```bash
git clone https://github.com/MiguelArbelaez0/FLUTTER_BOOKS_CLEAN_BLOC.git
cd FLUTTER_BOOKS_CLEAN_BLOC
flutter pub get
flutter devices
flutter run -d <device-id>
```

Para ejecutar en navegador: `flutter run -d chrome`.

```bash
dart format .
flutter analyze
flutter test
flutter build apk --debug
flutter build web
```

El APK debug, si la compilación termina correctamente, se genera en `build/app/outputs/flutter-apk/app-debug.apk`.

### JDK aislado para Android en Windows

Si Android Studio aporta un Java incompatible, el script `scripts/flutter-local.ps1` permite usar un JDK 17 portátil sin cambiar la configuración global. Descarga el ZIP para Windows x64 desde [Eclipse Temurin](https://adoptium.net/temurin/releases/?version=17), verifica su SHA-256 y extráelo bajo `.tooling/jdk17/`, o indica su ruta explícitamente:

```powershell
./scripts/flutter-local.ps1 -JdkPath 'C:\ruta\jdk-17' -FlutterArguments @('doctor', '-v')
./scripts/flutter-local.ps1 -JdkPath 'C:\ruta\jdk-17' -FlutterArguments @('build', 'apk', '--debug')
```

Con el JDK extraído en `.tooling/jdk17/` se puede omitir `-JdkPath`. El script aísla los ajustes Flutter en `.tooling/flutter-config`, establece Java solo para el proceso y restaura su entorno al terminar. `.tooling/` contiene herramientas y registros locales excluidos de Git. No incluye ni descarga automáticamente un JDK.

## API, almacenamiento y seguridad

Se consulta `https://openlibrary.org/search.json` mediante `http`, con parámetros codificados, paginación de 20 libros y timeout de 15 segundos. Las portadas usan HTTPS en `covers.openlibrary.org`. Los errores HTTP y las respuestas con formato inesperado muestran un estado de error; no hay reintentos automáticos ilimitados.

Los favoritos usan la clave existente `bookish_favorites_v1`. Se filtran entradas inválidas y duplicadas al leer, sin borrar automáticamente el contenido almacenado. Se informa al usuario si falla una escritura. SharedPreferences es almacenamiento local sin cifrado y no garantiza durabilidad para datos críticos; no se guardan credenciales. Véase la [documentación del plugin](https://pub.dev/packages/shared_preferences).

Android declara INTERNET y bloquea tráfico HTTP sin cifrar. macOS habilita conexiones salientes en ambos archivos de entitlements, conforme a la [configuración de red de Flutter](https://docs.flutter.dev/data-and-backend/networking). No se requieren claves de API ni permisos de cámara, ubicación o almacenamiento externo.

## Pruebas y estado de validación

Las pruebas unitarias y de widgets cubren modelos, respuestas HTTP inválidas, timeout, persistencia, duplicados, concurrencia, respuestas obsoletas, cierre del Cubit, errores y reintentos, búsqueda vacía, cancelación del debounce y navegación a detalles.

Se han ejecutado el análisis estático sin observaciones, 23 pruebas automatizadas satisfactorias y compilaciones de desarrollo para Android y web. La compilación Android requiere un JDK compatible y presenta advertencias de compatibilidad futura de Gradle, AGP y Kotlin. No se ha probado en dispositivos físicos.

Las pruebas usan repositorios y clientes HTTP controlados; no certifican disponibilidad real de Open Library ni funcionamiento en dispositivos físicos.

## Límites conocidos

- Favoritos disponibles sin conexión; búsqueda y portadas requieren red.
- Inicio y búsqueda comparten el catálogo de resultados del Cubit.
- El fin de paginación se estima por tamaño de página y registros nuevos; no se expone el total del servidor.
- La carga de inicio agrupa cuatro consultas: si falla una, se muestra error y se permite reintentar.
- El tema no se persiste entre sesiones.
- Los identificadores de aplicación conservan los valores originales `com.example` para evitar cambios de identidad y pérdida de acceso a datos existentes.
- La configuración Android release heredada usa firma debug. Debe configurarse una firma privada antes de distribuir; no está preparado para publicación en tiendas.

## Autor

**Miguel Arbeláez Vallejo**

Flutter & Dart · Full-Stack · Backend · AI/Data

- [GitHub](https://github.com/MiguelArbelaez0)
- [LinkedIn](https://www.linkedin.com/in/miguel-arbelaez-v-57719542b/)
