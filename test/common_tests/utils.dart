import 'package:crcrme_banque_stages/common/models/address.dart';
import 'package:crcrme_banque_stages/common/models/enterprise.dart';
import 'package:crcrme_banque_stages/common/models/incidents.dart';
import 'package:crcrme_banque_stages/common/models/internship.dart';
import 'package:crcrme_banque_stages/common/models/internship_evaluation_attitude.dart';
import 'package:crcrme_banque_stages/common/models/internship_evaluation_skill.dart';
import 'package:crcrme_banque_stages/common/models/itinerary.dart';
import 'package:crcrme_banque_stages/common/models/job.dart';
import 'package:crcrme_banque_stages/common/models/job_list.dart';
import 'package:crcrme_banque_stages/common/models/person.dart';
import 'package:crcrme_banque_stages/common/models/phone_number.dart';
import 'package:crcrme_banque_stages/common/models/pre_internship_request.dart';
import 'package:crcrme_banque_stages/common/models/protections.dart';
import 'package:crcrme_banque_stages/common/models/schedule.dart';
import 'package:crcrme_banque_stages/common/models/school.dart';
import 'package:crcrme_banque_stages/common/models/student.dart';
import 'package:crcrme_banque_stages/common/models/task_appreciation.dart';
import 'package:crcrme_banque_stages/common/models/teacher.dart';
import 'package:crcrme_banque_stages/common/models/uniform.dart';
import 'package:crcrme_banque_stages/common/models/visiting_priority.dart';
import 'package:crcrme_banque_stages/common/models/waypoints.dart';
import 'package:crcrme_banque_stages/misc/job_data_file_service.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';

School dummySchool({
  String? id,
}) =>
    School(id: id, name: 'Meine Schule', address: Address.empty);

Teacher dummyTeacher(
        {String id = 'teacherId',
        List<String> groups = const ['101', '102']}) =>
    Teacher(
      id: id,
      firstName: 'Pierre',
      middleName: 'Jean',
      lastName: 'Jacques',
      schoolId: 'schoolId',
      groups: groups,
      email: 'peter.john.jakob@test.com',
      phone: dummyPhoneNumber(),
    );

Student dummyStudent({
  String id = 'studentId',
  Program program = Program.fpt,
  String group = '101',
}) {
  final tp = dummyPerson();
  return Student(
    id: id,
    firstName: tp.firstName,
    middleName: tp.middleName,
    lastName: tp.lastName,
    dateBirth: tp.dateBirth,
    email: tp.email,
    phone: tp.phone,
    address: tp.address,
    contact: Person(id: 'My mother id', firstName: 'Jeanne', lastName: 'Doe'),
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
    '800-555-5555${extension == null ? '' : ' poste $extension'}}');

Address dummyAddress({
  bool skipCivicNumber = false,
  bool skipStreet = false,
  bool skipAppartment = false,
  bool skipCity = false,
  bool skipPostalCode = false,
}) =>
    Address(
      civicNumber: skipCivicNumber ? null : 100,
      street: skipStreet ? null : 'Wunderbar',
      appartment: skipAppartment ? null : 'A',
      city: skipCity ? null : 'Wonderland',
      postalCode: skipPostalCode ? null : 'H0H 0H0',
    );

JobList dummyJobList() {
  return JobList()..add(dummyJob());
}

Uniform dummyUniform({
  String? id,
}) =>
    Uniform(
        id: id,
        status: UniformStatus.suppliedByEnterprise,
        uniform: 'Un beau chapeu bleu\n'
            'Une belle chemise rouge\n'
            'Une cravate jaune peu désirable');

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
        'Q1': 'Oui',
        'Q1+t': 'Peu souvent, à la discrétion des employés.',
        'Q3': ['Un diable'],
        'Q5': ['Des ciseaux'],
        'Q9': ['Des solvants', 'Des produits de nettoyage'],
        'Q12': ['Bruyant'],
        'Q12+t': 'Bouchons a oreilles',
        'Q15': 'Oui',
        'Q18': 'Non',
      },
      date: DateTime(2000, 1, 1),
    );

