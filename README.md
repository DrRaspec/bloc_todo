# Bloc Todo

A local-first Todo application built with Flutter to explore practical state
management, dependency injection, routing, persistence, and feature-based
project organization.

The project is intentionally more than a basic list demo. It separates the UI,
business rules, repository contract, and SQLite implementation so each layer
can evolve without tightly coupling the rest of the application.

## Current Features

- Splash screen and declarative navigation with `go_router`
- Todo loading through `TodoCubit`
- Loading, empty, loaded, and error UI states
- Local SQLite storage
- Paginated todo retrieval with infinite-scroll detection
- Dependency injection with `get_it`
- Loading shimmer placeholders
- Responsive sliver-based home screen
- Todo priority, completion status, and creation date display
- SQLite FFI support for macOS, Windows, and Linux

The repository and storage layers already support creating, reading, updating,
completing, uncompleting, and deleting todos. Some corresponding UI actions,
including add, search, filter, edit, and completion toggling, are still under
development.

## Tech Stack

| Technology | Purpose |
| --- | --- |
| Flutter | Cross-platform user interface |
| Cubit / Bloc | State management |
| GetIt | Dependency injection and service location |
| GoRouter | Application navigation |
| Sqflite | Local SQLite persistence |
| Sqflite Common FFI | Desktop SQLite support |
| Intl | Date and time formatting |
| Lottie | Animation support |

## Architecture

The application follows a feature-first structure inspired by clean
architecture:

```text
UI
 │
 ▼
TodoCubit
 │
 ▼
TodoRepository
 │
 ▼
TodoRepositoryImpl
 │
 ▼
LocalStorageService
 │
 ▼
SQLite
```

### Presentation layer

The presentation layer contains pages, reusable widgets, Cubits, and states.
`HomePage` reacts to `TodoState`, while `HomeView` and its smaller widgets are
responsible only for rendering the interface.

### Domain layer

The domain layer defines the `TodoRepository` contract. The Cubit depends on
this abstraction instead of depending directly on SQLite.

### Data layer

`TodoRepositoryImpl` implements the domain contract and delegates database
operations to `LocalStorageService`.

### Dependency injection

Dependencies are configured before the application starts:

- `LocalStorageService` is registered as a singleton.
- `TodoRepository` is registered as a lazy singleton.
- `TodoCubit` is registered as a factory so each provider receives a fresh
  Cubit instance.

The home route creates and provides `TodoCubit`, then immediately loads the
first page of todos.

## Project Structure

```text
lib/
├── app/
│   ├── app.dart
│   ├── di/
│   │   └── injection.dart
│   └── routes/
│       ├── app_router.dart
│       └── app_routes.dart
├── core/
│   ├── storage/
│   │   └── local_storage_service.dart
│   └── utils/
│       └── date_time_helper.dart
├── features/
│   ├── home/
│   │   ├── data/repositories/
│   │   ├── domain/repositories/
│   │   └── presentation/
│   │       ├── cubit/
│   │       ├── pages/
│   │       └── widgets/
│   └── splash/
│       └── presentation/pages/
├── shared/
│   ├── enums/
│   └── models/
└── main.dart
```

## Todo State Flow

When the home route opens, it creates `TodoCubit` and calls `loadTodos()`.

The Cubit can emit:

- `TodoInitial` before loading begins
- `TodoLoading` while reading from SQLite
- `TodoEmpty` when no records are available
- `TodoLoaded` when todos are returned
- `TodoError` when an operation fails

The first database query loads up to 20 records. When the user scrolls near the
bottom of the list, `loadMoreTodos()` requests the next page and appends it to
the existing state.

## Getting Started

### Prerequisites

- Flutter SDK compatible with Dart `^3.12.1`
- A configured Android emulator, iOS simulator, desktop target, or physical
  device

Confirm your Flutter installation:

```bash
flutter doctor
```

### Installation

Clone the repository and enter the project:

```bash
git clone <repository-url>
cd bloc_todo
```

Install dependencies:

```bash
flutter pub get
```

Run the application:

```bash
flutter run
```

To select a specific device:

```bash
flutter devices
flutter run -d <device-id>
```

## Development Commands

Format the source code:

```bash
dart format lib
```

Run static analysis:

```bash
flutter analyze
```

Run tests:

```bash
flutter test
```

Regenerate Flutter asset references when assets change:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Database

The app stores data in a local SQLite database named `todo.db`.

The storage service currently provides operations for:

- Inserting a todo
- Retrieving one todo by ID
- Retrieving paginated todos
- Updating a todo
- Marking a todo complete or incomplete
- Deleting one or multiple todos
- Deleting all todos

The database is initialized before `runApp`, ensuring the storage service is
ready before the first screen requests data.

## Roadmap

- Add and edit todo screens
- Connect checkbox completion actions
- Implement search
- Implement All, Active, and Done filters
- Display live task and completion counts
- Add delete confirmation and bulk actions
- Improve error handling and retry states
- Add Cubit, repository, storage, and widget tests
- Add light and dark themes

## Learning Goals

This project is primarily a place to practice:

- Structuring a Flutter application by feature
- Keeping widgets small and focused
- Managing asynchronous UI states with Cubit
- Providing route-scoped dependencies
- Hiding persistence details behind repository abstractions
- Implementing local pagination
- Supporting mobile and desktop database environments

## License

This is a learning project. Add a license file before distributing or reusing
it as a public package.
