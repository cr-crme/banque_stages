import 'package:crcrme_banque_stages/common/models/address.dart';
import 'package:crcrme_banque_stages/common/models/enterprise.dart';
import 'package:crcrme_banque_stages/common/models/incidents.dart';
import 'package:crcrme_banque_stages/common/models/internship.dart';
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

Teacher dummyTeacher({String id = 'teacherId'}) => Teacher(
      id: id,
      firstName: 'Pierre',
      middleName: 'Jean',
      lastName: 'Jacques',
      schoolId: 'schoolId',
      groups: ['101', '102'],
      email: 'peter.john.jakob@test.com',
      phone: dummyPhoneNumber(),
    );

Student dummyStudent({
  String id = 'studentId',
  Program program = Program.fpt,
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
    group: '101',
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
  String internshipId = 'internshipId',
}) =>
    PostIntershipEnterpriseEvaluation(
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
      acceptanceLanguageDisorder: 4,
      acceptanceIntellectualDisability: 4,
      acceptancePhysicalDisability: 4,
      acceptanceMentalHealthDisorder: 2,
      acceptanceBehaviorDifficulties: 2,
    );

Internship dummyInternship({
  String id = 'internshipId',
  String studentId = 'studentId',
  String teacherId = 'teacherId',
  String enterpriseId = 'enterpriseId',
  String jobId = 'jobId',
}) {
  final period = DateTimeRange(
      start: DateTime.now(), end: DateTime.now().add(const Duration(days: 20)));
  return Internship(
    id: id,
    versionDate: DateTime.now(),
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
    expectedLength: 135,
    achievedLength: 0,
    enterpriseEvaluation:
        dummyPostIntershipEnterpriseEvaluation(internshipId: id),
    weeklySchedules: [
      WeeklySchedule(
        schedule: [
          DailySchedule(
            dayOfWeek: Day.monday,
            start: const TimeOfDay(hour: 9, minute: 00),
            end: const TimeOfDay(hour: 15, minute: 00),
          ),
          DailySchedule(
            dayOfWeek: Day.tuesday,
            start: const TimeOfDay(hour: 9, minute: 00),
            end: const TimeOfDay(hour: 15, minute: 00),
          ),
          DailySchedule(
            dayOfWeek: Day.wednesday,
            start: const TimeOfDay(hour: 9, minute: 00),
            end: const TimeOfDay(hour: 15, minute: 00),
          ),
          DailySchedule(
            dayOfWeek: Day.thursday,
            start: const TimeOfDay(hour: 9, minute: 00),
            end: const TimeOfDay(hour: 15, minute: 00),
          ),
          DailySchedule(
            dayOfWeek: Day.friday,
            start: const TimeOfDay(hour: 9, minute: 00),
            end: const TimeOfDay(hour: 15, minute: 00),
          ),
        ],
        period: period,
      ),
    ],
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
}) =>
    Itinerary(date: DateTime(2000, 1, 1))
      ..add(dummyWaypoint())
      ..add(dummyWaypoint(id: 'waypointId2', latitude: 30.0, longitude: 30.5));
