# Serene Slumber — Flutter MVVM + BLoC Project Structure with Routes

This structure is for a **small mobile-only Sleep Tracker Manual app** using Flutter, MVVM style, BLoC as the ViewModel, named routes with `onGenerateRoute`, and local storage only.

---

# Why Routes Are Different with BLoC

With GetX you may use:

```txt
Route
 ↓
Binding
 ↓
Controller
 ↓
Page
```

With BLoC, replace bindings with providers:

```txt
Route
 ↓
BlocProvider / MultiBlocProvider
 ↓
Page
```

For this Sleep Tracker app, the best setup is **app-level providers** so `SleepBloc` is shared by Home, Add Record, History, Stats, and Profile.

```txt
AppBlocProviders
 ↓
RepositoryProvider
 ↓
BlocProvider
 ↓
MaterialApp
 ↓
onGenerateRoute
 ↓
Page
```

---

# Flutter MVVM + BLoC Project Structure

```txt
lib/
├── main.dart
│
├── app/
│   ├── app.dart
│   ├── di/
│   │   └── app_bloc_providers.dart
│   │
│   ├── routes/
│   │   ├── app_routes.dart
│   │   ├── app_pages.dart
│   │   ├── app_router.dart
│   │   └── route_transition.dart
│   │
│   └── theme/
│       ├── app_colors.dart
│       ├── app_text_theme.dart
│       ├── app_theme.dart
│       ├── app_extensions.dart
│       └── component_themes.dart
│
├── core/
│   ├── constants/
│   │   └── app_constants.dart
│   ├── storage/
│   │   └── local_storage_service.dart
│   ├── utils/
│   │   ├── date_time_helper.dart
│   │   └── duration_helper.dart
│   ├── widgets/
│   │   ├── app_card.dart
│   │   ├── app_empty_state.dart
│   │   └── app_primary_button.dart
│   └── exceptions/
│       └── app_exception.dart
│
├── features/
│   └── sleep/
│       ├── data/
│       │   ├── datasources/
│       │   │   └── sleep_local_datasource.dart
│       │   ├── models/
│       │   │   └── sleep_record_model.dart
│       │   └── repositories/
│       │       └── sleep_repository_impl.dart
│       │
│       ├── domain/
│       │   ├── entities/
│       │   │   └── sleep_record.dart
│       │   ├── repositories/
│       │   │   └── sleep_repository.dart
│       │   └── usecases/
│       │       ├── add_sleep_record.dart
│       │       ├── get_sleep_records.dart
│       │       ├── update_sleep_record.dart
│       │       ├── delete_sleep_record.dart
│       │       └── get_sleep_stats.dart
│       │
│       └── presentation/
│           ├── bloc/
│           │   ├── sleep_bloc.dart
│           │   ├── sleep_event.dart
│           │   └── sleep_state.dart
│           ├── pages/
│           │   ├── sleep_shell_page.dart
│           │   ├── sleep_home_page.dart
│           │   ├── add_sleep_record_page.dart
│           │   ├── sleep_history_page.dart
│           │   ├── sleep_stats_page.dart
│           │   └── sleep_profile_page.dart
│           └── widgets/
│               ├── sleep_summary_card.dart
│               ├── weekly_sleep_chart.dart
│               ├── sleep_record_card.dart
│               ├── mood_chip.dart
│               └── sleep_time_picker_card.dart
│
├── shared/
│   ├── enums/
│   │   ├── sleep_mood.dart
│   │   └── sleep_quality.dart
│   ├── widgets/
│   ├── mixins/
│   └── models/
│
└── l10n/
    ├── app_en.arb
    └── app_km.arb
```

---

# MVVM Flow

```txt
View / Page
 ↓
BLoC / Cubit as ViewModel
 ↓
UseCase
 ↓
Repository Interface
 ↓
Repository Implementation
 ↓
Local Datasource
 ↓
Hive / SharedPreferences
```

Example:

```txt
AddSleepRecordPage
 ↓ user taps save
SleepBloc.add(SleepRecordAdded(record))
 ↓
SleepRepository.addRecord(record)
 ↓
SleepLocalDatasource.save(record)
 ↓
Bloc emits SleepLoaded(records)
 ↓
UI rebuilds
```

