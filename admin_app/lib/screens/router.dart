import 'package:admin_app/providers/auth_provider.dart';
import 'package:admin_app/screens/admins/admins_list_screen.dart';
import 'package:admin_app/screens/enterprises/enterprises_list_screen.dart';
import 'package:admin_app/screens/internships/internships_list_screen.dart';
import 'package:admin_app/screens/login/login_screen.dart';
import 'package:admin_app/screens/school_boards/school_boards_list_screen.dart';
import 'package:admin_app/screens/students/students_list_screen.dart';
import 'package:admin_app/screens/teachers/teachers_list_screen.dart';
import 'package:go_router/go_router.dart';

abstract class Screens {
  static const home = teachersListScreen;

  static const login = LoginScreen.route;
  static const schoolBoardsListScreen = SchoolBoardsListScreen.route;
  static const adminsListScreen = AdminsListScreen.route;
  static const teachersListScreen = TeachersListScreen.route;
  static const studentsListScreen = StudentsListScreen.route;
  static const enterprisesListScreen = EnterprisesListScreen.route;
  static const internshipsListScreen = InternshipsListScreen.route;
}

// Keep a reference of the last requested state so when login is successful, we can redirect to it
GoRouterState? _lastRequestedState;

final router = GoRouter(
  redirect: (context, state) {
    _lastRequestedState ??= state;
    if (AuthProvider.of(context).isFullySignedIn) {
      final lastRequestedState = _lastRequestedState;
      _lastRequestedState = null;
      return lastRequestedState?.fullPath;
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
              AuthProvider.of(context).isFullySignedIn ? '/' : null,
    ),
    GoRoute(
      path: Screens.schoolBoardsListScreen,
      name: Screens.schoolBoardsListScreen,
      builder: (context, state) => const SchoolBoardsListScreen(),
    ),
    GoRoute(
      path: Screens.adminsListScreen,
      name: Screens.adminsListScreen,
      builder: (context, state) => const AdminsListScreen(),
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
    GoRoute(
      path: Screens.enterprisesListScreen,
      name: Screens.enterprisesListScreen,
      builder: (context, state) => const EnterprisesListScreen(),
    ),
    GoRoute(
      path: Screens.internshipsListScreen,
      name: Screens.internshipsListScreen,
      builder: (context, state) => const InternshipsListScreen(),
    ),
  ],
);
