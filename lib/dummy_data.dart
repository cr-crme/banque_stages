import 'dart:math';

import 'package:enhanced_containers/enhanced_containers.dart';
import 'package:flutter/material.dart';

import '/common/models/address.dart';
import '/common/models/enterprise.dart';
import '/common/models/internship.dart';
import '/common/models/job.dart';
import '/common/models/job_list.dart';
import '/common/models/person.dart';
import '/common/models/schedule.dart';
import '/common/models/school.dart';
import '/common/models/student.dart';
import '/common/models/teacher.dart';
import '/common/models/visiting_priority.dart';
import '/common/providers/enterprises_provider.dart';
import '/common/providers/internships_provider.dart';
import '/common/providers/schools_provider.dart';
import '/common/providers/students_provider.dart';
import '/common/providers/teachers_provider.dart';
import '/misc/job_data_file_service.dart';

bool hasDummyData(context) {
  final teachers = TeachersProvider.of(context, listen: false);
  final enterprises = EnterprisesProvider.of(context, listen: false);
  final internships = InternshipsProvider.of(context, listen: false);
  final students = StudentsProvider.of(context, listen: false);

  return teachers.isNotEmpty ||
      enterprises.isNotEmpty ||
      internships.isNotEmpty ||
      students.isNotEmpty;
}

Future<void> addAllDummyData(BuildContext context) async {
  final schools = SchoolsProvider.of(context, listen: false);
  final teachers = TeachersProvider.of(context, listen: false);
  final enterprises = EnterprisesProvider.of(context, listen: false);
  final internships = InternshipsProvider.of(context, listen: false);
  final students = StudentsProvider.of(context, listen: false);

  if (schools.isEmpty) await addDummySchools(schools);
  if (teachers.isEmpty) await addDummyTeachers(teachers, schools);
  if (enterprises.isEmpty) await addDummyEnterprises(enterprises, teachers);
  if (students.isEmpty) await addDummyStudents(students, teachers);
  if (internships.isEmpty) {
    await addDummyInterships(internships, students, enterprises, teachers);
  }
}

Future<void> addDummySchools(SchoolsProvider schools) async {
  schools.add(School(
    name: 'My lovely school Marie-Vic',
    address: (await Address.fromAddress('École Marie-Victorin, Montréal'))!,
  ));

  await _waitForDatabaseUpdate(schools, 1);
}

Future<void> addDummyTeachers(
    TeachersProvider teachers, SchoolsProvider schools) async {
  teachers.add(Teacher(
      firstName: 'Roméo',
      lastName: 'Montaigu',
      schoolId: schools[0].id,
      email: 'romeo.montaigu@shakespeare.qc'));
  teachers.add(Teacher(
      id: teachers.currentTeacherId,
      firstName: 'Juliette',
      lastName: 'Capulet',
      schoolId: schools[0].id,
      email: 'juliette.capulet@shakespeare.qc'));
  teachers.add(Teacher(
      firstName: 'Tybalt',
      lastName: 'Capulet',
      schoolId: schools[0].id,
      email: 'tybalt.capulet@shakespeare.qc'));
  teachers.add(Teacher(
      firstName: 'Benvolio',
      lastName: 'Montaigu',
      schoolId: schools[0].id,
      email: 'benvolio.montaigu@shakespeare.qc'));

  await _waitForDatabaseUpdate(teachers, 4);
}

