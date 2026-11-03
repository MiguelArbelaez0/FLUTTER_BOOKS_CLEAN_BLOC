# Auditoría técnica — 2 de noviembre de 2026

## Alcance y método

Revisión de todos los archivos Dart en lib/ y test/, pubspec y lockfile, reglas del analizador, composición de dependencias, manifiestos y configuración Gradle de Android, configuración Xcode/plist/entitlements de iOS y macOS, runners y CMake de Windows/Linux, archivos web, exclusiones Git y nombres de archivos históricos relacionados con secretos. Los recursos binarios de iconos se inventariaron; no se realizó una revisión visual de cada icono. No se ejecutó un escáner especializado de todo el historial Git ni una auditoría de vulnerabilidades de dependencias.

## Hallazgos y correcciones

| Prioridad | Defecto confirmado | Corrección |
|---|---|---|
| Alta | Android release sin permiso INTERNET; macOS sin permiso de cliente de red | Manifiesto principal y ambos entitlements corregidos |
| Alta | Inicio podía sobrescribir búsquedas recientes | Identificador de solicitud compartido entre inicio y búsqueda |
| Alta | Operaciones asíncronas podían emitir tras cerrar el Cubit | Comprobación de cierre antes de emitir |
| Alta | Favoritos solo se cargaban tras éxito de la API | Lectura local previa a las consultas remotas |
| Alta | Fallos al guardar favoritos se propagaban sin aviso y podían mostrar éxito falso | Resultado explícito, mensaje separado y comprobación del booleano de escritura |
| Media | Escrituras concurrentes de favoritos podían perder consistencia | Cola serial que se recupera de errores |
| Media | JSON local no-lista o campos de tipo incorrecto causaban errores | Lectura tolerante, valores seguros y filtrado de IDs vacíos/duplicados |
| Media | Respuesta API sin docs se interpretaba como catálogo vacío | Validación del contenedor y de docs |
| Media | Limpiar búsqueda conservaba paginación y solicitudes pendientes | Reinicio de página/flags y cancelación de debounce |
| Media | Resultados de consulta anterior se mostraban bajo la nueva consulta | Limpieza al iniciar búsqueda de reemplazo |
| Media | Fallo de primera página permitía cargar página 2 | Deshabilitar paginación tras fallo inicial |
| Media | Reintento de página adicional reiniciaba el catálogo | Reintentar sin perder resultados previos |
| Media | Etiquetas Hero repetidas entre secciones y pestañas | Etiqueta por tile y HeroMode según pestaña activa |
| Media | Grid de búsqueda anidado construía resultados acumulados | SliverGrid con delegado diferido |
| Media | Cliente HTTP no tenía propietario que liberara recursos | RepositoryProvider con creación inmediata y dispose |
| Baja | Nombre iOS refería a otro proyecto | Nombre visible Libris |
| Baja | Fuente Cupertino referida por el tema de Flutter | Dependencia conservada tras verificar advertencia de build sin ella |
| Baja | README describía carpetas y Equatable inexistentes | Documentación ajustada al código real |

Se conservaron contratos de dominio, funcionalidades y la clave de persistencia. No se añadieron paquetes de producción. El dominio mantiene la dirección de dependencias correcta; no era necesario reorganizar toda la interfaz en múltiples carpetas. Se conservaron IDs de plataforma para no alterar la identidad de instalaciones existentes.

## Seguridad

No se detectaron secretos en la inspección por patrones de los archivos actuales. Los endpoints son HTTPS y las imágenes se construyen desde identificadores, sin ejecutar URLs suministradas por la API. Android bloquea tráfico sin cifrar. No se añadieron permisos sensibles. Se agregaron exclusiones para archivos de entorno y certificados privados. Esto no demuestra ausencia absoluta de secretos en todo el historial.

Pendiente para distribución: firma release privada (la plantilla conserva debug), identificadores definitivos, iconos propios y validación en dispositivos. SharedPreferences no cifra ni garantiza durabilidad de datos críticos. Las consultas de búsqueda se envían al servicio externo. No hay autenticación ni secretos que migrar a almacenamiento seguro.

## Validación del entorno

Windows; Flutter 3.47.5 estable; Dart 3.13.4. La ruta del SDK conserva un nombre anterior, pero las versiones son las reportadas por flutter --version.

- `flutter pub get`: correcto; se conservan las versiones del lockfile.
- `dart format .`: ejecutado.
- `flutter analyze`: correcto, sin observaciones tras corregir seis lints introducidos durante el trabajo.
- `flutter test`: 23 pruebas correctas en la validación final.
- `flutter build apk --debug`: falló por Java 25.0.3 incompatible con Gradle 8.14. No se generó un APK validado. Flutter doctor también informa cmdline-tools ausente y licencias Android sin verificar.
- `flutter build web`: correcto; compilación JavaScript y comprobación de compilación Wasm. No se realizó validación interactiva en navegador.

No se cambió la configuración global de Java ni se aceptaron licencias automáticamente. No se actualizó Gradle/AGP solo para adaptar el proyecto a un JDK local incompatible. Para repetir Android, instalar/configurar un JDK compatible (por ejemplo 17), completar Android SDK y licencias, y repetir el comando. Los cambios automáticos de gradle.properties del intento de compilación se descartaron por no ser necesarios para las correcciones.

No se ejecutaron pruebas en dispositivo físico ni builds iOS/macOS/Linux. No se afirma compatibilidad verificada en esas plataformas. Las pruebas de red son deterministas con MockClient; no equivalen a una prueba end-to-end con el catálogo real. No se midieron FPS, consumo de memoria ni accesibilidad con lector de pantalla.

## Archivos afectados

- `lib/main.dart`: propiedad y cierre de cliente HTTP.
- `lib/data/datasources/`: validación remota y persistencia local.
- `lib/data/models/book_model.dart`: normalización de campos.
- `lib/data/repositories/book_repository_impl.dart`: escrituras serializadas.
- `lib/presentation/`: estados, concurrencia, búsqueda, favoritos, navegación y grid.
- `test/book_test.dart`, `test/data_sources_test.dart`, `test/regression_test.dart`: regresiones y casos límite; pruebas originales conservadas.
- AndroidManifest principal, Info.plist iOS y entitlements macOS: configuración.
- `.gitignore`, `pubspec.yaml`, `README.md` y este informe.

El commit local en audit/flutter-books permite revisar el diff completo. No se realizó push ni se modificó main.
