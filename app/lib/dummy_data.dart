// coverage:ignore-file
import 'dart:developer' as dev;
import 'dart:math';

import 'package:common/models/enterprises/enterprise.dart';
import 'package:common/models/enterprises/job.dart';
import 'package:common/models/enterprises/job_list.dart';
import 'package:common/models/generic/address.dart';
import 'package:common/models/generic/phone_number.dart';
import 'package:common/models/internships/internship.dart';
import 'package:common/models/internships/schedule.dart';
import 'package:common/models/internships/time_utils.dart' as time_utils;
import 'package:common/models/itineraries/visiting_priority.dart';
import 'package:common/models/persons/person.dart';
import 'package:common/models/persons/student.dart';
import 'package:common/models/persons/teacher.dart';
import 'package:common/models/school_boards/school.dart';
import 'package:common/models/school_boards/school_board.dart';
import 'package:common/services/job_data_file_service.dart';
import 'package:common/utils.dart';
import 'package:crcrme_banque_stages/common/providers/enterprises_provider.dart';
import 'package:crcrme_banque_stages/common/providers/internships_provider.dart';
import 'package:crcrme_banque_stages/common/providers/school_boards_provider.dart';
import 'package:crcrme_banque_stages/common/providers/students_provider.dart';
import 'package:crcrme_banque_stages/common/providers/teachers_provider.dart';
import 'package:enhanced_containers/enhanced_containers.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

Future<void> resetDummyData(BuildContext context) async {
  final schoolBoards = SchoolBoardsProvider.of(context, listen: false);
  final teachers = TeachersProvider.of(context, listen: false);
  final enterprises = EnterprisesProvider.of(context, listen: false);
  final internships = InternshipsProvider.of(context, listen: false);
  final students = StudentsProvider.instance(context, listen: false);
// TODO Enterprises should store all the teachers that have recruited them and
// fixed the shareWith field to be a list of teacher ids

  await _removeAll(internships, enterprises, students, teachers, schoolBoards);

// TODO Look for Quebec servers (OVH, Akamai, Vultr, etc.) to host the database
  await _addDummySchoolBoards(schoolBoards);
  await _addDummyTeachers(teachers, schoolBoards);
  await _addDummyStudents(students, teachers);
  await _addDummyEnterprises(enterprises, teachers);
  await _addDummyInternships(internships, students, enterprises, teachers);

  dev.log('Dummy reset data done');
}

Future<void> _removeAll(
  InternshipsProvider internships,
  EnterprisesProvider enterprises,
  StudentsProvider students,
  TeachersProvider teachers,
  SchoolBoardsProvider schoolBoards,
) async {
  dev.log('Removing dummy data');
  // To properly remove the data, we need to start by the internships
  internships.clear(confirm: true);
  await _waitForDatabaseUpdate(internships, 0, strictlyEqualToExpected: true);

  enterprises.clear(confirm: true);
  await _waitForDatabaseUpdate(enterprises, 0, strictlyEqualToExpected: true);

  students.clear(confirm: true);
  await _waitForDatabaseUpdate(students, 0, strictlyEqualToExpected: true);

  teachers.clear(confirm: true);
  await _waitForDatabaseUpdate(teachers, 0, strictlyEqualToExpected: true);

  schoolBoards.clear(confirm: true);
  await _waitForDatabaseUpdate(schoolBoards, 0, strictlyEqualToExpected: true);
}

Future<void> _addDummySchoolBoards(SchoolBoardsProvider schoolBoards) async {
  dev.log('Adding dummy schools');

  // Test the add function
  final schools = [
    School(
        id: DevAuth.devMySchoolId,
        name: 'Mon école',
        address: Address(
            civicNumber: 9105,
            street: 'Rue Verville',
            city: 'Montréal',
            postalCode: 'H2N 1Y5')),
    School(
        name: 'Ma deuxième école',
        address: Address(
            civicNumber: 9105,
            street: 'Rue Verville',
            city: 'Montréal',
            postalCode: 'H2N 1Y5')),
  ];
  schoolBoards.add(SchoolBoard(
      id: DevAuth.devMySchoolBoardId,
      name: 'Ma commission scolaire',
      schools: schools.toList()));
  await _waitForDatabaseUpdate(schoolBoards, 1);

  // Test the replace function

  // Change the name of the schoolboard
  schoolBoards.replace(
      schoolBoards[0].copyWith(name: 'Ma première commission scolaire'));
  while (schoolBoards[0].name != 'Ma première commission scolaire') {
    await Future.delayed(const Duration(milliseconds: 100));
  }

  // Modify the name of the first school
  schools[0] = schools[0].copyWith(name: 'Ma première école');
  schoolBoards.replace(schoolBoards[0].copyWith(schools: schools.toList()));
  while (!schoolBoards[0].schools.any((e) => e.name == 'Ma première école')) {
    await Future.delayed(const Duration(milliseconds: 100));
  }

  // Modify the address of the second school
  schools[1] = schools[1].copyWith(
    address: Address(
      civicNumber: 5019,
      street: 'Rue Merville',
      city: 'Québec',
      postalCode: '1Y5 H2N',
    ),
  );
  schoolBoards.replace(schoolBoards[0].copyWith(schools: schools.toList()));
  while (!schoolBoards[0].schools.any((e) => e.address.civicNumber == 5019)) {
    await Future.delayed(const Duration(milliseconds: 100));
  }
}

String get _partnerTeacherId {
  var uuid = Uuid();
  final namespace = UuidValue.fromNamespace(Namespace.dns);
  return uuid.v5(namespace.toString(), '42');
}

Future<void> _addDummyTeachers(
    TeachersProvider teachers, SchoolBoardsProvider schoolBoards) async {
  dev.log('Adding dummy teachers');

  teachers.add(Teacher(
    id: _partnerTeacherId,
    firstName: 'Roméo',
    middleName: null,
    lastName: 'Montaigu',
    schoolBoardId: schoolBoards[0].id,
    schoolId: schoolBoards[0].schools[0].id,
    groups: ['550', '551'],
    email: 'romeo.montaigu@shakespeare.qc',
    phone: PhoneNumber.empty,
    address: Address.empty,
    dateBirth: null,
    itineraries: [],
  ));

  teachers.add(Teacher(
    id: teachers.currentTeacherId,
    firstName: 'Juliette',
    middleName: null,
    lastName: 'Capulet',
    schoolBoardId: schoolBoards[0].id,
    schoolId: schoolBoards[0].schools[0].id,
    groups: ['550', '551'],
    email: 'juliette.capulet@shakespeare.qc',
    phone: PhoneNumber.empty,
    address: Address.empty,
    dateBirth: null,
    itineraries: [],
  ));

  teachers.add(Teacher(
    firstName: 'Tybalt',
    middleName: null,
    lastName: 'Capulet',
    schoolBoardId: schoolBoards[0].id,
    schoolId: schoolBoards[0].schools[0].id,
    groups: ['550', '551'],
    email: 'tybalt.capulet@shakespeare.qc',
    phone: PhoneNumber.empty,
    address: Address.empty,
    dateBirth: null,
    itineraries: [],
  ));

  teachers.add(Teacher(
    firstName: 'Benvolio',
    middleName: null,
    lastName: 'Montaigu',
    schoolBoardId: schoolBoards[0].id,
    schoolId: schoolBoards[0].schools[0].id,
    groups: ['552'],
    email: 'benvolio.montaigu@shakespeare.qc',
    phone: PhoneNumber.empty,
    address: Address.empty,
    dateBirth: null,
    itineraries: [],
  ));
  await _waitForDatabaseUpdate(teachers, 4);
}

