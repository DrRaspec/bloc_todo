class AppRoutes {
  static const String splash = '/';
  static const String home = '/home';

  // Child routes under /home
  static const String createTodo = 'todos/create';
  static const String todoDetail = 'todos/:id';
  static const String editTodo = 'todos/:id/edit';

  static const String createTodoPath = '/home/todos/create';
  static String todoDetailPath(int id) => '/home/todos/$id';
  static String editTodoPath(int id) => '/home/todos/$id/edit';
}
