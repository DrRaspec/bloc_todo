# Bloc Todo

A local-first Todo application built with Flutter to explore practical state
management, dependency injection, routing, persistence, local notifications,
and feature-based project organization.

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
- Create-todo form with validation and asynchronous submission states
- Todo priority and due-date selection
- Reminder preset bottom sheet
- Timezone-aware local notification service
- Immediate and scheduled local notifications
- Android and iOS notification permission handling
- Android exact-alarm support with an inexact fallback
- Pending-notification lookup and cancellation
- Custom Android and iOS launcher icon
- SQLite FFI support for macOS, Windows, and Linux

The repository and storage layers already support creating, reading, updating,
completing, uncompleting, and deleting todos. Creating a todo and selecting its
due date are connected to local persistence. Reminder selection is designed,
and the notification service is ready, but the selected reminder still needs
to be persisted and passed to `scheduleTodoReminder()`.

Some other UI actions, including search, filtering, editing, deletion, and
completion toggling, are still under development.

## Tech Stack

| Technology | Purpose |
| --- | --- |
| Flutter | Cross-platform user interface |
| Cubit / Bloc | State management |
| GetIt | Dependency injection and service location |
| GoRouter | Application navigation |
| Sqflite | Local SQLite persistence |
| Sqflite Common FFI | Desktop SQLite support |
| Flutter Local Notifications | Immediate and scheduled reminders |
| Flutter Timezone / Timezone | Device-aware notification scheduling |
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

Local reminder scheduling follows a separate service flow:

```text
Reminder UI
 │
 ▼
NotificationService
 │
 ├── Permission handling
 ├── Device timezone conversion
 ├── Android notification channel
 └── Scheduled local notification
```

### Presentation layer

The presentation layer contains pages, reusable widgets, Cubits, and states.
`HomePage` reacts to `TodoState`, while `HomeView` and its smaller widgets are
responsible only for rendering the interface. `CreateTodoCubit` independently
manages todo submission so creating a task does not replace or complicate the
list state.

### Domain layer

The domain layer defines the `TodoRepository` contract. The Cubit depends on
this abstraction instead of depending directly on SQLite.

### Data layer

`TodoRepositoryImpl` implements the domain contract and delegates database
operations to `LocalStorageService`.

### Core services

`LocalStorageService` owns the SQLite connection and CRUD operations.
`NotificationService` owns notification initialization, permissions, timezone
configuration, Android channels, scheduling, and cancellation.

### Dependency injection

Dependencies are configured before the application starts:

- `LocalStorageService` is registered as a singleton.
- `NotificationService` is initialized and registered as a singleton.
- `TodoRepository` is registered as a lazy singleton.
- `TodoCubit` is registered as a factory so each provider receives a fresh
  Cubit instance.
- `CreateTodoCubit` is registered as a factory for the create route.

The home route creates and provides `TodoCubit`, then immediately loads the
first page of todos. The create route provides its own `CreateTodoCubit`.

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
│   ├── services/
│   │   ├── local_storage_service.dart
│   │   └── notification_service.dart
│   └── utils/
│       ├── app_logger.dart
│       └── date_time_helper.dart
├── features/
│   ├── splash/
│   │   └── presentation/pages/
│   └── todos/
│       ├── data/repositories/
│       ├── domain/repositories/
│       └── presentation/
│           ├── cubit/
│           ├── pages/
│           └── widgets/
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

## Create Todo Flow

The create screen uses a separate state flow:

```text
initial → submitting → success
                     ↘ failure
```

While submitting, the form is disabled and the save button shows progress. A
successful SQLite insert returns the created todo to the home route, which then
reloads the list. A failure keeps the form open and displays an error message.

## Local Notifications

`NotificationService` currently supports:

- Requesting Android, iOS, and macOS notification permissions
- Creating the Android `Todo Reminders` notification channel
- Showing an immediate notification
- Scheduling a timezone-aware notification
- Using exact alarms on Android when permitted
- Falling back to inexact scheduling when exact alarms are unavailable
- Listing pending notification requests
- Cancelling one notification or all notifications
- Receiving notification-tap payloads

The create screen currently offers these reminder choices:

- On the due date
- 10 minutes before
- 1 hour before
- 1 day before
- Custom date and time
- No reminder

The reminder UI and notification infrastructure are present, but connecting a
selected option to model persistence and scheduling remains a planned step.

## Getting Started

### Prerequisites

- Flutter SDK compatible with Dart `^3.12.1`
- JDK 21 for Android development
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

When reminder scheduling is connected, the operating system may ask for
notification permission on the first scheduled reminder. Android may also
request exact-alarm access. If exact access is not granted, the service uses
inexact scheduling.

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
- Saving an optional due date
- Marking a todo complete or incomplete
- Deleting one or multiple todos
- Deleting all todos

The database is initialized before `runApp`, ensuring the storage service is
ready before the first screen requests data.

## Roadmap

- Persist the selected reminder date and notification ID
- Connect reminder choices to `scheduleTodoReminder()`
- Reschedule or cancel reminders when todos change
- Navigate to todo details when a notification is tapped
- Add an edit todo screen
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
- Scheduling timezone-aware local notifications
- Handling notification and exact-alarm permissions
- Supporting mobile and desktop database environments

## License

This is a learning project. Add a license file before distributing or reusing
it as a public package.
