# Flutter Books Clean BLoC

A Flutter application for discovering, searching, and consulting books through the Open Library API, built with a clean, maintainable architecture using BLoC/Cubit.

## 📱 Overview

Flutter Books Clean BLoC is a mobile application focused on book discovery and search. The project demonstrates how to structure a Flutter application using separation of concerns, repository-based data access, use cases, and reactive state management.

The application consumes the Open Library API and includes local persistence for favorite books.

## 🏗️ Architecture

The project follows a Clean Architecture-inspired structure:

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

The main application flow is:

```text
Presentation
     ↓
Cubit / BLoC
     ↓
Use Case
     ↓
Repository
     ↓
Remote Data Source
     ↓
Open Library API
```

This separation keeps UI, business logic, domain rules, and external data sources independent from each other.

## 🚀 Features

- Search for books through the Open Library API
- Browse book information
- Pagination for API results
- Favorite books
- Local persistence for favorites
- Reactive state management with Cubit/BLoC
- Repository Pattern
- Use Case layer
- Responsive interface
- Separation between presentation, domain, and data layers
- Unit and application-level tests

## 🧩 Technologies

| Technology | Usage |
|---|---|
| Flutter | Application framework |
| Dart | Programming language |
| flutter_bloc | State management |
| Cubit | Reactive application state |
| Open Library API | Book data |
| HTTP | REST API communication |
| SharedPreferences | Local persistence |
| Equatable | Value equality |
| Clean Architecture | Application organization |
| Repository Pattern | Data abstraction |

## 🔎 Book Search

The application communicates with the Open Library API to retrieve book information.

The search flow is handled through the application layers instead of making API calls directly from the UI:

```text
User Search
    ↓
Presentation
    ↓
Cubit
    ↓
Use Case
    ↓
Repository
    ↓
Remote Data Source
    ↓
Open Library API
```

This structure makes the API integration easier to test and maintain.

## ❤️ Favorites

Favorite books are persisted locally using `SharedPreferences`, allowing selected books to remain available between application sessions.

## 📄 Pagination

Search results are handled through pagination to avoid loading an unnecessarily large number of books at once.

This provides a more efficient experience when navigating through API results.

## 🧪 Testing

The project includes tests for application functionality and core components.

The architecture also makes individual layers easier to test because dependencies are separated through repositories and use cases.

## ⚙️ Installation

### 1. Clone the repository

```bash
git clone https://github.com/MiguelArbelaez0/FLUTTER_BOOKS_CLEAN_BLOC.git
cd FLUTTER_BOOKS_CLEAN_BLOC
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Run the application

```bash
flutter run
```

Make sure Flutter and Dart are correctly installed and configured on your development environment.

## 📂 Project Structure

The project is organized around the main responsibilities of the application:

- **Presentation:** screens, widgets and state management.
- **Domain:** entities, repository contracts and use cases.
- **Data:** API communication, models and repository implementations.
- **Core:** shared functionality and application utilities.

## 🎯 What This Project Demonstrates

This project demonstrates practical experience with:

- Flutter application development
- Dart
- BLoC/Cubit
- Clean Architecture principles
- Repository Pattern
- Use Case design
- REST API integration
- Local persistence
- Pagination
- State management
- Testing
- Separation of concerns

## 📌 Project Status

The project is a completed academic/personal development project created to practice production-oriented Flutter architecture and application development patterns.

## 👨‍💻 Author

**Miguel Arbeláez Vallejo**

Software Developer | Flutter / Dart | Full-Stack Development

- GitHub: https://github.com/MiguelArbelaez0
- LinkedIn: https://www.linkedin.com/in/miguel-arbelaez-v-57719542b/