Future<void> addDummyEnterprises(
    EnterprisesProvider enterprises, TeachersProvider teachers) async {
  JobList jobs = JobList();
  jobs.add(
    Job(
      specialization: ActivitySectorsService.sectors[2].specializations[9],
      positionsOffered: 1,
    ),
  );
  jobs.add(
    Job(
      specialization: ActivitySectorsService.sectors[0].specializations[7],
      positionsOffered: 2,
    ),
  );

  enterprises.add(
    Enterprise(
      name: 'Metro Gagnon',
      activityTypes: {activityTypes[2], activityTypes[5], activityTypes[10]},
      recrutedBy: teachers[0].id,
      shareWith: 'Tout le monde',
      jobs: jobs,
      contactName: 'Marc Arcand',
      contactFunction: 'Directeur',
      contactPhone: '514 999 6655',
      contactEmail: 'm.arcand@email.com',
      address: Address(
          civicNumber: 1853,
          street: 'Chem. Rockland',
          city: 'Mont-Royal',
          postalCode: 'H3P 2Y7'),
      phone: '514 999 6655',
      fax: '514 999 6600',
      website: 'fausse.ca',
      headquartersAddress: Address(
          civicNumber: 1853,
          street: 'Chem. Rockland',
          city: 'Mont-Royal',
          postalCode: 'H3P 2Y7'),
      neq: '4567900954',
    ),
  );

  jobs = JobList();
  jobs.add(
    Job(
      specialization: ActivitySectorsService.sectors[0].specializations[7],
      positionsOffered: 3,
    ),
  );
  enterprises.add(
    Enterprise(
      name: 'Jean Coutu',
      activityTypes: {activityTypes[20], activityTypes[5]},
      recrutedBy: teachers[1].id,
      shareWith: 'Personne',
      jobs: jobs,
      contactName: 'Caroline Mercier',
      contactFunction: 'Assistante-gérante',
      contactPhone: '514 123 4567 poste 123',
      contactEmail: 'c.mercier@email.com',
      address: Address(
          civicNumber: 4885,
          street: 'Henri-Bourassa Blvd Ouest',
          city: 'Montréal',
          postalCode: 'H3L 1P3'),
      phone: '514 123 4567',
      fax: '514 123 4560',
      website: 'example.com',
      headquartersAddress: Address(
          civicNumber: 4885,
          street: 'Henri-Bourassa Blvd Ouest',
          city: 'Montréal',
          postalCode: 'H3L 1P3'),
      neq: '1234567891',
    ),
  );

  jobs = JobList();
  jobs.add(
    Job(
      specialization: ActivitySectorsService.sectors[9].specializations[3],
      positionsOffered: 1,
    ),
  );
  enterprises.add(
    Enterprise(
      name: 'Auto Care',
      activityTypes: {activityTypes[12], activityTypes[18]},
      recrutedBy: teachers[0].id,
      shareWith: 'Tout le monde',
      jobs: jobs,
      contactName: 'Denis Rondeau',
      contactFunction: 'Propriétaire',
      contactPhone: '438 987 6543',
      contactEmail: 'd.rondeau@email.com',
      address: Address(
          civicNumber: 8490,
          street: 'Rue Saint-Dominique',
          city: 'Montréal',
          postalCode: 'H2P 2L5'),
      phone: '438 987 6543',
      fax: '',
      website: '',
      headquartersAddress: Address(
          civicNumber: 8490,
          street: 'Rue Saint-Dominique',
          city: 'Montréal',
          postalCode: 'H2P 2L5'),
      neq: '5679011975',
    ),
  );

  jobs = JobList();
  jobs.add(
    Job(
      specialization: ActivitySectorsService.sectors[9].specializations[3],
      positionsOffered: 2,
    ),
  );
  enterprises.add(
    Enterprise(
      name: 'Auto Repair',
      activityTypes: {activityTypes[12], activityTypes[18]},
      recrutedBy: teachers[2].id,
      shareWith: 'Tout le monde',
      jobs: jobs,
      contactName: 'Claudio Brodeur',
      contactFunction: 'Propriétaire',
      contactPhone: '514 235 6789',
      contactEmail: 'c.brodeur@email.com',
      address: Address(
          civicNumber: 10142,
          street: 'Boul. Saint-Laurent',
          city: 'Montréal',
          postalCode: 'H3L 2N7'),
      phone: '514 235 6789',
      fax: '514 321 9870',
      website: 'fausse.ca',
      headquartersAddress: Address(
          civicNumber: 10142,
          street: 'Boul. Saint-Laurent',
          city: 'Montréal',
          postalCode: 'H3L 2N7'),
      neq: '2345678912',
    ),
  );

  jobs = JobList();
  jobs.add(
    Job(
      specialization: ActivitySectorsService.sectors[2].specializations[9],
      positionsOffered: 2,
    ),
  );

  enterprises.add(
    Enterprise(
      name: 'Boucherie Marien',
      activityTypes: {activityTypes[2], activityTypes[5]},
      recrutedBy: teachers[0].id,
      shareWith: 'Tout le monde',
      jobs: jobs,
      contactName: 'Brigitte Samson',
      contactFunction: 'Gérante',
      contactPhone: '438 888 2222',
      contactEmail: 'b.samson@email.com',
      address: Address(
          civicNumber: 8921,
          street: 'Rue Lajeunesse',
          city: 'Montréal',
          postalCode: 'H2M 1S1'),
      phone: '514 321 9876',
      fax: '514 321 9870',
      website: 'fausse.ca',
      headquartersAddress: Address(
          civicNumber: 8921,
          street: 'Rue Lajeunesse',
          city: 'Montréal',
          postalCode: 'H2M 1S1'),
      neq: '1234567080',
    ),
  );

  jobs = JobList();
  jobs.add(
    Job(
      specialization: ActivitySectorsService.sectors[2].specializations[7],
      positionsOffered: 1,
    ),
  );

  enterprises.add(
    Enterprise(
      name: 'IGA',
      activityTypes: {activityTypes[10], activityTypes[29]},
      recrutedBy: teachers[0].id,
      shareWith: 'Tout le monde',
      jobs: jobs,
      contactName: 'Gabrielle Fortin',
      contactFunction: 'Gérante',
      contactPhone: '514 111 2222',
      contactEmail: 'g.fortin@email.com',
      address: Address(
          civicNumber: 1415,
          street: 'Rue Jarry E',
          city: 'Montréal',
          postalCode: 'H2E 1A7'),
      phone: '514 111 2222',
      fax: '514 111 2200',
      website: 'fausse.ca',
      headquartersAddress: Address(
          civicNumber: 7885,
          street: 'Rue Lajeunesse',
          city: 'Montréal',
          postalCode: 'H2M 1S1'),
      neq: '1234560522',
    ),
  );

  jobs = JobList();
  jobs.add(
    Job(
      specialization: ActivitySectorsService.sectors[0].specializations[7],
      positionsOffered: 2,
    ),
  );

  enterprises.add(
    Enterprise(
      name: 'Pharmaprix',
      activityTypes: {activityTypes[20], activityTypes[5]},
      recrutedBy: teachers[3].id,
      shareWith: 'Tout le monde',
      jobs: jobs,
      contactName: 'Jessica Marcotte',
      contactFunction: 'Pharmacienne',
      contactPhone: '514 111 2222',
      contactEmail: 'g.fortin@email.com',
      address: Address(
          civicNumber: 3611,
          street: 'Rue Jarry E',
          city: 'Montréal',
          postalCode: 'H1Z 2G1'),
      phone: '514 654 5444',
      fax: '514 654 5445',
      website: 'fausse.ca',
      headquartersAddress: Address(
          civicNumber: 3611,
          street: 'Rue Jarry E',
          city: 'Montréal',
          postalCode: 'H1Z 2G1'),
      neq: '3456789933',
    ),
  );

  jobs = JobList();
  jobs.add(
    Job(
      specialization: ActivitySectorsService.sectors[2].specializations[14],
      positionsOffered: 1,
    ),
  );

  enterprises.add(
    Enterprise(
      name: 'Subway',
      activityTypes: {activityTypes[24], activityTypes[27]},
      recrutedBy: teachers[3].id,
      shareWith: 'Tout le monde',
      jobs: jobs,
      contactName: 'Carlos Rodriguez',
      contactFunction: 'Gérant',
      contactPhone: '514 555 3333',
      contactEmail: 'c.rodriguez@email.com',
      address: Address(
          civicNumber: 775,
          street: 'Rue Chabanel O',
          city: 'Montréal',
          postalCode: 'H4N 3J7'),
      phone: '514 555 7891',
      fax: '',
      website: 'fausse.ca',
      headquartersAddress: null,
      neq: '6790122996',
    ),
  );

  jobs = JobList();
  jobs.add(
    Job(
      specialization: ActivitySectorsService.sectors[0].specializations[7],
      positionsOffered: 3,
    ),
  );

  enterprises.add(
    Enterprise(
      name: 'Walmart',
      activityTypes: {activityTypes[5], activityTypes[15], activityTypes[29]},
      recrutedBy: teachers[0].id,
      shareWith: 'Tout le monde',
      jobs: jobs,
      contactName: 'France Boissonneau',
      contactFunction: 'Directrice des Ressources Humaines',
      contactPhone: '514 879 8654 poste 1112',
      contactEmail: 'f.boissonneau@email.com',
      address: Address(
          civicNumber: 10345,
          street: 'Ave Christophe-Colomb',
          city: 'Montréal',
          postalCode: 'H2C 2V1'),
      phone: '514 879 8654',
      fax: '514 879 8000',
      website: 'fausse.ca',
      headquartersAddress: Address(
          civicNumber: 10345,
          street: 'Ave Christophe-Colomb',
          city: 'Montréal',
          postalCode: 'H2C 2V1'),
      neq: '9012345038',
    ),
  );

  await _waitForDatabaseUpdate(enterprises, 9);
}

