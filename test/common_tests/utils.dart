import 'package:crcrme_banque_stages/common/models/address.dart';
import 'package:crcrme_banque_stages/common/models/enterprise.dart';
import 'package:crcrme_banque_stages/common/models/incidents.dart';
import 'package:crcrme_banque_stages/common/models/internship.dart';
import 'package:crcrme_banque_stages/common/models/job.dart';
import 'package:crcrme_banque_stages/common/models/job_list.dart';
import 'package:crcrme_banque_stages/common/models/person.dart';
import 'package:crcrme_banque_stages/common/models/phone_number.dart';
import 'package:crcrme_banque_stages/common/models/pre_internship_request.dart';
import 'package:crcrme_banque_stages/common/models/protections.dart';
import 'package:crcrme_banque_stages/common/models/schedule.dart';
import 'package:crcrme_banque_stages/common/models/uniform.dart';
import 'package:crcrme_banque_stages/common/models/visiting_priority.dart';
import 'package:crcrme_banque_stages/misc/job_data_file_service.dart';
import 'package:flutter/material.dart';

Person dummyPerson() => Person(firstName: 'Jeanne', lastName: 'Doe');

PhoneNumber dummyPhoneNumber() => PhoneNumber.fromString('800-555-5555');

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
  final jobList = JobList();
  jobList.add(Job(
      specialization: ActivitySectorsService.sectors[2].specializations[9],
      positionsOffered: 2,
      sstEvaluation: JobSstEvaluation.empty,
      incidents: Incidents(
          severeInjuries: [Incident('Vaut mieux ne pas détailler...')]),
      minimumAge: 12,
      preInternshipRequest:
          PreInternshipRequest(requests: ['Manger de la poutine']),
      uniform: Uniform(
          status: UniformStatus.suppliedByEnterprise,
          uniform: 'Un beau chapeu bleu'),
      protections: Protections(
          status: ProtectionsStatus.suppliedByEnterprise,
          protections: [
            'Une veste de mithril',
            'Une cotte de maille',
            'Une drole de bague'
          ])));
  return jobList;
}

Job dummyJob({String withId = 'jobId'}) => Job(
    id: withId,
    specialization: ActivitySectorsService.sectors[2].specializations[9],
    positionsOffered: 2,
    sstEvaluation: JobSstEvaluation.empty,
    incidents:
        Incidents(severeInjuries: [Incident('Vaut mieux ne pas détailler...')]),
    minimumAge: 12,
    preInternshipRequest:
        PreInternshipRequest(requests: ['Manger de la poutine']),
    uniform: Uniform(
        status: UniformStatus.suppliedByEnterprise,
        uniform: 'Un beau chapeu bleu'),
    protections: Protections(
        status: ProtectionsStatus.suppliedByEnterprise,
        protections: [
          'Une veste de mithril',
          'Une cotte de maille',
          'Une drole de bague'
        ]));

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

Internship dummyInternship() {
  final period = DateTimeRange(
      start: DateTime.now(), end: DateTime.now().add(const Duration(days: 20)));
  return Internship(
    versionDate: DateTime.now(),
    studentId: 'studentId',
    signatoryTeacherId: 'teacherId',
    extraSupervisingTeacherIds: [],
    enterpriseId: 'enterpriseId',
    jobId: 'jobId',
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
