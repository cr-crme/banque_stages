//! Remove this file before production

import 'dart:math';

import 'package:flutter/material.dart';

import '/common/models/enterprise.dart';
import '/common/models/internship.dart';
import '/common/models/job.dart';
import '/common/models/job_list.dart';
import '/common/models/person.dart';
import '/common/models/student.dart';
import '/common/models/visiting_priority.dart';
import '/common/providers/enterprises_provider.dart';
import '/common/providers/internships_provider.dart';
import '/common/providers/students_provider.dart';
import '/misc/job_data_file_service.dart';

void addDummyEnterprises(EnterprisesProvider enterprises) {
  // TODO: Add missing fields in the dummy jobs
  JobList jobs = JobList();
  jobs.add(
    Job(
      activitySector: JobDataFileService.sectors[2],
      specialization: JobDataFileService.sectors[2].specializations[9],
      positionsOffered: 1,
      positionsOccupied: 1,
    ),
  );
  jobs.add(
    Job(
      activitySector: JobDataFileService.sectors[0],
      specialization: JobDataFileService.sectors[0].specializations[7],
    ),
  );

  enterprises.add(
    Enterprise(
      name: 'Metro Gagnon',
      activityTypes: {activityTypes[2], activityTypes[5], activityTypes[10]},
      recrutedBy: 'Louise Talbot',
      shareWith: 'Tout le monde',
      jobs: jobs,
      contactName: 'Marc Arcand',
      contactFunction: 'Directeur',
      contactPhone: '514 999 6655',
      contactEmail: 'm.arcand@email.com',
      address: '1853 Chem. Rockland, Mont-Royal, QC H3P 2Y7',
      phone: '514 999 6655',
      fax: '514 999 6600',
      website: 'fausse.ca',
      headquartersAddress: '1853 Chem. Rockland, Mont-Royal, QC H3P 2Y7',
      neq: '4567900954',
    ),
  );

  jobs = JobList();
  jobs.add(
    Job(
      activitySector: JobDataFileService.sectors[0],
      specialization: JobDataFileService.sectors[0].specializations[7],
      positionsOffered: 3,
      positionsOccupied: 3,
    ),
  );
  enterprises.add(
    Enterprise(
      name: 'Jean Coutu',
      activityTypes: {activityTypes[20], activityTypes[5]},
      recrutedBy: 'Judith Larivée',
      shareWith: 'Personne',
      jobs: jobs,
      contactName: 'Caroline Mercier',
      contactFunction: 'Assistante-gérante',
      contactPhone: '514 123 4567 poste 123',
      contactEmail: 'c.mercier@email.com',
      address: '4885 Henri-Bourassa Blvd Ouest, Montréal, QC H3L 1P3',
      phone: '514 123 4567',
      fax: '514 123 4560',
      website: 'example.com',
      headquartersAddress:
          '4885 Henri-Bourassa Blvd Ouest, Montréal, QC H3L 1P3',
      neq: '1234567891',
    ),
  );

  jobs = JobList();
  jobs.add(
    Job(
      activitySector: JobDataFileService.sectors[9],
      specialization: JobDataFileService.sectors[9].specializations[3],
      positionsOffered: 1,
      positionsOccupied: 1,
    ),
  );
  enterprises.add(
    Enterprise(
      name: 'Auto Care',
      activityTypes: {activityTypes[12], activityTypes[18]},
      recrutedBy: 'François Duchemin',
      shareWith: 'Tout le monde',
      jobs: jobs,
      contactName: 'Denis Rondeau',
      contactFunction: 'Propriétaire',
      contactPhone: '438 987 6543',
      contactEmail: 'd.rondeau@email.com',
      address: '8490 Rue Saint-Dominique, Montréal, QC H2P 2L5',
      phone: '438 987 6543',
      fax: '',
      website: '',
      headquartersAddress: '8490 Rue Saint-Dominique, Montréal, QC H2P 2L5',
      neq: '5679011975',
    ),
  );

  jobs = JobList();
  jobs.add(
    Job(
      activitySector: JobDataFileService.sectors[9],
      specialization: JobDataFileService.sectors[9].specializations[3],
      positionsOffered: 2,
      positionsOccupied: 1,
    ),
  );
  enterprises.add(
    Enterprise(
      name: 'Auto Repair',
      activityTypes: {activityTypes[12], activityTypes[18]},
      recrutedBy: 'Charlène Cantin',
      shareWith: 'Tout le monde',
      jobs: jobs,
      contactName: 'Claudio Brodeur',
      contactFunction: 'Propriétaire',
      contactPhone: '514 235 6789',
      contactEmail: 'c.brodeur@email.com',
      address: '10142 Boul. Saint-Laurent, Montréal, QC H3L 2N7',
      phone: '514 235 6789',
      fax: '514 321 9870',
      website: 'fausse.ca',
      headquartersAddress: '10142 Boul. Saint-Laurent, Montréal, QC H3L 2N7',
      neq: '2345678912',
    ),
  );

  jobs = JobList();
  jobs.add(
    Job(
      activitySector: JobDataFileService.sectors[2],
      specialization: JobDataFileService.sectors[2].specializations[9],
      positionsOffered: 2,
      positionsOccupied: 1,
    ),
  );

  enterprises.add(
    Enterprise(
      name: 'Boucherie Marien',
      activityTypes: {activityTypes[2], activityTypes[5]},
      recrutedBy: 'Stéphane Tremblay',
      shareWith: 'Tout le monde',
      jobs: jobs,
      contactName: 'Brigitte Samson',
      contactFunction: 'Gérante',
      contactPhone: '438 888 2222',
      contactEmail: 'b.samson@email.com',
      address: '8921 Rue Lajeunesse, Montréal, QC H2M 1S1',
      phone: '514 321 9876',
      fax: '514 321 9870',
      website: 'fausse.ca',
      headquartersAddress: '8921 Rue Lajeunesse, Montréal, QC H2M 1S1',
      neq: '1234567080',
    ),
  );

  jobs = JobList();
  jobs.add(
    Job(
      activitySector: JobDataFileService.sectors[2],
      specialization: JobDataFileService.sectors[2].specializations[7],
      positionsOffered: 1,
      positionsOccupied: 1,
    ),
  );

  enterprises.add(
    Enterprise(
      name: 'IGA',
      activityTypes: {activityTypes[10], activityTypes[29]},
      recrutedBy: 'Christian Perez',
      shareWith: 'Tout le monde',
      jobs: jobs,
      contactName: 'Gabrielle Fortin',
      contactFunction: 'Gérante',
      contactPhone: '514 111 2222',
      contactEmail: 'g.fortin@email.com',
      address: '1415 Rue Jarry E, Montréal, QC H2E 1A7',
      phone: '514 111 2222',
      fax: '514 111 2200',
      website: 'fausse.ca',
      headquartersAddress: '7885 Rue Lajeunesse, Montréal, QC H2M 1S1',
      neq: '1234560522',
    ),
  );

  jobs = JobList();
  jobs.add(
    Job(
      activitySector: JobDataFileService.sectors[0],
      specialization: JobDataFileService.sectors[0].specializations[7],
      positionsOffered: 2,
      positionsOccupied: 1,
    ),
  );

  enterprises.add(
    Enterprise(
      name: 'Pharmaprix',
      activityTypes: {activityTypes[20], activityTypes[5]},
      recrutedBy: 'Louise Talbot',
      shareWith: 'Tout le monde',
      jobs: jobs,
      contactName: 'Jessica Marcotte',
      contactFunction: 'Pharmacienne',
      contactPhone: '514 111 2222',
      contactEmail: 'g.fortin@email.com',
      address: '3611 Rue Jarry E, Montréal, QC H1Z 2G1',
      phone: '514 654 5444',
      fax: '514 654 5445',
      website: 'fausse.ca',
      headquartersAddress: '3611 Rue Jarry E, Montréal, QC H1Z 2G1',
      neq: '3456789933',
    ),
  );

  jobs = JobList();
  jobs.add(
    Job(
      activitySector: JobDataFileService.sectors[2],
      specialization: JobDataFileService.sectors[2].specializations[14],
      positionsOffered: 1,
      positionsOccupied: 1,
    ),
  );

  enterprises.add(
    Enterprise(
      name: 'Subway',
      activityTypes: {activityTypes[24], activityTypes[27]},
      recrutedBy: 'Patricia Filion',
      shareWith: 'Tout le monde',
      jobs: jobs,
      contactName: 'Carlos Rodriguez',
      contactFunction: 'Gérant',
      contactPhone: '514 555 3333',
      contactEmail: 'c.rodriguez@email.com',
      address: '775 Rue Chabanel O, Montréal, QC H4N 3J7',
      phone: '514 555 7891',
      fax: '',
      website: 'fausse.ca',
      headquartersAddress: '',
      neq: '6790122996',
    ),
  );

  jobs = JobList();
  jobs.add(
    Job(
      activitySector: JobDataFileService.sectors[0],
      specialization: JobDataFileService.sectors[0].specializations[7],
      positionsOffered: 3,
      positionsOccupied: 2,
    ),
  );

  enterprises.add(
    Enterprise(
      name: 'Walmart',
      activityTypes: {activityTypes[5], activityTypes[15], activityTypes[29]},
      recrutedBy: 'Caroline Mercier',
      shareWith: 'Tout le monde',
      jobs: jobs,
      contactName: 'France Boissonneau',
      contactFunction: 'Directrice des Ressources Humaines',
      contactPhone: '514 879 8654 poste 1112',
      contactEmail: 'f.boissonneau@email.com',
      address: '10345 Ave Christophe-Colomb, Montreal, QC H2C 2V1',
      phone: '514 879 8654',
      fax: '514 879 8000',
      website: 'fausse.ca',
      headquartersAddress: '10345 Ave Christophe-Colomb, Montreal, QC H2C 2V1',
      neq: '9012345038',
    ),
  );
}

