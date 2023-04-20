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
import 'screens/internship_enrollment/internship_enrollment_screen.dart';
import 'screens/internship_forms/enterprise_steps/enterprise_evaluation_screen.dart';
import 'screens/internship_forms/student_steps/attitude_evaluation_screen.dart';
import 'screens/internship_forms/student_steps/skill_evaluation_form_controller.dart';
import 'screens/internship_forms/student_steps/skill_evaluation_form_screen.dart';
import 'screens/internship_forms/student_steps/skill_evaluation_main_screen.dart';
import 'screens/job_sst_form/job_sst_form_screen.dart';
import 'screens/login_screen.dart';
import 'screens/ref_sst/home_sst/home_sst_screen.dart';
import 'screens/ref_sst/risks_list/risks_list_screen.dart';
import 'screens/ref_sst/specialization_list_risks_and_skills/specialization_list_screen.dart';
import 'screens/student/student_screen.dart';
import 'screens/students_list/students_list_screen.dart';
import 'screens/supervision_chart/supervision_chart_screen.dart';
import 'screens/supervision_chart/supervision_student_details.dart';
import 'screens/visiting_students/itinerary_screen.dart';

abstract class Screens {
  static const populateWithDebugData = 'populate-with-debug-data';
  static const login = 'login';
  static const itinerary = 'itinerary';

  static const enterprisesList = 'enterprises-list';
  static const enterprise = 'enterprise';
  static const addEnterprise = 'add-enterprise';
  static const jobSstForm = 'job-sst-form';

  static const home = supervisionChart;
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

  static Map<String, String> withId(id, {jobId}) {
    return {
      'id': (id is String)
          ? id
          : (id is ItemSerializable ? id.id : throw TypeError()),
      if (jobId != null)
        'jobId': (jobId is String)
            ? jobId
            : (jobId is ItemSerializable ? jobId.id : throw TypeError())
    };
  }
}

final router = GoRouter(
  redirect: (context, state) {
    if (context.read<AuthProvider>().isSignedIn()) {
      return (populateWithDebugData && !hasDummyData(context))
          ? '/debug-data'
          : null;
    }
    return '/login';
  },
  routes: [
    GoRoute(
      path: '/',
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
          path: ':id:pageIndex',
          name: Screens.enterprise,
          builder: (context, state) => EnterpriseScreen(
              id: state.params['id']!,
              pageIndex: int.parse(state.params['pageIndex']!)),
          routes: [
            GoRoute(
              path: 'add-internship-enterprise',
              name: Screens.internshipEnrollementFromEnterprise,
              builder: (context, state) =>
                  InternshipEnrollmentScreen(enterpriseId: state.params['id']!),
            ),
            GoRoute(
              path: 'enterprise-evaluation/:jobId',
              name: Screens.enterpriseEvaluationScreen,
              builder: (context, state) => EnterpriseEvaluationScreen(
                id: state.params['id']!,
                jobId: state.params['jobId']!,
              ),
            ),
            GoRoute(
              path: ':jobId',
              name: Screens.jobSstForm,
              builder: (context, state) => JobSstFormScreen(
                  enterpriseId: state.params['id']!,
                  jobId: state.params['jobId']!),
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
          path: 'add-internship-student/:id',
          name: Screens.internshipEnrollementFromStudent,
          builder: (context, state) =>
              InternshipEnrollmentScreen(studentId: state.params['id']!),
        ),
        GoRoute(
          path: 'studentScreen/:id:initialPage',
          name: Screens.student,
          builder: (context, state) => StudentScreen(
              id: state.params['id']!,
              initialPage: int.parse(state.params['initialPage']!)),
        ),
      ],
    ),
    GoRoute(
      path: '/itinerary',
      name: Screens.itinerary,
      builder: (context, state) => const ItineraryScreen(),
    ),
    GoRoute(
      path: '/skill-evaluation-main/:internshipId:editMode',
      name: Screens.skillEvaluationMainScreen,
      builder: (context, state) => SkillEvaluationMainScreen(
        internshipId: state.params['internshipId']!,
        editMode: state.params['editMode']! == '1',
      ),
    ),
    GoRoute(
      path: '/skill-evaluation-form/:editMode',
      name: Screens.skillEvaluationFormScreen,
      builder: (context, state) {
        return SkillEvaluationFormScreen(
          formController: state.extra as SkillEvaluationFormController,
          editMode: state.params['editMode']! == '1',
        );
      },
    ),
    GoRoute(
      path: '/attitude-evaluation-form/:internshipId:editMode',
      name: Screens.attitudeEvaluationScreen,
      builder: (context, state) => AttitudeEvaluationScreen(
        internshipId: state.params['internshipId']!,
        editMode: state.params['editMode']! == '1',
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
              SpecializationListScreen(id: state.params['id']!),
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
