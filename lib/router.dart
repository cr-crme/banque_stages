import 'package:crcrme_banque_stages/screens/add_enterprise/add_enterprise_screen.dart';
import 'package:crcrme_banque_stages/screens/enterprise/enterprise_screen.dart';
import 'package:crcrme_banque_stages/screens/enterprises_list/enterprises_list_screen.dart';
import 'package:crcrme_banque_stages/screens/internship_enrollment/internship_enrollment_screen.dart';
import 'package:crcrme_banque_stages/screens/internship_forms/enterprise_steps/enterprise_evaluation_screen.dart';
import 'package:crcrme_banque_stages/screens/internship_forms/student_steps/attitude_evaluation_form_controller.dart';
import 'package:crcrme_banque_stages/screens/internship_forms/student_steps/attitude_evaluation_screen.dart';
import 'package:crcrme_banque_stages/screens/internship_forms/student_steps/skill_evaluation_form_controller.dart';
import 'package:crcrme_banque_stages/screens/internship_forms/student_steps/skill_evaluation_form_screen.dart';
import 'package:crcrme_banque_stages/screens/internship_forms/student_steps/skill_evaluation_main_screen.dart';
import 'package:crcrme_banque_stages/screens/job_sst_form/job_sst_form_screen.dart';
import 'package:crcrme_banque_stages/screens/login_screen.dart';
import 'package:crcrme_banque_stages/screens/ref_sst/home_sst/home_sst_screen.dart';
import 'package:crcrme_banque_stages/screens/ref_sst/risks_list/risks_list_screen.dart';
import 'package:crcrme_banque_stages/screens/ref_sst/specialization_list_risks_and_skills/specialization_list_screen.dart';
import 'package:crcrme_banque_stages/screens/student/student_screen.dart';
import 'package:crcrme_banque_stages/screens/students_list/students_list_screen.dart';
import 'package:crcrme_banque_stages/screens/supervision_chart/supervision_chart_screen.dart';
import 'package:crcrme_banque_stages/screens/supervision_chart/supervision_student_details.dart';
import 'package:crcrme_banque_stages/screens/tasks_to_do/tasks_to_do_screen.dart';
import 'package:crcrme_banque_stages/screens/visiting_students/itinerary_screen.dart';
import 'package:enhanced_containers/item_serializable.dart';
import 'package:go_router/go_router.dart';

import 'common/providers/auth_provider.dart';

abstract class Screens {
  static const home = enterprisesList;

  static const login = 'login';
  static const itinerary = 'itinerary';

  static const tasksToDo = 'tasksToDo';

  static const enterprisesList = 'enterprises-list';
  static const enterprise = 'enterprise';
  static const addEnterprise = 'add-enterprise';
  static const jobSstForm = 'job-sst-form';

  static const supervisionChart = 'supervision';
  static const supervisionStudentDetails = 'supervision-student-details';

  static const studentsList = 'students-list';
  static const student = 'student';
  static const addStudent = 'add-student';

  static const internshipEnrollementFromEnterprise =
      'add-internship-from-enterprise';
  static const internshipEnrollementFromStudent = 'add-internship-from-student';
  static const enterpriseEvaluationScreen = 'enterprise-evaluation';
  static const skillEvaluationMainScreen = 'skill-evaluation-main';
  static const skillEvaluationFormScreen = 'skill-evaluation-form';
  static const attitudeEvaluationScreen = 'attitude-evaluation';

  static const homeSst = 'home-sst';
  static const jobSst = 'job-sst';
  static const cardsSst = 'cards-sst';

  static Map<String, String> params(id, {jobId}) {
    return {
      'id': (id is String)
          ? id
          : (id is ItemSerializable ? id.id : throw TypeError()),
      if (jobId != null)
        'jobId': (jobId is String)
            ? jobId
            : (jobId is ItemSerializable ? jobId.id : throw TypeError()),
    };
  }