Future<void> addDummyStudents(StudentsProvider students,
    InternshipsProvider internships, EnterprisesProvider enterprises) async {
  if (enterprises.isEmpty) {
    addDummyEnterprises(enterprises);
    while (enterprises.isEmpty) {
      await Future.delayed(const Duration(seconds: 1));
    }
  }
  final rng = Random();

  var student = Student(
    firstName: 'Cedric',
    lastName: 'Masson',
    dateBirth: DateTime.now(),
    email: 'c.masson@email.com',
    program: 'FPT2',
    group: '550',
    address: '7248 Rue D\'Iberville, Montréal, QC H2E 2Y6',
    phone: '514 321 8888',
    contact: Person(
        firstName: 'Paul',
        lastName: 'Masson',
        phone: '514 321 9876',
        email: 'p.masson@email.com'),
    contactLink: 'Père',
  );
  students.add(student);
  internships.add(Internship(
    teacherId: '-1',
    studentId: student.id,
    enterpriseId: enterprises[0].id,
    jobId: enterprises[0].jobs[0].specialization!.id,
    type: '-1',
    visitingPriority: VisitingPriority.values[rng.nextInt(3)],
    supervisorName: '-1',
    supervisorPhone: '-1',
    supervisorEmail: '-1',
    date: DateTimeRange(
        start: DateTime.now(),
        end: DateTime.now().add(Duration(days: rng.nextInt(90)))),
    protection: [],
    uniform: '-1',
  ));

  student = Student(
    firstName: 'Thomas',
    lastName: 'Caron',
    dateBirth: DateTime.now(),
    email: 't.caron@email.com',
    program: 'FPT3',
    group: '885',
    contact: Person(
        firstName: 'Joe',
        lastName: 'Caron',
        phone: '514 321 9876',
        email: 'j.caron@email.com'),
    contactLink: 'Père',
    address: '6622 16e Avenue, Montréal, QC H1X 2T2',
    phone: '514 222 3344',
  );
  students.add(student);
  internships.add(Internship(
    teacherId: '-1',
    studentId: student.id,
    enterpriseId: enterprises[0].id,
    jobId: enterprises[0].jobs[0].specialization!.id,
    type: '-1',
    visitingPriority: VisitingPriority.values[rng.nextInt(3)],
    supervisorName: '-1',
    supervisorPhone: '-1',
    supervisorEmail: '-1',
    date: DateTimeRange(
        start: DateTime.now(),
        end: DateTime.now().add(Duration(days: rng.nextInt(90)))),
    protection: [],
    uniform: '-1',
  ));

  student = Student(
    firstName: 'Mikael',
    lastName: 'Boucher',
    dateBirth: DateTime.now(),
    email: 'm.boucher@email.com',
    program: 'FPT3',
    group: '885',
    contact: Person(
        firstName: 'Nicole',
        lastName: 'Lefranc',
        phone: '514 321 9876',
        email: 'n.lefranc@email.com'),
    contactLink: 'Mère',
    address: '6723 25e Ave, Montréal, QC H1T 3M1',
    phone: '514 333 4455',
  );
  students.add(student);
  internships.add(Internship(
    teacherId: '-1',
    studentId: student.id,
    enterpriseId: enterprises[1].id,
    jobId: enterprises[1].jobs[0].specialization!.id,
    type: '-1',
    visitingPriority: VisitingPriority.values[rng.nextInt(3)],
    supervisorName: '-1',
    supervisorPhone: '-1',
    supervisorEmail: '-1',
    date: DateTimeRange(
        start: DateTime.now(),
        end: DateTime.now().add(Duration(days: rng.nextInt(90)))),
    protection: [],
    uniform: '-1',
  ));

  student = Student(
    firstName: 'Kevin',
    lastName: 'Leblanc',
    dateBirth: DateTime.now(),
    email: 'k.leblanc@email.com',
    program: 'FPT2',
    group: '550',
    contact: Person(
        firstName: 'Martine',
        lastName: 'Gagnon',
        phone: '514 321 9876',
        email: 'm.gagnon@email.com'),
    contactLink: 'Mère',
    address: '6655 33e Avenue, Montréal, QC H1T 3B9',
    phone: '514 999 8877',
  );
  students.add(student);
  internships.add(Internship(
    teacherId: '-1',
    studentId: student.id,
    enterpriseId: enterprises[2].id,
    jobId: enterprises[2].jobs[0].specialization!.id,
    type: '-1',
    visitingPriority: VisitingPriority.values[rng.nextInt(3)],
    supervisorName: '-1',
    supervisorPhone: '-1',
    supervisorEmail: '-1',
    date: DateTimeRange(
        start: DateTime.now(),
        end: DateTime.now().add(Duration(days: rng.nextInt(90)))),
    protection: [],
    uniform: '-1',
  ));

  student = Student(
    firstName: 'Simon',
    lastName: 'Gingras',
    dateBirth: DateTime.now(),
    email: 's.gingras@email.com',
    program: 'FMS',
    group: '789',
    contact: Person(
        firstName: 'Raoul',
        lastName: 'Gingras',
        email: 'r.gingras@email.com',
        phone: '514 321 9876'),
    contactLink: 'Père',
    address: '4517 Rue d\'Assise, Saint-Léonard, QC H1R 1W2',
    phone: '514 888 7766',
  );
  students.add(student);
  internships.add(Internship(
    teacherId: '-1',
    studentId: student.id,
    enterpriseId: enterprises[3].id,
    jobId: enterprises[3].jobs[0].specialization!.id,
    type: '-1',
    visitingPriority: VisitingPriority.values[rng.nextInt(3)],
    supervisorName: '-1',
    supervisorPhone: '-1',
    supervisorEmail: '-1',
    date: DateTimeRange(
        start: DateTime.now(),
        end: DateTime.now().add(Duration(days: rng.nextInt(90)))),
    protection: [],
    uniform: '-1',
  ));

  student = Student(
    firstName: 'Diego',
    lastName: 'Vargas',
    dateBirth: DateTime.now(),
    email: 'd.vargas@email.com',
    program: 'FMS',
    group: '789',
    contact: Person(
        firstName: 'Laura',
        lastName: 'Vargas',
        phone: '514 321 9876',
        email: 'l.vargas@email.com'),
    contactLink: 'Mère',
    address: '8204 Rue de Blois, Saint-Léonard, QC H1R 2X1',
    phone: '514 444 5566',
  );
  students.add(student);
  internships.add(Internship(
    teacherId: '-1',
    studentId: student.id,
    enterpriseId: enterprises[4].id,
    jobId: enterprises[4].jobs[0].specialization!.id,
    type: '-1',
    visitingPriority: VisitingPriority.values[rng.nextInt(3)],
    supervisorName: '-1',
    supervisorPhone: '-1',
    supervisorEmail: '-1',
    date: DateTimeRange(
        start: DateTime.now(),
        end: DateTime.now().add(Duration(days: rng.nextInt(90)))),
    protection: [],
    uniform: '-1',
  ));

  students.add(
    Student(
      firstName: 'Geneviève',
      lastName: 'Tremblay',
      dateBirth: DateTime.now(),
      email: 'g.tremblay@email.com',
      program: 'FPT3',
      group: '885',
      contact: Person(
          firstName: 'Vincent',
          lastName: 'Tremblay',
          phone: '514 321 9876',
          email: 'v.tremblay@email.com'),
      contactLink: 'Père',
      address: '8358 Rue Jean-Nicolet, Saint-Léonard, QC H1R 2R2',
      phone: '514 555 9988',
    ),
  );

  students.add(
    Student(
      firstName: 'Vincent',
      lastName: 'Picard',
      dateBirth: DateTime.now(),
      email: 'v.picard@email.com',
      program: 'FMS',
      group: '789',
      contact: Person(
          firstName: 'Jean-François',
          lastName: 'Picard',
          phone: '514 321 9876',
          email: 'jp.picard@email.com'),
      contactLink: 'Père',
      address: '8382 Rue du Laus, Saint-Léonard, QC H1R 2P4',
      phone: '514 778 8899',
    ),
  );

  student = Student(
    firstName: 'Vanessa',
    lastName: 'Monette',
    dateBirth: DateTime.now(),
    email: 'v.monette@email.com',
    program: 'FMS',
    group: '789',
    contact: Person(
        firstName: 'Stéphane',
        lastName: 'Monette',
        phone: '514 321 9876',
        email: 's.monette@email.com'),
    contactLink: 'Père',
    address: '6865 Rue Chaillot, Saint-Léonard, QC H1T 3R5',
    phone: '514 321 6655',
  );
  students.add(student);
  internships.add(Internship(
    teacherId: '-1',
    studentId: student.id,
    enterpriseId: enterprises[4].id,
    jobId: enterprises[4].jobs[0].specialization!.id,
    type: '-1',
    visitingPriority: VisitingPriority.values[rng.nextInt(3)],
    supervisorName: '-1',
    supervisorPhone: '-1',
    supervisorEmail: '-1',
    date: DateTimeRange(
        start: DateTime.now(),
        end: DateTime.now().add(Duration(days: rng.nextInt(90)))),
    protection: [],
    uniform: '-1',
  ));

  students.add(
    Student(
      firstName: 'Mélissa',
      lastName: 'Poulain',
      dateBirth: DateTime.now(),
      email: 'm.poulain@email.com',
      program: 'FMS',
      group: '789',
      contact: Person(
          firstName: 'Mathieu',
          lastName: 'Poulain',
          phone: '514 321 9876',
          email: 'm.poulain@email.com'),
      contactLink: 'Père',
      address: '6585 Rue Lemay, Montréal, QC H1T 2L8',
      phone: '514 567 9999',
    ),
  );
}
