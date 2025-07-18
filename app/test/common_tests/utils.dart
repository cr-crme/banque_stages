import 'package:common/models/enterprises/enterprise.dart';
import 'package:common/models/enterprises/job.dart';
import 'package:common/models/enterprises/job_list.dart';
import 'package:common/models/generic/address.dart';
import 'package:common/models/generic/phone_number.dart';
import 'package:common/models/internships/internship.dart';
import 'package:common/models/internships/internship_evaluation_attitude.dart';
import 'package:common/models/internships/internship_evaluation_skill.dart';
import 'package:common/models/internships/schedule.dart';
import 'package:common/models/internships/task_appreciation.dart';
import 'package:common/models/internships/time_utils.dart';
import 'package:common/models/internships/transportation.dart';
import 'package:common/models/itineraries/itinerary.dart';
import 'package:common/models/itineraries/visiting_priority.dart';
import 'package:common/models/itineraries/waypoint.dart';
import 'package:common/models/persons/person.dart';
import 'package:common/models/persons/student.dart';
import 'package:common/models/persons/teacher.dart';
import 'package:common/models/school_boards/school.dart';
import 'package:common/services/job_data_file_service.dart';

void expectNear(double a, double b, {double epsilon = 1e-8}) {
  if ((a - b).abs() > epsilon) {
    throw Exception('Expected $a to be near $b within $epsilon');
  }
}

School dummySchool({
  String? id,
}) =>
    School(
        id: id,
        name: 'Meine Schule',
        address: Address.empty,
        phone: PhoneNumber.empty);

Teacher dummyTeacher(
        {String id = 'teacherId',
        String schoolBoardId = 'school_board_id',
        String schoolId = 'school_id',
        List<String> groups = const ['101', '102']}) =>
    Teacher(
      id: id,
      firstName: 'Pierre',
      middleName: 'Jean',
      lastName: 'Jacques',
      schoolBoardId: schoolBoardId,
      schoolId: schoolId,
      hasRegisteredAccount: false,
      groups: groups,
      email: 'peter.john.jakob@test.com',
      phone: dummyPhoneNumber(),
      address: null,
      dateBirth: null,
      itineraries: [],
    );

Student dummyStudent({
  String firstName = 'Jeanne',
  String lastName = 'Doe',
  String id = 'studentId',
  Program program = Program.fpt,
  String group = '101',
}) {
  final tp = dummyPerson(firstName: firstName, lastName: lastName);
  return Student(
    id: id,
    schoolBoardId: 'schoolBoardId',
    schoolId: 'schoolId',
    firstName: tp.firstName,
    middleName: tp.middleName,
    lastName: tp.lastName,
    dateBirth: tp.dateBirth,
    email: tp.email,
    phone: tp.phone,
    address: tp.address,
    contact: Person(
      id: 'My mother id',
      firstName: 'Jeanne',
      middleName: null,
      lastName: 'Doe',
      dateBirth: null,
      phone: PhoneNumber.empty,
      address: Address.empty,
      email: null,
    ),
    photo: '0x00FF00',
    contactLink: 'Mère',
    group: group,
    program: program,
  );
}

Person dummyPerson({
  String id = 'personId',
  String firstName = 'Jeanne',
  String lastName = 'Doe',
}) =>
    Person(
        id: id,
        firstName: firstName,
        middleName: 'Kathlin',
        lastName: lastName,
        address: dummyAddress(),
        dateBirth: DateTime(2000, 1, 1),
        email: 'jeanne.k.doe@test.com',
        phone: dummyPhoneNumber());

PhoneNumber dummyPhoneNumber({int? extension}) => PhoneNumber.fromString(
    '800-555-5555${extension == null ? '' : ' poste $extension'}');

Address dummyAddress({
  bool skipCivicNumber = false,
  bool skipStreet = false,
  bool skipApartment = false,
  bool skipCity = false,
  bool skipPostalCode = false,
}) =>
    Address(
      civicNumber: skipCivicNumber ? null : 100,
      street: skipStreet ? null : 'Wunderbar',
      apartment: skipApartment ? null : 'A',
      city: skipCity ? null : 'Wonderland',
      postalCode: skipPostalCode ? null : 'H0H 0H0',
    );

JobList dummyJobList() {
  return JobList()..add(dummyJob());
}

Uniforms dummyUniforms({
  String? id,
}) =>
    Uniforms(id: id, status: UniformStatus.suppliedByEnterprise, uniforms: [
      'Un beau chapeu bleu',
      'Une belle chemise rouge',
      'Une cravate jaune peu désirable'
    ]);

Protections dummyProtections({
  String? id,
}) =>
    Protections(
        id: id,
        status: ProtectionsStatus.suppliedByEnterprise,
        protections: [
          'Une veste de mithril',
          'Une cotte de maille',
          'Une drole de bague'
        ]);

