import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import 'screens/enterprise/enterprise_screen.dart';
import 'screens/enterprises_list/enterprises_list_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/ref_sst/home_sst/home_sst_screen.dart';
import 'screens/ref_sst/job_list_risks_and_skills/job_list_screen.dart';
import 'screens/student/student_screen.dart';
import 'screens/students_list/students_list_screen.dart';
import 'screens/visiting_students/visit_students_screen.dart';

final router = _BanqueStagesRouterDelegate();
final routerInformationParser = _BanqueStagesRouteInformationParser();

abstract class Navigation {
  static void openNamedRoute(String route) {
    routerInformationParser
        .parseRouteInformation(RouteInformation(location: route))
        .then((config) => router.setNewRoutePath(config));
  }
}

abstract class Routes {
  static const home = "";
  static const login = "login";
  static const enterprisesList = "enterprises";
  static String enterprise(String id) => "$enterprisesList/$id";
  static const studentsList = "students";
  static String student(String id) => "$studentsList/$id";
  static const visitStudents = "visit-students";
  static const homeSST = "sst";
  static String jobSST(String id) => "$homeSST/$id";
  static const risksSST = "$homeSST/risks";
  static const riSST = "$homeSST/sst";
}

const _homePage = MaterialPage(
  key: ValueKey(Routes.home),
  child: HomeScreen(),
);

const _routePages = {
  Routes.login: MaterialPage(
    key: ValueKey(Routes.login),
    child: LoginScreen(),
  ),
  Routes.enterprisesList: MaterialPage(
    key: ValueKey(Routes.enterprisesList),
    child: EnterprisesListScreen(),
  ),
  Routes.studentsList: MaterialPage(
    key: ValueKey(Routes.studentsList),
    child: StudentsListScreen(),
  ),
  Routes.visitStudents: MaterialPage(
    key: ValueKey(Routes.visitStudents),
    child: VisitStudentScreen(),
  ),
  Routes.homeSST: MaterialPage(
    key: ValueKey(Routes.homeSST),
    child: HomeSSTScreen(),
  ),
};

class _RouteConfiguration {
  _RouteConfiguration({required this.route, this.data});

  String route;
  String? data;
}

class _BanqueStagesRouteInformationParser
    extends RouteInformationParser<_RouteConfiguration> {
  @override
  Future<_RouteConfiguration> parseRouteInformation(routeInformation) async {
    final segments =
        Uri.parse(routeInformation.location ?? Routes.home).pathSegments;

    if (segments.isEmpty) {
      return _RouteConfiguration(route: "");
    }

    if (_routePages.keys.any((e) => e.endsWith(segments.last))) {
      return _RouteConfiguration(route: segments.join("/"));
    }

    return _RouteConfiguration(
      route: segments.take(segments.length - 1).join("/"),
      data: segments.last,
    );
  }

  @override
  RouteInformation restoreRouteInformation(_RouteConfiguration configuration) {
    if (configuration.data == null) {
      return RouteInformation(
        location: configuration.route,
      );
    }

    return RouteInformation(
      location: "${configuration.route}/${configuration.data}",
    );
  }
}

class _BanqueStagesRouterDelegate extends RouterDelegate<_RouteConfiguration>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<_RouteConfiguration> {
  @override
  final navigatorKey = GlobalKey<NavigatorState>();

  _RouteConfiguration _config = _RouteConfiguration(route: "");

  List<MaterialPage> _getPages(_RouteConfiguration config) {
    List<MaterialPage> pages = [_homePage];
    if (config.route.isEmpty) {
      return pages;
    }

    String route = "";
    for (String segment in config.route.split("/")) {
      route += segment;
      final entry = _routePages.entries.firstWhereOrNull((e) => e.key == route);
      if (entry != null) {
        pages.add(entry.value);
      }
      route += "/";
    }

    if (config.data != null) {
      final routePageData = {
        Routes.enterprisesList: MaterialPage(
          key: ValueKey(Routes.enterprise(config.data!)),
          child: EnterpriseScreen(id: config.data!),
        ),
        Routes.studentsList: MaterialPage(
          key: ValueKey(Routes.student(config.data!)),
          child: StudentScreen(id: config.data!),
        ),
        Routes.homeSST: MaterialPage(
          key: const ValueKey(Routes.jobSST),
          child: JobListScreen(id: config.data!),
        ),
      };

      final entry =
          routePageData.entries.firstWhereOrNull((e) => e.key == config.route);
      if (entry != null) {
        pages.add(entry.value);
      }
    }

    return pages;
  }

  @override
  Widget build(BuildContext context) {
    return Navigator(
      key: navigatorKey,
      pages: _getPages(_config),
      onPopPage: (route, result) {
        if (!route.didPop(result)) {
          return false;
        }

        if (_config.data != null) {
          _config.data = null;
        } else if (_config.route != Routes.home) {
          _config.route = Routes.home;
        }

        notifyListeners();
        return true;
      },
    );
  }

  @override
  Future<void> setNewRoutePath(_RouteConfiguration configuration) async {
    _config = configuration;
    notifyListeners();
  }

  @override
  _RouteConfiguration get currentConfiguration => _config;
}