PreInternshipRequest dummyPreInternshipRequest({
  String? id,
}) =>
    PreInternshipRequest(id: id, requests: [
      PreInternshipRequestType.judiciaryBackgroundCheck.name,
      'Manger de la poutine'
    ]);

Job dummyJob({String id = 'jobId'}) => Job(
      id: id,
      specialization: ActivitySectorsService.sectors[2].specializations[9],
      positionsOffered: 2,
      sstEvaluation: dummyJobSstEvaluation(),
      incidents: dummyIncidents(),
      minimumAge: 12,
      preInternshipRequest: dummyPreInternshipRequest(),
      uniform: dummyUniform(),
      protections: dummyProtections(),
    );

Enterprise dummyEnterprise({bool addJob = false}) {
  final jobs = JobList();
  if (addJob) {
    jobs.add(dummyJob());
  }
  return Enterprise(
    id: 'enterpriseId',
    name: 'Not named',
    activityTypes: {},
    recrutedBy: 'Nobody',
    shareWith: 'No one',
    jobs: jobs,
    contact: dummyPerson(),
    address: dummyAddress(),
    headquartersAddress: dummyAddress(),
  );
}

PostIntershipEnterpriseEvaluation dummyPostIntershipEnterpriseEvaluation({
  String id = 'postIntershipEnterpriseEvaluationId',
  String internshipId = 'internshipId',
  bool hasDisorder = true,
}) =>
    PostIntershipEnterpriseEvaluation(
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
  DateTime? versionDate,
  String studentId = 'studentId',
  String teacherId = 'teacherId',
  String enterpriseId = 'enterpriseId',
  String jobId = 'jobId',
  bool hasEndDate = false,
}) {
  final period = DateTimeRange(
      start: DateTime(1995, 10, 31),
      end: DateTime(1995, 10, 31).add(const Duration(days: 20)));
  return Internship(
    id: id,
    versionDate: versionDate ?? DateTime(1995, 10, 31),
    studentId: studentId,
    signatoryTeacherId: teacherId,
    extraSupervisingTeacherIds: [],
    enterpriseId: enterpriseId,
    jobId: jobId,
    extraSpecializationsId: [
      ActivitySectorsService.sectors[2].specializations[1].id,
      ActivitySectorsService.sectors[1].specializations[0].id,
    ],
    visitingPriority: VisitingPriority.values[0],
    supervisor: Person(
        firstName: 'Nobody',
        lastName: 'Forever',
        phone: PhoneNumber.fromString('514-555-1234')),
    date: period,
    endDate: hasEndDate ? DateTime(2034, 10, 28) : null,
    expectedLength: 135,
    achievedLength: 130,
    enterpriseEvaluation:
        dummyPostIntershipEnterpriseEvaluation(internshipId: id),
    weeklySchedules: [dummyWeeklySchedule(period: period)],
    skillEvaluations: [dummyInternshipEvaluationSkill()],
    attitudeEvaluations: [dummyInternshipEvaluationAttitude()],
  );
}

DailySchedule dummyDailySchedule(
    {String id = 'dailyScheduleId', Day dayOfWeek = Day.monday}) {
  return DailySchedule(
    id: id,
    dayOfWeek: dayOfWeek,
    start: const TimeOfDay(hour: 9, minute: 00),
    end: const TimeOfDay(hour: 15, minute: 00),
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
      address: Placemark(
          street: '123 rue de la rue',
          locality: 'Ville',
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
      inattendance: 1,
      ponctuality: 2,
      sociability: 3,
      politeness: 1,
      motivation: 2,
      dressCode: 3,
      qualityOfWork: 1,
      productivity: 2,
      autonomy: 3,
      cautiousness: 1,
      generalAppreciation: 2,
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
      comment: 'comment',
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