Future<void> _addDummyEnterprises(
    EnterprisesProvider enterprises, TeachersProvider teachers) async {
  dev.log('Adding dummy enterprises');
  final schoolBoardId = teachers.currentTeacher.schoolBoardId;

  JobList jobs = JobList();
  jobs.add(
    Job(
        specialization:
            ActivitySectorsService.activitySectors[2].specializations[9],
        positionsOffered: 2,
        sstEvaluation: JobSstEvaluation.empty,
        incidents: Incidents(
            severeInjuries: [Incident('Vaut mieux ne pas détailler...')]),
        minimumAge: 12,
        preInternshipRequests: PreInternshipRequests.fromStrings([
          'Manger de la poutine',
          PreInternshipRequestTypes.soloInterview.index.toString()
        ]),
        uniforms: Uniforms(
            status: UniformStatus.suppliedByEnterprise,
            uniforms: ['Un beau chapeu bleu']),
        protections: Protections(
            status: ProtectionsStatus.suppliedByEnterprise,
            protections: [
              'Une veste de mithril',
              'Une cotte de maille',
              'Une drole de bague'
            ])),
  );
  jobs.add(
    Job(
        specialization:
            ActivitySectorsService.activitySectors[0].specializations[7],
        positionsOffered: 3,
        sstEvaluation: JobSstEvaluation.empty,
        incidents: Incidents(minorInjuries: [
          Incident('Juste un petit couteau de 5cm dans la main'),
          Incident('Une deuxième fois, mais seulement 5 points de suture'),
        ]),
        minimumAge: 15,
        preInternshipRequests:
            PreInternshipRequests.fromStrings(['Manger de la tarte']),
        uniforms: Uniforms(
            status: UniformStatus.suppliedByEnterprise,
            uniforms: ['Deux dents en or']),
        protections: Protections(
            status: ProtectionsStatus.suppliedByEnterprise,
            protections: [
              'Une veste de mithril',
              'Une cotte de maille',
              'Une drole de bague'
            ])),
  );

  enterprises.add(
    Enterprise(
      schoolBoardId: schoolBoardId,
      name: 'Metro Gagnon',
      activityTypes: {
        ActivityTypes.boucherie,
        ActivityTypes.commerce,
        ActivityTypes.epicerie
      },
      recruiterId: teachers[0].id,
      jobs: jobs,
      contact: Person(
          firstName: 'Marc',
          middleName: null,
          lastName: 'Arcand',
          dateBirth: null,
          phone: PhoneNumber.fromString('514 999 6655'),
          address: Address.empty,
          email: 'm.arcand@email.com'),
      contactFunction: 'Directeur',
      address: Address(
          civicNumber: 1853,
          street: 'Chemin Rockland',
          city: 'Mont-Royal',
          postalCode: 'H3P 2Y7'),
      phone: PhoneNumber.fromString('514 999 6655'),
      fax: PhoneNumber.fromString('514 999 6600'),
      website: 'fausse.ca',
      headquartersAddress: Address(
          civicNumber: 1853,
          street: 'Chemin Rockland',
          city: 'Mont-Royal',
          postalCode: 'H3P 2Y7'),
      neq: '4567900954',
    ),
  );

  jobs = JobList();
  jobs.add(
    Job(
        specialization:
            ActivitySectorsService.activitySectors[0].specializations[7],
        positionsOffered: 3,
        sstEvaluation: JobSstEvaluation.empty,
        incidents: Incidents.empty,
        minimumAge: 15,
        preInternshipRequests: PreInternshipRequests.fromStrings([]),
        uniforms: Uniforms(status: UniformStatus.none),
        protections: Protections(status: ProtectionsStatus.none)),
  );
  enterprises.add(
    Enterprise(
      schoolBoardId: schoolBoardId,
      name: 'Jean Coutu',
      activityTypes: {ActivityTypes.commerce, ActivityTypes.pharmacie},
      recruiterId: teachers[1].id,
      jobs: jobs,
      contact: Person(
        firstName: 'Caroline',
        middleName: null,
        lastName: 'Mercier',
        dateBirth: null,
        phone: PhoneNumber.fromString('514 123 4567 poste 123'),
        address: Address.empty,
        email: 'c.mercier@email.com',
      ),
      contactFunction: 'Assistante-gérante',
      address: Address(
          civicNumber: 1665,
          street: 'Poncet',
          city: 'Montréal',
          postalCode: 'H3M 1T8'),
      phone: PhoneNumber.fromString('514 123 4567'),
      fax: PhoneNumber.fromString('514 123 4560'),
      website: 'example.com',
      headquartersAddress: Address(
          civicNumber: 1665,
          street: 'Poncet',
          city: 'Montréal',
          postalCode: 'H3M 1T8'),
      neq: '1234567891',
    ),
  );

  jobs = JobList();
  jobs.add(
    Job(
      specialization:
          ActivitySectorsService.activitySectors[9].specializations[3],
      positionsOffered: 3,
      sstEvaluation: JobSstEvaluation(
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
        date: DateTime.now(),
      ),
      incidents: Incidents.empty,
      minimumAge: 15,
      preInternshipRequests: PreInternshipRequests.fromStrings([]),
      uniforms: Uniforms(status: UniformStatus.none),
      protections: Protections(status: ProtectionsStatus.none),
    ),
  );

  enterprises.add(
    Enterprise(
      schoolBoardId: schoolBoardId,
      name: 'Auto Care',
      activityTypes: {ActivityTypes.garage},
      recruiterId: teachers[0].id,
      jobs: jobs,
      contact: Person(
        firstName: 'Denis',
        middleName: null,
        lastName: 'Rondeau',
        dateBirth: null,
        phone: PhoneNumber.fromString('438 987 6543'),
        address: Address.empty,
        email: 'd.rondeau@email.com',
      ),
      contactFunction: 'Propriétaire',
      address: Address(
          civicNumber: 8490,
          street: 'Rue Saint-Dominique',
          city: 'Montréal',
          postalCode: 'H2P 2L5'),
      phone: PhoneNumber.fromString('438 987 6543'),
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
      specialization:
          ActivitySectorsService.activitySectors[9].specializations[3],
      positionsOffered: 2,
      sstEvaluation: JobSstEvaluation.empty,
      incidents: Incidents.empty,
      minimumAge: 15,
      preInternshipRequests: PreInternshipRequests.fromStrings([]),
      uniforms: Uniforms(status: UniformStatus.none),
      protections: Protections(status: ProtectionsStatus.none),
    ),
  );
  enterprises.add(
    Enterprise(
      schoolBoardId: schoolBoardId,
      name: 'Auto Repair',
      activityTypes: {ActivityTypes.garage, ActivityTypes.mecanique},
      recruiterId: teachers[2].id,
      jobs: jobs,
      contact: Person(
        firstName: 'Claudio',
        middleName: null,
        lastName: 'Brodeur',
        dateBirth: null,
        phone: PhoneNumber.fromString('514 235 6789'),
        address: Address.empty,
        email: 'c.brodeur@email.com',
      ),
      contactFunction: 'Propriétaire',
      address: Address(
          civicNumber: 10142,
          street: 'Boul. Saint-Laurent',
          city: 'Montréal',
          postalCode: 'H3L 2N7'),
      phone: PhoneNumber.fromString('514 235 6789'),
      fax: PhoneNumber.fromString('514 321 9870'),
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
      specialization:
          ActivitySectorsService.activitySectors[2].specializations[9],
      positionsOffered: 2,
      sstEvaluation: JobSstEvaluation.empty,
      incidents: Incidents.empty,
      minimumAge: 15,
      preInternshipRequests: PreInternshipRequests.fromStrings([]),
      uniforms: Uniforms(status: UniformStatus.none),
      protections: Protections(status: ProtectionsStatus.none),
    ),
  );

  enterprises.add(
    Enterprise(
      schoolBoardId: schoolBoardId,
      name: 'Boucherie Marien',
      activityTypes: {ActivityTypes.boucherie, ActivityTypes.commerce},
      recruiterId: teachers[0].id,
      jobs: jobs,
      contact: Person(
        firstName: 'Brigitte',
        middleName: null,
        lastName: 'Samson',
        dateBirth: null,
        phone: PhoneNumber.fromString('438 888 2222'),
        address: Address.empty,
        email: 'b.samson@email.com',
      ),
      contactFunction: 'Gérante',
      address: Address(
          civicNumber: 8921,
          street: 'Rue Lajeunesse',
          city: 'Montréal',
          postalCode: 'H2M 1S1'),
      phone: PhoneNumber.fromString('514 321 9876'),
      fax: PhoneNumber.fromString('514 321 9870'),
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
      specialization:
          ActivitySectorsService.activitySectors[2].specializations[7],
      positionsOffered: 1,
      sstEvaluation: JobSstEvaluation.empty,
      incidents: Incidents.empty,
      minimumAge: 15,
      preInternshipRequests: PreInternshipRequests.fromStrings([]),
      uniforms: Uniforms(status: UniformStatus.none),
      protections: Protections(status: ProtectionsStatus.none),
    ),
  );

  enterprises.add(
    Enterprise(
      schoolBoardId: schoolBoardId,
      name: 'IGA',
      activityTypes: {ActivityTypes.epicerie, ActivityTypes.supermarche},
      recruiterId: teachers[0].id,
      jobs: jobs,
      contact: Person(
        firstName: 'Gabrielle',
        middleName: null,
        lastName: 'Fortin',
        dateBirth: null,
        phone: PhoneNumber.fromString('514 111 2222'),
        address: Address.empty,
        email: 'g.fortin@email.com',
      ),
      contactFunction: 'Gérante',
      address: Address(
          civicNumber: 1415,
          street: 'Rue Jarry Est',
          city: 'Montréal',
          postalCode: 'H2E 1A7'),
      phone: PhoneNumber.fromString('514 111 2222'),
      fax: PhoneNumber.fromString('514 111 2200'),
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
      specialization:
          ActivitySectorsService.activitySectors[0].specializations[7],
      positionsOffered: 2,
      sstEvaluation: JobSstEvaluation.empty,
      incidents: Incidents.empty,
      minimumAge: 15,
      preInternshipRequests: PreInternshipRequests.fromStrings([]),
      uniforms: Uniforms(status: UniformStatus.none),
      protections: Protections(status: ProtectionsStatus.none),
    ),
  );

  enterprises.add(
    Enterprise(
      schoolBoardId: schoolBoardId,
      name: 'Pharmaprix',
      activityTypes: {ActivityTypes.commerce, ActivityTypes.pharmacie},
      recruiterId: teachers[3].id,
      jobs: jobs,
      contact: Person(
        firstName: 'Jessica',
        middleName: null,
        lastName: 'Marcotte',
        dateBirth: null,
        phone: PhoneNumber.fromString('514 111 2222'),
        address: Address.empty,
        email: 'g.fortin@email.com',
      ),
      contactFunction: 'Pharmacienne',
      address: Address(
          civicNumber: 3611,
          street: 'Rue Jarry Est',
          city: 'Montréal',
          postalCode: 'H1Z 2G1'),
      phone: PhoneNumber.fromString('514 654 5444'),
      fax: PhoneNumber.fromString('514 654 5445'),
      website: 'fausse.ca',
      headquartersAddress: Address(
          civicNumber: 3611,
          street: 'Rue Jarry Est',
          city: 'Montréal',
          postalCode: 'H1Z 2G1'),
      neq: '3456789933',
    ),
  );

  jobs = JobList();
  jobs.add(
    Job(
      specialization:
          ActivitySectorsService.activitySectors[2].specializations[14],
      positionsOffered: 1,
      sstEvaluation: JobSstEvaluation.empty,
      incidents: Incidents.empty,
      minimumAge: 15,
      preInternshipRequests: PreInternshipRequests.fromStrings([]),
      uniforms: Uniforms(status: UniformStatus.none),
      protections: Protections(status: ProtectionsStatus.none),
    ),
  );

  enterprises.add(
    Enterprise(
      schoolBoardId: schoolBoardId,
      name: 'Subway',
      activityTypes: {
        ActivityTypes.restaurationRapide,
        ActivityTypes.sandwicherie
      },
      recruiterId: teachers[3].id,
      jobs: jobs,
      contact: Person(
        firstName: 'Carlos',
        middleName: null,
        lastName: 'Rodriguez',
        dateBirth: null,
        phone: PhoneNumber.fromString('514 555 3333'),
        address: Address.empty,
        email: 'c.rodriguez@email.com',
      ),
      contactFunction: 'Gérant',
      address: Address(
          civicNumber: 775,
          street: 'Rue Chabanel O',
          city: 'Montréal',
          postalCode: 'H4N 3J7'),
      phone: PhoneNumber.fromString('514 555 7891'),
      website: 'fausse.ca',
      headquartersAddress: null,
      neq: '6790122996',
    ),
  );

  jobs = JobList();
  jobs.add(
    Job(
      specialization:
          ActivitySectorsService.activitySectors[0].specializations[7],
      positionsOffered: 3,
      sstEvaluation: JobSstEvaluation.empty,
      incidents: Incidents.empty,
      minimumAge: 15,
      preInternshipRequests: PreInternshipRequests.fromStrings([]),
      uniforms: Uniforms(status: UniformStatus.none),
      protections: Protections(status: ProtectionsStatus.none),
    ),
  );

  enterprises.add(
    Enterprise(
      schoolBoardId: schoolBoardId,
      name: 'Walmart',
      activityTypes: {
        ActivityTypes.commerce,
        ActivityTypes.magasin,
        ActivityTypes.supermarche
      },
      recruiterId: teachers[0].id,
      jobs: jobs,
      contact: Person(
        firstName: 'France',
        middleName: null,
        lastName: 'Boissonneau',
        dateBirth: null,
        phone: PhoneNumber.fromString('514 879 8654 poste 1112'),
        address: Address.empty,
        email: 'f.boissonneau@email.com',
      ),
      contactFunction: 'Directrice des Ressources Humaines',
      address: Address(
          civicNumber: 10345,
          street: 'Ave Christophe-Colomb',
          city: 'Montréal',
          postalCode: 'H2C 2V1'),
      phone: PhoneNumber.fromString('514 879 8654'),
      fax: PhoneNumber.fromString('514 879 8000'),
      website: 'fausse.ca',
      headquartersAddress: Address(
          civicNumber: 10345,
          street: 'Ave Christophe-Colomb',
          city: 'Montréal',
          postalCode: 'H2C 2V1'),
      neq: '9012345038',
    ),
  );

  jobs = JobList();
  jobs.add(
    Job(
      specialization:
          ActivitySectorsService.activitySectors[1].specializations[2],
      positionsOffered: 1,
      sstEvaluation: JobSstEvaluation(
        questions: {
          'Q1': ['Oui'],
          'Q1+t': ['Plusieurs fois par jour, surtout des pots de fleurs.'],
          'Q3': ['Un diable'],
          'Q5': ['Un couteau', 'Des ciseaux', 'Un sécateur'],
          'Q7': ['Des pesticides', 'Engrais'],
          'Q12': ['Bruyant'],
          'Q15': ['Non'],
          'Q18': ['Oui'],
          'Q18+t': [
            'L\'élève ne portait pas ses gants malgré plusieurs avertissements, '
                'et il s\'est ouvert profondément la paume en voulant couper une tige.'
          ],
        },
      ),
      incidents: Incidents.empty,
      minimumAge: 15,
      preInternshipRequests: PreInternshipRequests.fromStrings([]),
      uniforms: Uniforms(status: UniformStatus.none),
      protections: Protections(status: ProtectionsStatus.none),
    ),
  );
  enterprises.add(
    Enterprise(
      schoolBoardId: schoolBoardId,
      name: 'Le jardin de Joanie',
      activityTypes: {ActivityTypes.commerce, ActivityTypes.fleuriste},
      recruiterId: teachers[0].id,
      jobs: jobs,
      contact: Person(
        firstName: 'Joanie',
        middleName: null,
        lastName: 'Lemieux',
        dateBirth: null,
        phone: PhoneNumber.fromString('438 789 6543'),
        address: Address.empty,
        email: 'j.lemieux@email.com',
      ),
      contactFunction: 'Propriétaire',
      address: Address(
          civicNumber: 8629,
          street: 'Rue de Gaspé',
          city: 'Montréal',
          postalCode: 'H2P 2K3'),
      phone: PhoneNumber.fromString('438 789 6543'),
      website: '',
      headquartersAddress: Address(
          civicNumber: 8629,
          street: 'Rue de Gaspé',
          city: 'Montréal',
          postalCode: 'H2P 2K3'),
      neq: '5679011966',
    ),
  );

  jobs = JobList();
  jobs.add(
    Job(
      specialization:
          ActivitySectorsService.activitySectors[1].specializations[2],
      positionsOffered: 1,
      sstEvaluation: JobSstEvaluation(
        questions: {
          'Q1': ['Oui'],
          'Q1+t': [
            'En début et en fin de journée, surtout des pots de fleurs.'
          ],
          'Q3': ['Un diable'],
          'Q5': ['Un couteau', 'Des ciseaux'],
          'Q7': ['Des pesticides', 'Engrais'],
          'Q12': ['__NOT_APPLICABLE_INTERNAL__'],
          'Q15': ['Oui'],
          'Q15+t': ['Mais pourquoi donc??'],
          'Q16': ['Beurk'],
          'Q18': ['Non'],
        },
      ),
      incidents: Incidents.empty,
      minimumAge: 15,
      preInternshipRequests: PreInternshipRequests.fromStrings([]),
      uniforms: Uniforms(status: UniformStatus.none),
      protections: Protections(status: ProtectionsStatus.none),
    ),
  );
  enterprises.add(
    Enterprise(
      schoolBoardId: schoolBoardId,
      name: 'Fleuriste Joli',
      activityTypes: {ActivityTypes.fleuriste, ActivityTypes.magasin},
      recruiterId: teachers[0].id,
      jobs: jobs,
      contact: Person(
        firstName: 'Gaëtan',
        middleName: null,
        lastName: 'Munger',
        dateBirth: null,
        phone: PhoneNumber.fromString('514 987 6543'),
        address: Address.empty,
        email: 'g.munger@email.com',
      ),
      contactFunction: 'Gérant',
      address: Address(
          civicNumber: 70,
          street: 'Rue Chabanel Ouest',
          city: 'Montréal',
          postalCode: 'H2N 1E7'),
      phone: PhoneNumber.fromString('514 987 6543'),
      website: '',
      headquartersAddress: Address(
          civicNumber: 70,
          street: 'Rue Chabanel Ouest',
          city: 'Montréal',
          postalCode: 'H2N 1E7'),
      neq: '5679055590',
    ),
  );
  await _waitForDatabaseUpdate(enterprises, 11);
}

