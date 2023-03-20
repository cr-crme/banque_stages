import 'package:enhanced_containers/item_serializable.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'common/providers/auth_provider.dart';
import 'dummy_data.dart';
import 'main.dart';
import 'screens/add_enterprise/add_enterprise_screen.dart';
import 'screens/enterprise/enterprise_screen.dart';
import 'screens/enterprises_list/enterprises_list_screen.dart';
import 'screens/generate_debug_data_screen.dart';
import 'screens/home_screen.dart';
import 'screens/internship_enrollment/internship_enrollment_screen.dart';
import 'screens/internship_forms/post_internship_evaluation_screen.dart';
import 'screens/login_screen.dart';
import 'screens/ref_sst/home_sst/home_sst_screen.dart';
import 'screens/ref_sst/job_list_risks_and_skills/job_list_screen.dart';
import 'screens/ref_sst/risks_list/risks_list_screen.dart';
import 'screens/student/student_screen.dart';
import 'screens/students_list/students_list_screen.dart';
import 'screens/supervision_chart/supervision_chart_screen.dart';
import 'screens/supervision_chart/supervision_student_details.dart';
import 'screens/visiting_students/visit_students_screen.dart';

abstract class Screens {
  static const home = 'home';
  static const populateWithDebugData = 'populate-with-debug-data';
  static const login = 'login';
  static const visitStudents = 'visit-students';

  static const enterprisesList = 'enterprises-list';
  static const enterprise = 'enterprise';
  static const addEnterprise = 'add-enterprise';

  static const supervisionChart = 'supervision';
  static const supervisionStudentDetails = 'supervision-student-details';

  static const studentsList = 'students-list';
  static const student = 'student';
  static const addStudent = 'add-student';

  static const internshipEnrollement = 'add-internship';
  static const postInternshipEvaluationScreen = 'post-internship-evaluation';

  static const homeSst = 'home-sst';
  static const jobSst = 'job-sst';
  static const cardsSst = 'cards-sst';

  static Map<String, String> withId(id) {
    if (id is String) {
      return {'id': id};
    } else if (id is ItemSerializable) {
      return {'id': id.id};
    }

    throw TypeError();
  }
}

final router = GoRouter(
  redirect: (context, state) {
    if (context.read<AuthProvider>().isSignedIn()) {
      return populateWithDebugData && !hasDummyData(context)
          ? '/debug-data'
          : null;
    }
    return '/login';
  },
  routes: [
    GoRoute(
      path: '/',
      name: Screens.home,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/debug-data',
      name: Screens.populateWithDebugData,
      builder: (context, state) => const GenerateDebugDataScreen(),
    ),
    GoRoute(
      path: '/login',
      name: Screens.login,
      builder: (context, state) => const LoginScreen(),
      redirect: (context, state) =>
          context.read<AuthProvider>().isSignedIn() ? '/' : null,
    ),
    GoRoute(
      path: '/enterprises',
      name: Screens.enterprisesList,
      builder: (context, state) => const EnterprisesListScreen(),
      routes: [
        GoRoute(
          path: 'add',
          name: Screens.addEnterprise,
          builder: (context, state) => const AddEnterpriseScreen(),
        ),
        GoRoute(
          path: ':id',
          name: Screens.enterprise,
          builder: (context, state) =>
              EnterpriseScreen(id: state.params['id']!),
          routes: [
            GoRoute(
              path: 'internship',
              name: Screens.internshipEnrollement,
              builder: (context, state) =>
                  InternshipEnrollmentScreen(enterpriseId: state.params['id']!),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/supervision',
      name: Screens.supervisionChart,
      builder: (context, state) => const SupervisionChart(),
      routes: [
        GoRoute(
          path: 'student-details/:studentId',
          name: Screens.supervisionStudentDetails,
          builder: (context, state) => SupervisionStudentDetailsScreen(
              studentId: state.params['studentId']!),
        ),
      ],
    ),
    GoRoute(
      path: '/students',
      name: Screens.studentsList,
      builder: (context, state) => const StudentsListScreen(),
      routes: [
        GoRoute(
          path: ':id/:initialPage',
          name: Screens.student,
          builder: (context, state) => StudentScreen(
              id: state.params['id']!,
              initialPage: state.params.containsKey('initialPage')
                  ? int.parse(state.params['initialPage']!)
                  : 0),
        ),
      ],
    ),
    GoRoute(
      path: '/visit-students',
      name: Screens.visitStudents,
      builder: (context, state) => const VisitStudentScreen(),
    ),
    GoRoute(
      path: '/post-internship-evaluation',
      name: Screens.postInternshipEvaluationScreen,
      builder: (context, state) => PostInternshipEvaluationScreen(
        enterpriseId: state.params['enterpriseId']!,
        jobId: state.params['jobId']!,
      ),
    ),
    GoRoute(
      path: '/sst',
      name: Screens.homeSst,
      builder: (context, state) => const HomeSstScreen(),
      routes: [
        GoRoute(
          path: 'jobs/:id',
          name: Screens.jobSst,
          builder: (context, state) => JobListScreen(id: state.params['id']!),
        ),
        GoRoute(
          name: Screens.cardsSst,
          path: 'cards',
          builder: (context, state) => const SstCardsScreen(),
        ),
      ],
    ),
  ],
);