Incidents dummyIncidents({
  String? id,
}) =>
    Incidents(
      id: id,
      severeInjuries: [],
      minorInjuries: [
        Incident('Un "petit" truc avec la scie sauteuse'),
        Incident('Une "légère" entaille de la main au couteau')
      ],
      verbalAbuses: [Incident('Vaut mieux ne pas détailler...')],
    );

JobSstEvaluation dummyJobSstEvaluation({
  String? id,
}) =>
    JobSstEvaluation(
      id: id,
      questions: {
        'Q1': ['Oui'],
        'Q1+t': ['Peu souvent, à la discrétion des employés.'],
        'Q3': ['Un diable'],
        'Q5': ['Des ciseaux'],
        'Q9': ['Des solvants', 'Des produits de nettoyage'],
        'Q12': ['Bruyant'],
        'Q12+t': ['Bouchons a oreilles'],
        'Q15': ['Oui'],
        'Q18': ['Non'],
      },
      date: DateTime(2000, 1, 1),
    );

PreInternshipRequests dummyPreInternshipRequests({
  String? id,
}) =>
    PreInternshipRequests(
      id: id,
      requests: [PreInternshipRequestTypes.judiciaryBackgroundCheck],
      other: 'Manger de la poutine',
      isApplicable: true,
    );

Job dummyJob({
  String id = 'jobId',
  String? sstEvaluationId,
  String? incidentsId,
  String? preInternshipId,
  String? uniformId,
  String? protectionsId,
}) =>
    Job(
      id: id,
      specialization:
          ActivitySectorsService.activitySectors[2].specializations[9],
      positionsOffered: {'school_id': 2},
      sstEvaluation: dummyJobSstEvaluation(id: sstEvaluationId ?? id),
      incidents: dummyIncidents(id: incidentsId ?? id),
      minimumAge: 12,
      preInternshipRequests:
          dummyPreInternshipRequests(id: preInternshipId ?? id),
      uniforms: dummyUniforms(id: uniformId ?? id),
      protections: dummyProtections(id: protectionsId ?? id),
      reservedForId: '',
    );

Enterprise dummyEnterprise({bool addJob = false}) {
  final jobs = JobList();
  if (addJob) {
    jobs.add(dummyJob());
  }
  return Enterprise(
    schoolBoardId: 'schoolBoardId',
    id: 'enterpriseId',
    name: 'Not named',
    activityTypes: {},
    recruiterId: 'Nobody',
    jobs: jobs,
    contact: dummyPerson(),
    address: dummyAddress(),
    headquartersAddress: dummyAddress(),
    reservedForId: '',
  );
}

PostInternshipEnterpriseEvaluation dummyPostInternshipEnterpriseEvaluation({
  String id = 'postInternshipEnterpriseEvaluationId',
  String internshipId = 'internshipId',
  bool hasDisorder = true,
}) =>
    PostInternshipEnterpriseEvaluation(
      id: id,
      internshipId: internshipId,
      skillsRequired: [
        'Communiquer à l\'écrit',
        'Interagir avec des clients',
      ],
      taskVariety: 0,
      trainingPlanRespect: 1,
      autonomyExpected: 4,
      efficiencyExpected: 2,
      supervisionStyle: 1,
      easeOfCommunication: 5,
      absenceAcceptance: 4,
      supervisionComments: 'Milieu peu aidant, mais ouvert',
      acceptanceTsa: -1,
      acceptanceLanguageDisorder: hasDisorder ? 4 : -1,
      acceptanceIntellectualDisability: hasDisorder ? 4 : -1,
      acceptancePhysicalDisability: hasDisorder ? 4 : -1,
      acceptanceMentalHealthDisorder: hasDisorder ? 2 : -1,
      acceptanceBehaviorDifficulties: hasDisorder ? 2 : -1,
    );

Internship dummyInternship({
  String id = 'internshipId',
  String schoolBoardId = 'schoolBoardId',
  DateTime? versionDate,
  String studentId = 'studentId',
  String teacherId = 'teacherId',
  String enterpriseId = 'enterpriseId',
  String jobId = 'jobId',
  bool hasEndDate = false,
  int achievedLength = 130,
}) {
  final period = DateTimeRange(
      start: DateTime(1995, 10, 31),
      end: DateTime(1995, 10, 31).add(const Duration(days: 20)));
  return Internship(
    id: id,
    schoolBoardId: schoolBoardId,
    creationDate: versionDate ?? DateTime(1995, 10, 31),
    studentId: studentId,
    signatoryTeacherId: teacherId,
    extraSupervisingTeacherIds: [],
    enterpriseId: enterpriseId,
    jobId: jobId,
    extraSpecializationIds: [
      ActivitySectorsService.activitySectors[2].specializations[1].id,
      ActivitySectorsService.activitySectors[1].specializations[0].id,
    ],
    visitingPriority: VisitingPriority.values[0],
    supervisor: Person(
      firstName: 'Nobody',
      middleName: null,
      lastName: 'Forever',
      dateBirth: null,
      phone: PhoneNumber.fromString('514-555-1234'),
      address: Address.empty,
      email: null,
    ),
    dates: period,
    endDate: hasEndDate ? DateTime(2034, 10, 28) : DateTime(0),
    expectedDuration: 135,
    achievedDuration: achievedLength,
    enterpriseEvaluation:
        dummyPostInternshipEnterpriseEvaluation(internshipId: id),
    weeklySchedules: [dummyWeeklySchedule(period: period)],
    skillEvaluations: [dummyInternshipEvaluationSkill()],
    attitudeEvaluations: [dummyInternshipEvaluationAttitude()],
    transportations: [Transportation.none],
    visitFrequencies: 'Tous les jours',
  );
}