Future<void> _addDummyStudents(
    StudentsProvider students, TeachersProvider teachers) async {
  dev.log('Adding dummy students');
  final schoolBoardId = teachers.currentTeacher.schoolBoardId;
  final schoolId = teachers.currentTeacher.schoolId;

  students.add(
    Student(
      schoolBoardId: schoolBoardId,
      schoolId: schoolId,
      firstName: 'Cedric',
      lastName: 'Masson',
      dateBirth: DateTime(2005, 5, 20),
      email: 'c.masson@email.com',
      program: Program.fpt,
      group: '550',
      address: Address(
          civicNumber: 7248,
          street: 'Rue D\'Iberville',
          city: 'Montréal',
          postalCode: 'H2E 2Y6'),
      phone: PhoneNumber.fromString('514 321 8888'),
      contact: Person(
          firstName: 'Paul',
          middleName: null,
          lastName: 'Masson',
          dateBirth: null,
          phone: PhoneNumber.fromString('514 321 9876'),
          address: Address.empty,
          email: 'p.masson@email.com'),
      contactLink: 'Père',
    ),
  );

  students.add(
    Student(
      schoolBoardId: schoolBoardId,
      schoolId: schoolId,
      firstName: 'Thomas',
      lastName: 'Caron',
      dateBirth: DateTime.now(),
      email: 't.caron@email.com',
      program: Program.fpt,
      group: '550',
      contact: Person(
          firstName: 'Jean-Pierre',
          middleName: null,
          lastName: 'Caron Mathieu',
          dateBirth: null,
          phone: PhoneNumber.fromString('514 321 9876'),
          address: Address.empty,
          email: 'j.caron@email.com'),
      contactLink: 'Père',
      address: Address(
          civicNumber: 202,
          street: 'Boulevard Saint-Joseph Est',
          city: 'Montréal',
          postalCode: 'H1X 2T2'),
      phone: PhoneNumber.fromString('514 222 3344'),
    ),
  );

  students.add(
    Student(
      schoolBoardId: schoolBoardId,
      schoolId: schoolId,
      firstName: 'Mikael',
      lastName: 'Boucher',
      dateBirth: DateTime.now(),
      email: 'm.boucher@email.com',
      program: Program.fpt,
      group: '550',
      contact: Person(
          firstName: 'Nicole',
          middleName: null,
          lastName: 'Lefranc',
          dateBirth: null,
          phone: PhoneNumber.fromString('514 321 9876'),
          address: Address.empty,
          email: 'n.lefranc@email.com'),
      contactLink: 'Mère',
      address: Address(
          civicNumber: 6723,
          street: '25e Ave',
          city: 'Montréal',
          postalCode: 'H1T 3M1'),
      phone: PhoneNumber.fromString('514 333 4455'),
    ),
  );

  students.add(
    Student(
      schoolBoardId: schoolBoardId,
      schoolId: schoolId,
      firstName: 'Kevin',
      lastName: 'Leblanc',
      dateBirth: DateTime.now(),
      email: 'k.leblanc@email.com',
      program: Program.fpt,
      group: '550',
      contact: Person(
          firstName: 'Martine',
          middleName: null,
          lastName: 'Gagnon',
          dateBirth: null,
          phone: PhoneNumber.fromString('514 321 9876'),
          address: Address.empty,
          email: 'm.gagnon@email.com'),
      contactLink: 'Mère',
      address: Address(
          civicNumber: 9277,
          street: 'Rue Meunier',
          city: 'Montréal',
          postalCode: 'H2N 1W4'),
      phone: PhoneNumber.fromString('514 999 8877'),
    ),
  );

  students.add(
    Student(
      schoolBoardId: schoolBoardId,
      schoolId: schoolId,
      firstName: 'Simon',
      lastName: 'Gingras',
      dateBirth: DateTime.now(),
      email: 's.gingras@email.com',
      program: Program.fms,
      group: '552',
      contact: Person(
          firstName: 'Raoul',
          middleName: null,
          lastName: 'Gingras',
          email: 'r.gingras@email.com',
          dateBirth: null,
          phone: PhoneNumber.fromString('514 321 9876'),
          address: Address.empty),
      contactLink: 'Père',
      address: Address(
          civicNumber: 4517,
          street: 'Rue d\'Assise',
          city: 'Saint-Léonard',
          postalCode: 'H1R 1W2'),
      phone: PhoneNumber.fromString('514 888 7766'),
    ),
  );

  students.add(
    Student(
      schoolBoardId: schoolBoardId,
      schoolId: schoolId,
      firstName: 'Diego',
      lastName: 'Vargas',
      dateBirth: DateTime.now(),
      email: 'd.vargas@email.com',
      program: Program.fpt,
      group: '550',
      contact: Person(
          firstName: 'Laura',
          middleName: null,
          lastName: 'Vargas',
          dateBirth: null,
          phone: PhoneNumber.fromString('514 321 9876'),
          address: Address.empty,
          email: 'l.vargas@email.com'),
      contactLink: 'Mère',
      address: Address(
          civicNumber: 8204,
          street: 'Rue de Blois',
          city: 'Saint-Léonard',
          postalCode: 'H1R 2X1'),
      phone: PhoneNumber.fromString('514 444 5566'),
    ),
  );

  students.add(
    Student(
      schoolBoardId: schoolBoardId,
      schoolId: schoolId,
      firstName: 'Jeanne',
      lastName: 'Tremblay',
      dateBirth: DateTime.now(),
      email: 'g.tremblay@email.com',
      program: Program.fpt,
      group: '550',
      contact: Person(
          firstName: 'Vincent',
          middleName: null,
          lastName: 'Tremblay',
          dateBirth: null,
          phone: PhoneNumber.fromString('514 321 9876'),
          address: Address.empty,
          email: 'v.tremblay@email.com'),
      contactLink: 'Père',
      address: Address(
          civicNumber: 8358,
          street: 'Rue Jean-Nicolet',
          city: 'Saint-Léonard',
          postalCode: 'H1R 2R2'),
      phone: PhoneNumber.fromString('514 555 9988'),
    ),
  );

  students.add(
    Student(
      schoolBoardId: schoolBoardId,
      schoolId: schoolId,
      firstName: 'Vincent',
      lastName: 'Picard',
      dateBirth: DateTime.now(),
      email: 'v.picard@email.com',
      program: Program.fms,
      group: '550',
      contact: Person(
          firstName: 'Jean-François',
          middleName: null,
          lastName: 'Picard',
          dateBirth: null,
          phone: PhoneNumber.fromString('514 321 9876'),
          address: Address.empty,
          email: 'jp.picard@email.com'),
      contactLink: 'Père',
      address: Address(
          civicNumber: 8382,
          street: 'Rue du Laus',
          city: 'Saint-Léonard',
          postalCode: 'H1R 2P4'),
      phone: PhoneNumber.fromString('514 778 8899'),
    ),
  );

  students.add(
    Student(
      schoolBoardId: schoolBoardId,
      schoolId: schoolId,
      firstName: 'Vanessa',
      lastName: 'Monette',
      dateBirth: DateTime.now(),
      email: 'v.monette@email.com',
      program: Program.fms,
      group: '551',
      contact: Person(
          firstName: 'Stéphane',
          middleName: null,
          lastName: 'Monette',
          dateBirth: null,
          phone: PhoneNumber.fromString('514 321 9876'),
          address: Address.empty,
          email: 's.monette@email.com'),
      contactLink: 'Père',
      address: Address(
          civicNumber: 6865,
          street: 'Rue Chaillot',
          city: 'Saint-Léonard',
          postalCode: 'H1T 3R5'),
      phone: PhoneNumber.fromString('514 321 6655'),
    ),
  );

  students.add(
    Student(
      schoolBoardId: schoolBoardId,
      schoolId: schoolId,
      firstName: 'Melissa',
      lastName: 'Poulain',
      dateBirth: DateTime.now(),
      email: 'm.poulain@email.com',
      program: Program.fms,
      group: '550',
      contact: Person(
          firstName: 'Mathieu',
          middleName: null,
          lastName: 'Poulain',
          dateBirth: null,
          phone: PhoneNumber.fromString('514 321 9876'),
          address: Address.empty,
          email: 'm.poulain@email.com'),
      contactLink: 'Père',
      address: Address(
          civicNumber: 6585,
          street: 'Rue Lemay',
          city: 'Montréal',
          postalCode: 'H1T 2L8'),
      phone: PhoneNumber.fromString('514 567 9999'),
    ),
  );

  await _waitForDatabaseUpdate(students, 10);
}