---

# Recommended Packages

```yaml
dependencies:
  flutter:
    sdk: flutter

  flutter_bloc: ^9.1.1
  equatable: ^2.0.7
  intl: ^0.20.2
  uuid: ^4.5.1

  hive: ^2.2.3
  hive_flutter: ^1.1.0

  fl_chart: ^1.0.0
```

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter

  flutter_lints: ^6.0.0
```

---

# Routes

## `app_routes.dart`

```dart
class AppRoutes {
  AppRoutes._();

  static const String home = '/';
  static const String addSleepRecord = '/add-sleep-record';
  static const String history = '/history';
  static const String stats = '/stats';
  static const String profile = '/profile';
}
```

## `app_pages.dart`

```dart
class AppPage {
  const AppPage({required this.name, required this.builder});

  final String name;
  final WidgetBuilder builder;
}

class AppPages {
  AppPages._();

  static final List<AppPage> pages = [
    AppPage(name: AppRoutes.home, builder: (_) => const SleepHomePage()),
    AppPage(name: AppRoutes.addSleepRecord, builder: (_) => const AddSleepRecordPage()),
    AppPage(name: AppRoutes.history, builder: (_) => const SleepHistoryPage()),
    AppPage(name: AppRoutes.stats, builder: (_) => const SleepStatsPage()),
    AppPage(name: AppRoutes.profile, builder: (_) => const SleepProfilePage()),
  ];
}
```

## `app_router.dart`

```dart
class AppRouter {
  AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final builder = AppPages.findBuilder(settings.name);

    if (builder == null) {
      return MaterialPageRoute(builder: (_) => const SleepHomePage());
    }

    final child = Builder(builder: builder);

    if (settings.name == AppRoutes.addSleepRecord) {
      return AppRouteTransition.slideUp(settings: settings, child: child);
    }

    return MaterialPageRoute(settings: settings, builder: (_) => child);
  }
}
```

---

# App-Level BLoC Providers

## `app_bloc_providers.dart`

```dart
class AppBlocProviders extends StatelessWidget {
  const AppBlocProviders({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider<SleepRepository>(
      create: (_) => SleepRepositoryImpl(
        localDatasource: SleepLocalDatasource(),
      ),
      child: BlocProvider<SleepBloc>(
        create: (context) => SleepBloc(
          repository: context.read<SleepRepository>(),
        )..add(const SleepStarted()),
        child: child,
      ),
    );
  }
}
```

---

# App Setup

## `app.dart`

```dart
class SereneSlumberApp extends StatelessWidget {
  const SereneSlumberApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBlocProviders(
      child: MaterialApp(
        title: 'Serene Slumber',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        initialRoute: AppRoutes.home,
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }
}
```

---

# Navigation Usage

```dart
Navigator.pushNamed(context, AppRoutes.addSleepRecord);
Navigator.pushNamed(context, AppRoutes.history);
Navigator.pushReplacementNamed(context, AppRoutes.home);
Navigator.pop(context);
```

---

# Naming Convention

| Type | Example |
|---|---|
| Route constants | `app_routes.dart` |
| Route generator | `app_router.dart` |
| Route pages list | `app_pages.dart` |
| View/Page | `sleep_home_page.dart` |
| ViewModel | `sleep_bloc.dart` |
| Event | `sleep_event.dart` |
| State | `sleep_state.dart` |
| UseCase | `add_sleep_record.dart` |
| Repository | `sleep_repository.dart` |
| Repository Impl | `sleep_repository_impl.dart` |
| Datasource | `sleep_local_datasource.dart` |
| Model | `sleep_record_model.dart` |
| Entity | `sleep_record.dart` |
| Widget | `sleep_summary_card.dart` |

---

# Best Setup for This App

Use this routing style:

```txt
MaterialApp
 ↓
onGenerateRoute
 ↓
AppRouter
 ↓
Named pages
```

Use this provider style:

```txt
AppBlocProviders
 ↓
RepositoryProvider
 ↓
BlocProvider
 ↓
MaterialApp
```

This keeps the app clean, beginner-friendly, and good for BLoC.
