class AppRoutes {
  static const String splash = '/';
  static const String home = '/home';
  static const String createTodo = '/todos/create';
  static const String todoDetail = '/todos/:id';

  static String todoDetailPath(int id) => '/todos/$id';
}