DailySchedule dummyDailySchedule(
    {String id = 'dailyScheduleId', Day dayOfWeek = Day.monday}) {
  return DailySchedule(
    id: id,
    dayOfWeek: dayOfWeek,
    start: const TimeOfDay(hour: 9, minute: 00),
    end: const TimeOfDay(hour: 15, minute: 00),
    breakStart: const TimeOfDay(hour: 12, minute: 00),
    breakEnd: const TimeOfDay(hour: 13, minute: 00),
  );
}

WeeklySchedule dummyWeeklySchedule(
    {String id = 'weeklyScheduleId', DateTimeRange? period}) {
  return WeeklySchedule(
    id: id,
    schedule: [
      dummyDailySchedule(id: 'dailyScheduleId1', dayOfWeek: Day.monday),
      dummyDailySchedule(id: 'dailyScheduleId2', dayOfWeek: Day.tuesday),
      dummyDailySchedule(id: 'dailyScheduleId3', dayOfWeek: Day.wednesday),
      dummyDailySchedule(id: 'dailyScheduleId4', dayOfWeek: Day.thursday),
      dummyDailySchedule(id: 'dailyScheduleId5', dayOfWeek: Day.friday),
    ],
    period: period ??
        DateTimeRange(start: DateTime(2026, 1, 2), end: DateTime(2026, 1, 22)),
  );
}

Waypoint dummyWaypoint(
        {String id = 'waypointId',
        double latitude = 40.0,
        double longitude = 50.0}) =>
    Waypoint(
      id: id,
      title: 'Waypoint',
      subtitle: 'Subtitle',
      latitude: latitude,
      longitude: longitude,
      address: Address(
          civicNumber: 123,
          street: 'rue de la rue',
          city: 'Ville',
          postalCode: 'H0H 0H0'),
    );

Itinerary dummyItinerary({
  String id = 'itineraryId',
  String studentId = 'studentId',
  String teacherId = 'teacherId',
  String enterpriseId = 'enterpriseId',
  String jobId = 'jobId',
  DateTime? date,
}) =>
    Itinerary(id: id, date: date ?? DateTime(2000, 1, 1))
      ..add(dummyWaypoint())
      ..add(dummyWaypoint(id: 'waypointId2', latitude: 30.0, longitude: 30.5));

AttitudeEvaluation dummyAttitudeEvaluation(
        {String id = 'attitudeEvaluationId'}) =>
    AttitudeEvaluation(
      id: id,
      inattendance: Inattendance.rarely,
      ponctuality: Ponctuality.sometimeLate,
      sociability: Sociability.veryLow,
      politeness: Politeness.alwaysSuitable,
      motivation: Motivation.low,
      dressCode: DressCode.notAppropriate,
      qualityOfWork: QualityOfWork.high,
      productivity: Productivity.low,
      autonomy: Autonomy.none,
      cautiousness: Cautiousness.mostly,
      generalAppreciation: GeneralAppreciation.passable,
    );

InternshipEvaluationAttitude dummyInternshipEvaluationAttitude(
        {String id = 'internshipEvaluationAttitudeId'}) =>
    InternshipEvaluationAttitude(
      id: id,
      date: DateTime(1980, 5, 20),
      presentAtEvaluation: ['Me', 'You'],
      attitude: dummyAttitudeEvaluation(),
      comments: 'No comment',
      formVersion: '1.0.0',
    );

TaskAppreciation dummyTaskAppreciation() => TaskAppreciation(
    id: 'taskAppreciationId',
    title: 'Task title',
    level: TaskAppreciationLevel.autonomous);

SkillEvaluation dummySkillEvaluation({String id = 'skillEvaluationId'}) =>
    SkillEvaluation(
      id: id,
      specializationId: 'specializationId',
      skillName: 'skillName',
      tasks: [dummyTaskAppreciation()],
      appreciation: SkillAppreciation.failed,
      comments: 'comment',
    );

InternshipEvaluationSkill dummyInternshipEvaluationSkill(
        {String id = 'internshipEvaluationSkillId'}) =>
    InternshipEvaluationSkill(
      id: id,
      date: DateTime(1980, 5, 20),
      presentAtEvaluation: ['Me', 'You'],
      skillGranularity: SkillEvaluationGranularity.byTask,
      skills: [dummySkillEvaluation()],
      comments: 'No comment',
      formVersion: '1.0.0',
    );
