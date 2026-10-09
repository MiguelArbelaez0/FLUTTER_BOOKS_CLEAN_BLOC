# Flutter Books Clean BLoC

Aplicación móvil desarrollada con Flutter y Dart para descubrir, buscar y guardar libros mediante la API de Open Library, utilizando una estructura basada en Clean Architecture y gestión de estado con BLoC/Cubit.

## 📱 Descripción general

Flutter Books Clean BLoC es una aplicación móvil enfocada en el descubrimiento y búsqueda de libros.

El proyecto separa las responsabilidades entre presentación, dominio y datos, utilizando repositorios, casos de uso y gestión reactiva del estado.

La aplicación consume la API de Open Library e incluye persistencia local para los libros favoritos.

## 🏗️ Arquitectura

```text
lib/
├── core/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
└── presentation/
    ├── cubit/
    ├── pages/
    └── widgets/
```

Flujo principal:

```text
Presentación
     ↓
Cubit / BLoC
     ↓
Caso de uso
     ↓
Repositorio
     ↓
Fuente de datos remota
     ↓
API de Open Library
```

Esta separación mantiene independientes la interfaz, la lógica de negocio, las reglas de dominio y las fuentes externas de datos.

## 🚀 Funcionalidades

- Buscar libros mediante la API de Open Library.
- Consultar información de libros.
- Paginación de resultados.
- Marcar libros como favoritos.
- Persistencia local de favoritos.
- Gestión reactiva del estado con Cubit/BLoC.
- Repository Pattern.
- Capa de casos de uso.
- Interfaz adaptable.
- Separación entre presentación, dominio y datos.
- Pruebas unitarias y de aplicación.

## 🧩 Tecnologías

| Tecnología | Uso |
|---|---|
| Flutter | Desarrollo de la aplicación |
| Dart | Lenguaje de programación |
| flutter_bloc | Gestión de estado |
| Cubit | Gestión reactiva del estado |
| Open Library API | Datos de libros |
| HTTP | Comunicación con la API REST |
| SharedPreferences | Persistencia local |
| Clean Architecture | Organización de la aplicación |
| Repository Pattern | Abstracción del acceso a datos |

## 🔎 Búsqueda de libros

La aplicación se comunica con Open Library para obtener información de libros.

La búsqueda atraviesa las capas de la aplicación en lugar de realizar llamadas directamente desde la interfaz:

```text
Búsqueda del usuario
    ↓
Presentación
    ↓
Cubit
    ↓
Caso de uso
    ↓
Repositorio
    ↓
Fuente de datos remota
    ↓
API de Open Library
```

Esto facilita las pruebas y el mantenimiento de la integración.

## ❤️ Favoritos

Los libros favoritos se almacenan localmente mediante `SharedPreferences`, permitiendo conservarlos entre sesiones.

## 📄 Paginación

Los resultados se manejan mediante paginación para evitar cargar una cantidad innecesaria de libros en una sola consulta.

## 🧪 Pruebas

El proyecto incluye pruebas para funcionalidades y componentes principales.

La separación mediante repositorios y casos de uso facilita probar las capas de manera independiente.

## ⚙️ Instalación

### 1. Clonar el repositorio

```bash
git clone https://github.com/MiguelArbelaez0/FLUTTER_BOOKS_CLEAN_BLOC.git
cd FLUTTER_BOOKS_CLEAN_BLOC
```

### 2. Instalar dependencias

```bash
flutter pub get
```

### 3. Ejecutar

```bash
flutter run
```

Asegúrate de tener Flutter y Dart instalados y configurados correctamente.

## 📂 Estructura de responsabilidades

- **Presentación:** pantallas, widgets y gestión de estado.
- **Dominio:** entidades, contratos de repositorio y casos de uso.
- **Datos:** comunicación con la API, modelos e implementaciones de repositorios.
- **Core:** funcionalidades compartidas y utilidades.

## 🎯 Qué demuestra este proyecto

- Desarrollo de aplicaciones con Flutter.
- Dart.
- BLoC/Cubit.
- Principios de Clean Architecture.
- Repository Pattern.
- Diseño mediante casos de uso.
- Integración con APIs REST.
- Persistencia local.
- Paginación.
- Gestión de estado.
- Pruebas.
- Separación de responsabilidades.

## 📌 Estado del proyecto

**Proyecto de portafolio terminado.**

Desarrollado para demostrar arquitectura mantenible en Flutter, integración con APIs REST, persistencia local, paginación y gestión de estado orientada a pruebas.

## 👨‍💻 Autor

**Miguel Arbeláez Vallejo**

Flutter & Dart · Full-Stack · Backend · AI/Data

- GitHub: https://github.com/MiguelArbelaez0
- LinkedIn: https://www.linkedin.com/in/miguel-arbelaez-v-57719542b/