  static Map<String, String> queryParams({pageIndex, editMode}) {
    return {
      if (pageIndex != null)
        'pageIndex': (pageIndex is String)
            ? pageIndex
            : (pageIndex is ItemSerializable
                ? pageIndex.id
                : throw TypeError()),
      if (editMode != null)
        'editMode': (editMode is String)
            ? editMode
            : (editMode is ItemSerializable ? editMode.id : throw TypeError()),
    };
  }
}

final router = GoRouter(
  initialLocation: '/students',
  redirect: (context, state) {
    if (AuthProvider.of(context, listen: false).isSignedIn()) {
      return null;
    }
    return '/login';
  },
  routes: [
    GoRoute(
      path: '/login',
      name: Screens.login,
      builder: (context, state) => const LoginScreen(),
      redirect: (context, state) =>
          AuthProvider.of(context, listen: false).isSignedIn() ? '/' : null,
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
          path: 'add-internship-enterprise/:id',
          name: Screens.internshipEnrollementFromEnterprise,
          builder: (context, state) => InternshipEnrollmentScreen(
              enterpriseId: state.pathParameters['id']!),
        ),
        GoRoute(
          path: 'enterprise-evaluation/:id',
          name: Screens.enterpriseEvaluationScreen,
          builder: (context, state) =>
              EnterpriseEvaluationScreen(id: state.pathParameters['id']!),
        ),
        GoRoute(
          path: ':id',
          name: Screens.enterprise,
          builder: (context, state) => EnterpriseScreen(
            id: state.pathParameters['id']!,
            pageIndex: int.parse(state.pathParameters['pageIndex'] ?? '0'),
          ),
          routes: [
            GoRoute(
              path: ':jobId',
              name: Screens.jobSstForm,
              builder: (context, state) => JobSstFormScreen(
                enterpriseId: state.pathParameters['id']!,
                jobId: state.pathParameters['jobId']!,
              ),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/students',
      name: Screens.studentsList,
      builder: (context, state) => const StudentsListScreen(),
      routes: [
        GoRoute(
          path: 'studentScreen/:id',
          name: Screens.student,
          builder: (context, state) => StudentScreen(
              id: state.pathParameters['id']!,
              initialPage:
                  int.parse(state.uri.queryParameters['pageIndex'] ?? '0')),
        ),
      ],
    ),
    GoRoute(
      path: '/supervision',
      name: Screens.supervisionChart,
      builder: (context, state) => const SupervisionChart(),
      routes: [
        GoRoute(
          path: 'student-details/:id',
          name: Screens.supervisionStudentDetails,
          builder: (context, state) => SupervisionStudentDetailsScreen(
            studentId: state.pathParameters['id']!,
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/itinerary',
      name: Screens.itinerary,
      builder: (context, state) => const ItineraryMainScreen(),
    ),
    GoRoute(
      path: '/tasks-to-do',
      name: Screens.tasksToDo,
      builder: (context, state) => const TasksToDoScreen(),
    ),
    GoRoute(
      path: '/skill-evaluation-main/:id',
      name: Screens.skillEvaluationMainScreen,
      builder: (context, state) => SkillEvaluationMainScreen(
        internshipId: state.pathParameters['id']!,
        editMode: state.uri.queryParameters['editMode']! == '1',
      ),
    ),
    GoRoute(
      path: '/skill-evaluation-form',
      name: Screens.skillEvaluationFormScreen,
      builder: (context, state) {
        return SkillEvaluationFormScreen(
          formController: state.extra as SkillEvaluationFormController,
          editMode: state.uri.queryParameters['editMode']! == '1',
        );
      },
    ),
    GoRoute(
      path: '/attitude-evaluation-form',
      name: Screens.attitudeEvaluationScreen,
      builder: (context, state) => AttitudeEvaluationScreen(
        formController: state.extra as AttitudeEvaluationFormController,
        editMode: state.uri.queryParameters['editMode'] == '1',
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
          builder: (context, state) =>
              SpecializationListScreen(id: state.uri.queryParameters['id']!),
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
