import 'package:admin_app/providers/auth_provider.dart';
import 'package:admin_app/screens/login/login_screen.dart';
import 'package:admin_app/screens/schools/schools_list_screen.dart';
import 'package:admin_app/screens/students/students_list_screen.dart';
import 'package:admin_app/screens/teachers/teachers_list_screen.dart';
import 'package:go_router/go_router.dart';

abstract class Screens {
  static const home = teachersListScreen;

  static const login = LoginScreen.route;
  static const schoolsListScreen = SchoolsListScreen.route;
  static const teachersListScreen = TeachersListScreen.route;
  static const studentsListScreen = StudentsListScreen.route;
}

final router = GoRouter(
  redirect: (context, state) {
    if (AuthProvider.of(context, listen: false).isSignedIn()) {
      return null;
    }
    return Screens.login;
  },
  routes: [
    GoRoute(path: '/', redirect: (context, state) => Screens.home),
    GoRoute(
      path: Screens.login,
      name: Screens.login,
      builder: (context, state) => const LoginScreen(),
      redirect:
          (context, state) =>
              AuthProvider.of(context, listen: false).isSignedIn() ? '/' : null,
    ),
    GoRoute(
      path: Screens.schoolsListScreen,
      name: Screens.schoolsListScreen,
      builder: (context, state) => const SchoolsListScreen(),
    ),
    GoRoute(
      path: Screens.teachersListScreen,
      name: Screens.teachersListScreen,
      builder: (context, state) => const TeachersListScreen(),
    ),

    GoRoute(
      path: Screens.studentsListScreen,
      name: Screens.studentsListScreen,
      builder: (context, state) => const StudentsListScreen(),
    ),
  ],
);