Future<void> addDummyStudents(
    StudentsProvider students, TeachersProvider teachers) async {
  students.add(
    Student(
      firstName: 'Cedric',
      lastName: 'Masson',
      dateBirth: DateTime.now(),
      email: 'c.masson@email.com',
      teacherId: teachers[0].id,
      program: 'FPT2',
      group: '550',
      address: await Address.fromAddress(
          '7248 Rue D\'Iberville, Montréal, QC H2E 2Y6'),
      phone: '514 321 8888',
      contact: Person(
          firstName: 'Paul',
          lastName: 'Masson',
          phone: '514 321 9876',
          email: 'p.masson@email.com'),
      contactLink: 'Père',
    ),
  );

  students.add(
    Student(
      firstName: 'Thomas',
      lastName: 'Caron',
      dateBirth: DateTime.now(),
      email: 't.caron@email.com',
      teacherId: teachers.currentTeacherId,
      program: 'FPT3',
      group: '885',
      contact: Person(
          firstName: 'Joe',
          lastName: 'Caron',
          phone: '514 321 9876',
          email: 'j.caron@email.com'),
      contactLink: 'Père',
      address:
          await Address.fromAddress('6622 16e Avenue, Montréal, QC H1X 2T2'),
      phone: '514 222 3344',
    ),
  );

  students.add(
    Student(
      firstName: 'Mikael',
      lastName: 'Boucher',
      dateBirth: DateTime.now(),
      email: 'm.boucher@email.com',
      teacherId: teachers.currentTeacherId,
      program: 'FPT3',
      group: '885',
      contact: Person(
          firstName: 'Nicole',
          lastName: 'Lefranc',
          phone: '514 321 9876',
          email: 'n.lefranc@email.com'),
      contactLink: 'Mère',
      address: await Address.fromAddress('6723 25e Ave, Montréal, QC H1T 3M1'),
      phone: '514 333 4455',
    ),
  );

  students.add(
    Student(
      firstName: 'Kevin',
      lastName: 'Leblanc',
      dateBirth: DateTime.now(),
      email: 'k.leblanc@email.com',
      teacherId: teachers.currentTeacherId,
      program: 'FPT2',
      group: '550',
      contact: Person(
          firstName: 'Martine',
          lastName: 'Gagnon',
          phone: '514 321 9876',
          email: 'm.gagnon@email.com'),
      contactLink: 'Mère',
      address:
          await Address.fromAddress('6655 33e Avenue, Montréal, QC H1T 3B9'),
      phone: '514 999 8877',
    ),
  );

  students.add(
    Student(
      firstName: 'Simon',
      lastName: 'Gingras',
      dateBirth: DateTime.now(),
      email: 's.gingras@email.com',
      teacherId: teachers[0].id,
      program: 'FMS',
      group: '789',
      contact: Person(
          firstName: 'Raoul',
          lastName: 'Gingras',
          email: 'r.gingras@email.com',
          phone: '514 321 9876'),
      contactLink: 'Père',
      address: await Address.fromAddress(
          '4517 Rue d\'Assise, Saint-Léonard, QC H1R 1W2'),
      phone: '514 888 7766',
    ),
  );

  students.add(
    Student(
      firstName: 'Diego',
      lastName: 'Vargas',
      dateBirth: DateTime.now(),
      email: 'd.vargas@email.com',
      teacherId: teachers.currentTeacherId,
      program: 'FMS',
      group: '789',
      contact: Person(
          firstName: 'Laura',
          lastName: 'Vargas',
          phone: '514 321 9876',
          email: 'l.vargas@email.com'),
      contactLink: 'Mère',
      address: await Address.fromAddress(
          '8204 Rue de Blois, Saint-Léonard, QC H1R 2X1'),
      phone: '514 444 5566',
    ),
  );

  students.add(
    Student(
      firstName: 'Geneviève',
      lastName: 'Tremblay',
      dateBirth: DateTime.now(),
      email: 'g.tremblay@email.com',
      teacherId: teachers.currentTeacherId,
      program: 'FPT3',
      group: '885',
      contact: Person(
          firstName: 'Vincent',
          lastName: 'Tremblay',
          phone: '514 321 9876',
          email: 'v.tremblay@email.com'),
      contactLink: 'Père',
      address: await Address.fromAddress(
          '8358 Rue Jean-Nicolet, Saint-Léonard, QC H1R 2R2'),
      phone: '514 555 9988',
    ),
  );

  students.add(
    Student(
      firstName: 'Vincent',
      lastName: 'Picard',
      dateBirth: DateTime.now(),
      email: 'v.picard@email.com',
      teacherId: teachers.currentTeacherId,
      program: 'FMS',
      group: '789',
      contact: Person(
          firstName: 'Jean-François',
          lastName: 'Picard',
          phone: '514 321 9876',
          email: 'jp.picard@email.com'),
      contactLink: 'Père',
      address: await Address.fromAddress(
          '8382 Rue du Laus, Saint-Léonard, QC H1R 2P4'),
      phone: '514 778 8899',
    ),
  );

  students.add(
    Student(
      firstName: 'Vanessa',
      lastName: 'Monette',
      dateBirth: DateTime.now(),
      email: 'v.monette@email.com',
      teacherId: teachers.currentTeacherId,
      program: 'FMS',
      group: '789',
      contact: Person(
          firstName: 'Stéphane',
          lastName: 'Monette',
          phone: '514 321 9876',
          email: 's.monette@email.com'),
      contactLink: 'Père',
      address: await Address.fromAddress(
          '6865 Rue Chaillot, Saint-Léonard, QC H1T 3R5'),
      phone: '514 321 6655',
    ),
  );

  students.add(
    Student(
      firstName: 'Mélissa',
      lastName: 'Poulain',
      dateBirth: DateTime.now(),
      email: 'm.poulain@email.com',
      teacherId: teachers.currentTeacherId,
      program: 'FMS',
      group: '789',
      contact: Person(
          firstName: 'Mathieu',
          lastName: 'Poulain',
          phone: '514 321 9876',
          email: 'm.poulain@email.com'),
      contactLink: 'Père',
      address:
          await Address.fromAddress('6585 Rue Lemay, Montréal, QC H1T 2L8'),
      phone: '514 567 9999',
    ),
  );

  await _waitForDatabaseUpdate(students, 10);
}