Future<void> _addDummyInternships(
  InternshipsProvider internships,
  StudentsProvider students,
  EnterprisesProvider enterprises,
  TeachersProvider teachers,
) async {
  dev.log('Adding dummy internships');

  final schoolBoardId = teachers.currentTeacher.schoolBoardId;
  final rng = Random();

  var period = time_utils.DateTimeRange(
      start: DateTime.now(),
      end: DateTime.now().add(Duration(days: rng.nextInt(90))));
  internships.add(Internship(
    schoolBoardId: schoolBoardId,
    creationDate: DateTime.now(),
    studentId: students.firstWhere((e) => e.fullName == 'Cedric Masson').id,
    signatoryTeacherId: teachers.currentTeacherId,
    extraSupervisingTeacherIds: [],
    enterpriseId: enterprises.firstWhere((e) => e.name == 'Auto Care').id,
    jobId: enterprises.firstWhere((e) => e.name == 'Auto Care').jobs[0].id,
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
    expectedDuration: 135,
    achievedDuration: 0,
    weeklySchedules: [
      WeeklySchedule(
        schedule: [
          DailySchedule(
            dayOfWeek: Day.monday,
            start: const time_utils.TimeOfDay(hour: 9, minute: 00),
            end: const time_utils.TimeOfDay(hour: 15, minute: 00),
          ),
          DailySchedule(
            dayOfWeek: Day.tuesday,
            start: const time_utils.TimeOfDay(hour: 9, minute: 00),
            end: const time_utils.TimeOfDay(hour: 15, minute: 00),
          ),
          DailySchedule(
            dayOfWeek: Day.wednesday,
            start: const time_utils.TimeOfDay(hour: 9, minute: 00),
            end: const time_utils.TimeOfDay(hour: 15, minute: 00),
          ),
          DailySchedule(
            dayOfWeek: Day.thursday,
            start: const time_utils.TimeOfDay(hour: 9, minute: 00),
            end: const time_utils.TimeOfDay(hour: 15, minute: 00),
          ),
          DailySchedule(
            dayOfWeek: Day.friday,
            start: const time_utils.TimeOfDay(hour: 9, minute: 00),
            end: const time_utils.TimeOfDay(hour: 15, minute: 00),
          ),
        ],
        period: period,
      ),
    ],
  ));

  var startingPeriod =
      DateTime.now().subtract(Duration(days: rng.nextInt(50) + 60));
  period = time_utils.DateTimeRange(
      start: startingPeriod,
      end: startingPeriod.add(Duration(days: rng.nextInt(50))));
  internships.add(Internship(
    schoolBoardId: schoolBoardId,
    creationDate: DateTime.now(),
    studentId: students.firstWhere((e) => e.fullName == 'Thomas Caron').id,
    signatoryTeacherId: teachers.currentTeacherId,
    extraSupervisingTeacherIds: [],
    enterpriseId:
        enterprises.firstWhere((e) => e.name == 'Boucherie Marien').id,
    jobId:
        enterprises.firstWhere((e) => e.name == 'Boucherie Marien').jobs[0].id,
    extraSpecializationIds: [],
    visitingPriority: VisitingPriority.values[0],
    supervisor: Person(
      firstName: 'Nobody',
      middleName: null,
      lastName: 'Forever',
      dateBirth: null,
      phone: PhoneNumber.empty,
      address: Address.empty,
      email: null,
    ),
    dates: period,
    expectedDuration: 135,
    achievedDuration: 0,
    weeklySchedules: [
      WeeklySchedule(
        schedule: [
          DailySchedule(
            dayOfWeek: Day.monday,
            start: const time_utils.TimeOfDay(hour: 9, minute: 00),
            end: const time_utils.TimeOfDay(hour: 15, minute: 00),
          ),
          DailySchedule(
            dayOfWeek: Day.tuesday,
            start: const time_utils.TimeOfDay(hour: 9, minute: 00),
            end: const time_utils.TimeOfDay(hour: 15, minute: 00),
          ),
          DailySchedule(
            dayOfWeek: Day.wednesday,
            start: const time_utils.TimeOfDay(hour: 9, minute: 00),
            end: const time_utils.TimeOfDay(hour: 15, minute: 00),
          ),
          DailySchedule(
            dayOfWeek: Day.thursday,
            start: const time_utils.TimeOfDay(hour: 9, minute: 00),
            end: const time_utils.TimeOfDay(hour: 15, minute: 00),
          ),
          DailySchedule(
            dayOfWeek: Day.friday,
            start: const time_utils.TimeOfDay(hour: 9, minute: 00),
            end: const time_utils.TimeOfDay(hour: 15, minute: 00),
          ),
        ],
        period: period,
      ),
    ],
  ));

  period = time_utils.DateTimeRange(
      start: DateTime.now(),
      end: DateTime.now().add(Duration(days: rng.nextInt(90))));
  var internship = Internship(
    schoolBoardId: schoolBoardId,
    creationDate: DateTime.now(),
    studentId: students.firstWhere((e) => e.fullName == 'Melissa Poulain').id,
    signatoryTeacherId: teachers.currentTeacherId,
    extraSupervisingTeacherIds: [],
    enterpriseId: enterprises.firstWhere((e) => e.name == 'Subway').id,
    jobId: enterprises.firstWhere((e) => e.name == 'Subway').jobs[0].id,
    extraSpecializationIds: [],
    visitingPriority: VisitingPriority.values[0],
    supervisor: Person(
      firstName: 'Nobody',
      middleName: null,
      lastName: 'Forever',
      dateBirth: null,
      phone: PhoneNumber.empty,
      address: Address.empty,
      email: null,
    ),
    dates: period,
    endDate: DateTime.now().add(const Duration(days: 10)),
    expectedDuration: 135,
    achievedDuration: 125,
    weeklySchedules: [
      WeeklySchedule(
        schedule: [
          DailySchedule(
            dayOfWeek: Day.monday,
            start: const time_utils.TimeOfDay(hour: 9, minute: 00),
            end: const time_utils.TimeOfDay(hour: 15, minute: 00),
          ),
          DailySchedule(
            dayOfWeek: Day.tuesday,
            start: const time_utils.TimeOfDay(hour: 9, minute: 00),
            end: const time_utils.TimeOfDay(hour: 15, minute: 00),
          ),
          DailySchedule(
            dayOfWeek: Day.wednesday,
            start: const time_utils.TimeOfDay(hour: 9, minute: 00),
            end: const time_utils.TimeOfDay(hour: 15, minute: 00),
          ),
          DailySchedule(
            dayOfWeek: Day.thursday,
            start: const time_utils.TimeOfDay(hour: 9, minute: 00),
            end: const time_utils.TimeOfDay(hour: 15, minute: 00),
          ),
        ],
        period: period,
      ),
    ],
  );
  internship.enterpriseEvaluation = PostInternshipEnterpriseEvaluation(
    internshipId: internship.id,
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
  internships.add(internship);

  period = time_utils.DateTimeRange(
      start: DateTime.now(),
      end: DateTime.now().add(Duration(days: rng.nextInt(90))));
  internships.add(Internship(
    schoolBoardId: schoolBoardId,
    creationDate: DateTime.now(),
    studentId: students.firstWhere((e) => e.fullName == 'Vincent Picard').id,
    signatoryTeacherId: teachers.currentTeacherId,
    extraSupervisingTeacherIds: [],
    enterpriseId: enterprises.firstWhere((e) => e.name == 'IGA').id,
    jobId: enterprises.firstWhere((e) => e.name == 'IGA').jobs[0].id,
    extraSpecializationIds: [],
    visitingPriority: VisitingPriority.values[0],
    supervisor: Person(
      firstName: 'Nobody',
      middleName: null,
      lastName: 'Forever',
      dateBirth: null,
      phone: PhoneNumber.empty,
      address: Address.empty,
      email: null,
    ),
    dates: period,
    expectedDuration: 135,
    achievedDuration: 0,
    weeklySchedules: [
      WeeklySchedule(
        schedule: [
          DailySchedule(
            dayOfWeek: Day.monday,
            start: const time_utils.TimeOfDay(hour: 9, minute: 00),
            end: const time_utils.TimeOfDay(hour: 15, minute: 00),
          ),
          DailySchedule(
            dayOfWeek: Day.tuesday,
            start: const time_utils.TimeOfDay(hour: 9, minute: 00),
            end: const time_utils.TimeOfDay(hour: 15, minute: 00),
          ),
          DailySchedule(
            dayOfWeek: Day.wednesday,
            start: const time_utils.TimeOfDay(hour: 9, minute: 00),
            end: const time_utils.TimeOfDay(hour: 15, minute: 00),
          ),
        ],
        period: period,
      ),
    ],
  ));

  period = time_utils.DateTimeRange(
      start: DateTime.now(),
      end: DateTime.now().add(Duration(days: rng.nextInt(90))));
  internships.add(Internship(
    schoolBoardId: schoolBoardId,
    creationDate: DateTime.now(),
    studentId: students.firstWhere((e) => e.fullName == 'Simon Gingras').id,
    signatoryTeacherId: _partnerTeacherId, // This is a Roméo Montaigu's student
    extraSupervisingTeacherIds: [],
    enterpriseId: enterprises.firstWhere((e) => e.name == 'Auto Repair').id,
    jobId: enterprises.firstWhere((e) => e.name == 'Auto Repair').jobs[0].id,
    extraSpecializationIds: [],
    visitingPriority: VisitingPriority.values[0],
    supervisor: Person(
      firstName: 'Nobody',
      middleName: null,
      lastName: 'Forever',
      dateBirth: null,
      phone: PhoneNumber.empty,
      address: Address.empty,
      email: null,
    ),
    dates: period,
    endDate: DateTime.now().add(const Duration(days: 10)),
    expectedDuration: 135,
    achievedDuration: 0,
    weeklySchedules: [
      WeeklySchedule(
        schedule: [
          DailySchedule(
            dayOfWeek: Day.monday,
            start: const time_utils.TimeOfDay(hour: 9, minute: 00),
            end: const time_utils.TimeOfDay(hour: 15, minute: 00),
          ),
          DailySchedule(
            dayOfWeek: Day.wednesday,
            start: const time_utils.TimeOfDay(hour: 9, minute: 00),
            end: const time_utils.TimeOfDay(hour: 15, minute: 00),
          ),
          DailySchedule(
            dayOfWeek: Day.friday,
            start: const time_utils.TimeOfDay(hour: 9, minute: 00),
            end: const time_utils.TimeOfDay(hour: 15, minute: 00),
          ),
        ],
        period: period,
      ),
    ],
  ));

  startingPeriod = DateTime.now().subtract(const Duration(days: 100));
  period = time_utils.DateTimeRange(
      start: startingPeriod,
      end: startingPeriod.add(Duration(days: rng.nextInt(90))));
  internships.add(Internship(
    schoolBoardId: schoolBoardId,
    creationDate: DateTime.now(),
    studentId: students.firstWhere((e) => e.fullName == 'Jeanne Tremblay').id,
    signatoryTeacherId: _partnerTeacherId,
    extraSupervisingTeacherIds: [],
    enterpriseId: enterprises.firstWhere((e) => e.name == 'Metro Gagnon').id,
    jobId: enterprises.firstWhere((e) => e.name == 'Metro Gagnon').jobs[0].id,
    extraSpecializationIds: [],
    visitingPriority: VisitingPriority.values[0],
    supervisor: Person(
      firstName: 'Nobody',
      middleName: null,
      lastName: 'Forever',
      dateBirth: null,
      phone: PhoneNumber.fromString('123-456-7890'),
      address: Address.empty,
      email: null,
    ),
    dates: period,
    expectedDuration: 135,
    achievedDuration: 0,
    weeklySchedules: [
      WeeklySchedule(
        schedule: [
          DailySchedule(
            dayOfWeek: Day.monday,
            start: const time_utils.TimeOfDay(hour: 9, minute: 00),
            end: const time_utils.TimeOfDay(hour: 15, minute: 00),
          ),
          DailySchedule(
            dayOfWeek: Day.tuesday,
            start: const time_utils.TimeOfDay(hour: 9, minute: 00),
            end: const time_utils.TimeOfDay(hour: 15, minute: 00),
          ),
          DailySchedule(
            dayOfWeek: Day.wednesday,
            start: const time_utils.TimeOfDay(hour: 9, minute: 00),
            end: const time_utils.TimeOfDay(hour: 15, minute: 00),
          ),
          DailySchedule(
            dayOfWeek: Day.thursday,
            start: const time_utils.TimeOfDay(hour: 9, minute: 00),
            end: const time_utils.TimeOfDay(hour: 15, minute: 00),
          ),
          DailySchedule(
            dayOfWeek: Day.friday,
            start: const time_utils.TimeOfDay(hour: 9, minute: 00),
            end: const time_utils.TimeOfDay(hour: 15, minute: 00),
          ),
        ],
        period: period,
      ),
    ],
  ));

  period = time_utils.DateTimeRange(
      start: DateTime.now(),
      end: DateTime.now().add(Duration(days: rng.nextInt(90))));
  internships.add(Internship(
    schoolBoardId: schoolBoardId,
    creationDate: DateTime.now(),
    studentId: students.firstWhere((e) => e.fullName == 'Diego Vargas').id,
    signatoryTeacherId: _partnerTeacherId,
    extraSupervisingTeacherIds: [teachers.currentTeacherId],
    enterpriseId: enterprises.firstWhere((e) => e.name == 'Metro Gagnon').id,
    jobId: enterprises.firstWhere((e) => e.name == 'Metro Gagnon').jobs[1].id,
    extraSpecializationIds: [],
    visitingPriority: VisitingPriority.values[0],
    supervisor: Person(
      firstName: 'Nobody',
      middleName: null,
      lastName: 'Forever',
      dateBirth: null,
      phone: PhoneNumber.empty,
      address: Address.empty,
      email: null,
    ),
    dates: period,
    expectedDuration: 135,
    achievedDuration: 0,
    weeklySchedules: [
      WeeklySchedule(
        schedule: [
          DailySchedule(
            dayOfWeek: Day.monday,
            start: const time_utils.TimeOfDay(hour: 9, minute: 00),
            end: const time_utils.TimeOfDay(hour: 15, minute: 00),
          ),
          DailySchedule(
            dayOfWeek: Day.tuesday,
            start: const time_utils.TimeOfDay(hour: 9, minute: 00),
            end: const time_utils.TimeOfDay(hour: 15, minute: 00),
          ),
          DailySchedule(
            dayOfWeek: Day.wednesday,
            start: const time_utils.TimeOfDay(hour: 9, minute: 00),
            end: const time_utils.TimeOfDay(hour: 15, minute: 00),
          ),
          DailySchedule(
            dayOfWeek: Day.thursday,
            start: const time_utils.TimeOfDay(hour: 9, minute: 00),
            end: const time_utils.TimeOfDay(hour: 15, minute: 00),
          ),
          DailySchedule(
            dayOfWeek: Day.friday,
            start: const time_utils.TimeOfDay(hour: 9, minute: 00),
            end: const time_utils.TimeOfDay(hour: 15, minute: 00),
          ),
        ],
        period: period,
      ),
    ],
  ));

  startingPeriod = DateTime.now().subtract(Duration(days: rng.nextInt(250)));
  period = time_utils.DateTimeRange(
      start: startingPeriod,
      end: startingPeriod.add(Duration(days: rng.nextInt(50))));
  internships.add(
    Internship(
      schoolBoardId: schoolBoardId,
      creationDate: DateTime.now(),
      studentId: students.firstWhere((e) => e.fullName == 'Vanessa Monette').id,
      signatoryTeacherId: teachers.currentTeacherId,
      extraSupervisingTeacherIds: [],
      enterpriseId: enterprises.firstWhere((e) => e.name == 'Jean Coutu').id,
      jobId: enterprises.firstWhere((e) => e.name == 'Jean Coutu').jobs[0].id,
      extraSpecializationIds: [],
      visitingPriority: VisitingPriority.values[0],
      supervisor: Person(
        firstName: 'Un',
        middleName: null,
        lastName: 'Ami',
        dateBirth: null,
        phone: PhoneNumber.empty,
        address: Address.empty,
        email: null,
      ),
      dates: period,
      endDate: period.end,
      expectedDuration: 135,
      achievedDuration: 100,
      weeklySchedules: [
        WeeklySchedule(
          schedule: [
            DailySchedule(
              dayOfWeek: Day.monday,
              start: const time_utils.TimeOfDay(hour: 9, minute: 00),
              end: const time_utils.TimeOfDay(hour: 15, minute: 00),
            ),
            DailySchedule(
              dayOfWeek: Day.tuesday,
              start: const time_utils.TimeOfDay(hour: 9, minute: 00),
              end: const time_utils.TimeOfDay(hour: 15, minute: 00),
            ),
          ],
          period: period,
        ),
      ],
    ),
  );

  startingPeriod = DateTime.now().subtract(Duration(days: rng.nextInt(200)));
  period = time_utils.DateTimeRange(
      start: startingPeriod,
      end: startingPeriod.add(Duration(days: rng.nextInt(50))));
  internships.add(Internship(
    schoolBoardId: schoolBoardId,
    creationDate: DateTime.now(),
    studentId: students.firstWhere((e) => e.fullName == 'Vanessa Monette').id,
    signatoryTeacherId: teachers.currentTeacherId,
    extraSupervisingTeacherIds: [],
    enterpriseId: enterprises.firstWhere((e) => e.name == 'Pharmaprix').id,
    jobId: enterprises.firstWhere((e) => e.name == 'Pharmaprix').jobs[0].id,
    extraSpecializationIds: [],
    visitingPriority: VisitingPriority.values[0],
    supervisor: Person(
      firstName: 'Deux',
      middleName: null,
      lastName: 'Amis',
      dateBirth: null,
      phone: PhoneNumber.empty,
      address: Address.empty,
      email: null,
    ),
    dates: period,
    endDate: period.end,
    expectedDuration: 135,
    achievedDuration: 100,
    weeklySchedules: [
      WeeklySchedule(
        schedule: [
          DailySchedule(
            dayOfWeek: Day.monday,
            start: const time_utils.TimeOfDay(hour: 9, minute: 00),
            end: const time_utils.TimeOfDay(hour: 15, minute: 00),
          ),
          DailySchedule(
            dayOfWeek: Day.tuesday,
            start: const time_utils.TimeOfDay(hour: 9, minute: 00),
            end: const time_utils.TimeOfDay(hour: 15, minute: 00),
          ),
        ],
        period: period,
      ),
    ],
  ));
  await _waitForDatabaseUpdate(internships, 9);
}

Future<void> _waitForDatabaseUpdate(
    DatabaseListProvided list, int expectedDuration,
    {bool strictlyEqualToExpected = false}) async {
  // Wait for the database to add all the students
  while (strictlyEqualToExpected
      ? list.length != expectedDuration
      : list.length < expectedDuration) {
    await Future.delayed(const Duration(milliseconds: 100));
  }
}