Future<void> addDummyInterships(
  InternshipsProvider internships,
  StudentsProvider students,
  EnterprisesProvider enterprises,
  TeachersProvider teachers,
) async {
  final rng = Random(); // Generate random priorities

  internships.add(Internship(
    studentId: students[0].id,
    teacherId: teachers.currentTeacherId,
    isTransfering: true,
    enterpriseId: enterprises[0].id,
    jobId: enterprises[0].jobs[0].id,
    extraJobsId: [],
    program: '-1',
    visitingPriority: VisitingPriority.values[rng.nextInt(3)],
    supervisor: Person(firstName: 'Nobody', lastName: 'Forever'),
    date: DateTimeRange(
        start: DateTime.now(),
        end: DateTime.now().add(Duration(days: rng.nextInt(90)))),
    schedule: [
      Schedule(
        dayOfWeek: Day.monday,
        start: const TimeOfDay(hour: 9, minute: 00),
        end: const TimeOfDay(hour: 17, minute: 00),
      ),
      Schedule(
        dayOfWeek: Day.tuesday,
        start: const TimeOfDay(hour: 9, minute: 00),
        end: const TimeOfDay(hour: 17, minute: 00),
      ),
      Schedule(
        dayOfWeek: Day.wednesday,
        start: const TimeOfDay(hour: 9, minute: 00),
        end: const TimeOfDay(hour: 17, minute: 00),
      ),
      Schedule(
        dayOfWeek: Day.thursday,
        start: const TimeOfDay(hour: 9, minute: 00),
        end: const TimeOfDay(hour: 17, minute: 00),
      ),
      Schedule(
        dayOfWeek: Day.friday,
        start: const TimeOfDay(hour: 9, minute: 00),
        end: const TimeOfDay(hour: 17, minute: 00),
      ),
    ],
    protection: [],
    uniform: '-1',
  ));

  internships.add(Internship(
    studentId: students[1].id,
    teacherId: teachers.currentTeacherId,
    enterpriseId: enterprises[0].id,
    jobId: enterprises[0].jobs[0].id,
    extraJobsId: [],
    program: '-1',
    visitingPriority: VisitingPriority.values[rng.nextInt(3)],
    supervisor: Person(firstName: 'Nobody', lastName: 'Forever'),
    date: DateTimeRange(
        start: DateTime.now(),
        end: DateTime.now().add(Duration(days: rng.nextInt(90)))),
    schedule: [
      Schedule(
        dayOfWeek: Day.monday,
        start: const TimeOfDay(hour: 9, minute: 00),
        end: const TimeOfDay(hour: 17, minute: 00),
      ),
      Schedule(
        dayOfWeek: Day.tuesday,
        start: const TimeOfDay(hour: 9, minute: 00),
        end: const TimeOfDay(hour: 17, minute: 00),
      ),
      Schedule(
        dayOfWeek: Day.wednesday,
        start: const TimeOfDay(hour: 9, minute: 00),
        end: const TimeOfDay(hour: 17, minute: 00),
      ),
      Schedule(
        dayOfWeek: Day.thursday,
        start: const TimeOfDay(hour: 9, minute: 00),
        end: const TimeOfDay(hour: 17, minute: 00),
      ),
      Schedule(
        dayOfWeek: Day.friday,
        start: const TimeOfDay(hour: 9, minute: 00),
        end: const TimeOfDay(hour: 17, minute: 00),
      ),
    ],
    protection: [],
    uniform: '-1',
  ));

  internships.add(Internship(
    studentId: students[2].id,
    teacherId: teachers.currentTeacherId,
    enterpriseId: enterprises[1].id,
    jobId: enterprises[1].jobs[0].id,
    extraJobsId: [],
    program: '-1',
    visitingPriority: VisitingPriority.values[rng.nextInt(3)],
    supervisor: Person(firstName: 'Nobody', lastName: 'Forever'),
    date: DateTimeRange(
        start: DateTime.now(),
        end: DateTime.now().add(Duration(days: rng.nextInt(90)))),
    schedule: [
      Schedule(
        dayOfWeek: Day.monday,
        start: const TimeOfDay(hour: 9, minute: 00),
        end: const TimeOfDay(hour: 17, minute: 00),
      ),
      Schedule(
        dayOfWeek: Day.tuesday,
        start: const TimeOfDay(hour: 9, minute: 00),
        end: const TimeOfDay(hour: 17, minute: 00),
      ),
      Schedule(
        dayOfWeek: Day.wednesday,
        start: const TimeOfDay(hour: 9, minute: 00),
        end: const TimeOfDay(hour: 17, minute: 00),
      ),
      Schedule(
        dayOfWeek: Day.thursday,
        start: const TimeOfDay(hour: 9, minute: 00),
        end: const TimeOfDay(hour: 17, minute: 00),
      ),
    ],
    protection: [],
    uniform: '-1',
  ));

  internships.add(Internship(
    studentId: students[3].id,
    teacherId: teachers.currentTeacherId,
    enterpriseId: enterprises[2].id,
    jobId: enterprises[2].jobs[0].id,
    extraJobsId: [],
    program: '-1',
    visitingPriority: VisitingPriority.values[rng.nextInt(3)],
    supervisor: Person(firstName: 'Nobody', lastName: 'Forever'),
    date: DateTimeRange(
        start: DateTime.now(),
        end: DateTime.now().add(Duration(days: rng.nextInt(90)))),
    schedule: [
      Schedule(
        dayOfWeek: Day.monday,
        start: const TimeOfDay(hour: 9, minute: 00),
        end: const TimeOfDay(hour: 17, minute: 00),
      ),
      Schedule(
        dayOfWeek: Day.tuesday,
        start: const TimeOfDay(hour: 9, minute: 00),
        end: const TimeOfDay(hour: 17, minute: 00),
      ),
      Schedule(
        dayOfWeek: Day.wednesday,
        start: const TimeOfDay(hour: 9, minute: 00),
        end: const TimeOfDay(hour: 17, minute: 00),
      ),
    ],
    protection: [],
    uniform: '-1',
  ));

  internships.add(Internship(
    studentId: students[4].id,
    teacherId: teachers[0].id,
    enterpriseId: enterprises[3].id,
    jobId: enterprises[3].jobs[0].id,
    extraJobsId: [],
    program: '-1',
    visitingPriority: VisitingPriority.values[rng.nextInt(3)],
    supervisor: Person(firstName: 'Nobody', lastName: 'Forever'),
    date: DateTimeRange(
        start: DateTime.now(),
        end: DateTime.now().add(Duration(days: rng.nextInt(90)))),
    schedule: [
      Schedule(
        dayOfWeek: Day.monday,
        start: const TimeOfDay(hour: 9, minute: 00),
        end: const TimeOfDay(hour: 17, minute: 00),
      ),
      Schedule(
        dayOfWeek: Day.wednesday,
        start: const TimeOfDay(hour: 9, minute: 00),
        end: const TimeOfDay(hour: 17, minute: 00),
      ),
      Schedule(
        dayOfWeek: Day.friday,
        start: const TimeOfDay(hour: 9, minute: 00),
        end: const TimeOfDay(hour: 17, minute: 00),
      ),
    ],
    protection: [],
    uniform: '-1',
  ));

  internships.add(Internship(
    studentId: students[5].id,
    teacherId: teachers.currentTeacherId,
    enterpriseId: enterprises[4].id,
    jobId: enterprises[4].jobs[0].id,
    extraJobsId: [],
    program: '-1',
    visitingPriority: VisitingPriority.values[rng.nextInt(3)],
    supervisor: Person(firstName: 'Nobody', lastName: 'Forever'),
    date: DateTimeRange(
        start: DateTime.now(),
        end: DateTime.now().add(Duration(days: rng.nextInt(90)))),
    schedule: [
      Schedule(
        dayOfWeek: Day.monday,
        start: const TimeOfDay(hour: 9, minute: 00),
        end: const TimeOfDay(hour: 17, minute: 00),
      ),
      Schedule(
        dayOfWeek: Day.tuesday,
        start: const TimeOfDay(hour: 9, minute: 00),
        end: const TimeOfDay(hour: 17, minute: 00),
      ),
      Schedule(
        dayOfWeek: Day.wednesday,
        start: const TimeOfDay(hour: 9, minute: 00),
        end: const TimeOfDay(hour: 17, minute: 00),
      ),
      Schedule(
        dayOfWeek: Day.thursday,
        start: const TimeOfDay(hour: 9, minute: 00),
        end: const TimeOfDay(hour: 17, minute: 00),
      ),
      Schedule(
        dayOfWeek: Day.friday,
        start: const TimeOfDay(hour: 9, minute: 00),
        end: const TimeOfDay(hour: 17, minute: 00),
      ),
    ],
    protection: [],
    uniform: '-1',
  ));

  internships.add(Internship(
    studentId: students[8].id,
    teacherId: teachers.currentTeacherId,
    enterpriseId: enterprises[4].id,
    jobId: enterprises[4].jobs[0].id,
    extraJobsId: [],
    program: '-1',
    visitingPriority: VisitingPriority.values[rng.nextInt(3)],
    supervisor: Person(firstName: 'Nobody', lastName: 'Forever'),
    date: DateTimeRange(
        start: DateTime.now(),
        end: DateTime.now().add(Duration(days: rng.nextInt(90)))),
    schedule: [
      Schedule(
        dayOfWeek: Day.monday,
        start: const TimeOfDay(hour: 9, minute: 00),
        end: const TimeOfDay(hour: 17, minute: 00),
      ),
      Schedule(
        dayOfWeek: Day.tuesday,
        start: const TimeOfDay(hour: 9, minute: 00),
        end: const TimeOfDay(hour: 17, minute: 00),
      ),
      Schedule(
        dayOfWeek: Day.wednesday,
        start: const TimeOfDay(hour: 9, minute: 00),
        end: const TimeOfDay(hour: 17, minute: 00),
      ),
      Schedule(
        dayOfWeek: Day.thursday,
        start: const TimeOfDay(hour: 9, minute: 00),
        end: const TimeOfDay(hour: 17, minute: 00),
      ),
      Schedule(
        dayOfWeek: Day.friday,
        start: const TimeOfDay(hour: 9, minute: 00),
        end: const TimeOfDay(hour: 17, minute: 00),
      ),
    ],
    protection: [],
    uniform: '-1',
  ));

  await _waitForDatabaseUpdate(internships, 7);
}

Future<void> _waitForDatabaseUpdate(
    FirebaseListProvided list, int expectedLength) async {
// Wait for the database to add all the students
  while (list.length < expectedLength) {
    await Future.delayed(const Duration(milliseconds: 250));
  }
}
