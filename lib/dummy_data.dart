import 'dart:math';

import 'package:crcrme_banque_stages/common/models/incidents.dart';
import 'package:crcrme_banque_stages/common/models/address.dart';
import 'package:crcrme_banque_stages/common/models/enterprise.dart';
import 'package:crcrme_banque_stages/common/models/internship.dart';
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
import 'package:crcrme_banque_stages/common/providers/enterprises_provider.dart';
import 'package:crcrme_banque_stages/common/providers/internships_provider.dart';
import 'package:crcrme_banque_stages/common/providers/schools_provider.dart';
import 'package:crcrme_banque_stages/common/providers/students_provider.dart';
import 'package:crcrme_banque_stages/common/providers/teachers_provider.dart';
import 'package:crcrme_banque_stages/misc/job_data_file_service.dart';
import 'package:enhanced_containers/enhanced_containers.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

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
    name: 'École',
    address:
        (await Address.fromAddress('9105 Rue Verville, Montréal, QC H2N 1Y5'))!,
  ));
  await _waitForDatabaseUpdate(schools, 1);
}

Future<void> addDummyTeachers(
    TeachersProvider teachers, SchoolsProvider schools) async {
  teachers.add(Teacher(
      id: '42',
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
            ])),
  );
  jobs.add(
    Job(
        specialization: ActivitySectorsService.sectors[0].specializations[7],
        positionsOffered: 3,
        sstEvaluation: JobSstEvaluation.empty,
        incidents: Incidents(minorInjuries: [
          Incident('Juste un petit couteau de 5cm dans la main'),
          Incident('Une deuxième fois, mais seulement 5 points de suture'),
        ]),
        minimumAge: 15,
        preInternshipRequest:
            PreInternshipRequest(requests: ['Manger de la tarte']),
        uniform: Uniform(
            status: UniformStatus.suppliedByEnterprise,
            uniform: 'Deux dents en or'),
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
      name: 'Metro Gagnon',
      activityTypes: {activityTypes[3], activityTypes[6], activityTypes[12]},
      recrutedBy: teachers[0].id,
      shareWith: 'Mon centre de services scolire',
      jobs: jobs,
      contact: Person(
          firstName: 'Marc',
          lastName: 'Arcand',
          phone: PhoneNumber.fromString('514 999 6655'),
          email: 'm.arcand@email.com'),
      contactFunction: 'Directeur',
      address: Address(
          civicNumber: 1853,
          street: 'Chem. Rockland',
          city: 'Mont-Royal',
          postalCode: 'H3P 2Y7'),
      phone: PhoneNumber.fromString('514 999 6655'),
      fax: PhoneNumber.fromString('514 999 6600'),
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
        sstEvaluation: JobSstEvaluation.empty,
        incidents: Incidents.empty,
        minimumAge: 15,
        preInternshipRequest: PreInternshipRequest(requests: []),
        uniform: Uniform(status: UniformStatus.none),
        protections: Protections(status: ProtectionsStatus.none)),
  );
  enterprises.add(
    Enterprise(
      name: 'Jean Coutu',
      activityTypes: {activityTypes[6], activityTypes[24]},
      recrutedBy: teachers[1].id,
      shareWith: 'Aucun partage',
      jobs: jobs,
      contact: Person(
        firstName: 'Caroline',
        lastName: 'Mercier',
        phone: PhoneNumber.fromString('514 123 4567 poste 123'),
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
      specialization: ActivitySectorsService.sectors[9].specializations[3],
      positionsOffered: 3,
      sstEvaluation: JobSstEvaluation(
        questions: {
          '1': 'Installer des pneus (les soulevers + transporter)',
          '2': false,
          '2+t': '',
          '3': true,
          '3+t': 'Peu souvent, à la discrétion des employés.',
          '5': ['Un diable'],
          '6': [],
          '7': ['Des ciseaux'],
          '8': [],
          '12': ['Des solvants', 'Des produits de nettoyage'],
          '15': [],
          '16': true,
          '16+t': 'Bouchons a oreilles',
          '19': true,
          '19+t': '',
          '20': '',
          '21': '',
          '22': false,
          '22+t': '',
          '23': ''
        },
        date: DateTime.now(),
      ),
      incidents: Incidents.empty,
      minimumAge: 15,
      preInternshipRequest: PreInternshipRequest(requests: []),
      uniform: Uniform(status: UniformStatus.none),
      protections: Protections(status: ProtectionsStatus.none),
    ),
  );

  enterprises.add(
    Enterprise(
      name: 'Auto Care',
      activityTypes: {activityTypes[15]},
      recrutedBy: teachers[0].id,
      shareWith: 'Mon centre de services scolaire',
      jobs: jobs,
      contact: Person(
        firstName: 'Denis',
        lastName: 'Rondeau',
        phone: PhoneNumber.fromString('438 987 6543'),
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
      specialization: ActivitySectorsService.sectors[9].specializations[3],
      positionsOffered: 2,
      sstEvaluation: JobSstEvaluation.empty,
      incidents: Incidents.empty,
      minimumAge: 15,
      preInternshipRequest: PreInternshipRequest(requests: []),
      uniform: Uniform(status: UniformStatus.none),
      protections: Protections(status: ProtectionsStatus.none),
    ),
  );
  enterprises.add(
    Enterprise(
      name: 'Auto Repair',
      activityTypes: {activityTypes[15], activityTypes[22]},
      recrutedBy: teachers[2].id,
      shareWith: 'Enseignants FPT de l\'école',
      jobs: jobs,
      contact: Person(
        firstName: 'Claudio',
        lastName: 'Brodeur',
        phone: PhoneNumber.fromString('514 235 6789'),
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
      specialization: ActivitySectorsService.sectors[2].specializations[9],
      positionsOffered: 2,
      sstEvaluation: JobSstEvaluation.empty,
      incidents: Incidents.empty,
      minimumAge: 15,
      preInternshipRequest: PreInternshipRequest(requests: []),
      uniform: Uniform(status: UniformStatus.none),
      protections: Protections(status: ProtectionsStatus.none),
    ),
  );

  enterprises.add(
    Enterprise(
      name: 'Boucherie Marien',
      activityTypes: {activityTypes[3], activityTypes[6]},
      recrutedBy: teachers[0].id,
      shareWith: 'Enseignants PFAE de l\'école',
      jobs: jobs,
      contact: Person(
        firstName: 'Brigitte',
        lastName: 'Samson',
        phone: PhoneNumber.fromString('438 888 2222'),
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
      specialization: ActivitySectorsService.sectors[2].specializations[7],
      positionsOffered: 1,
      sstEvaluation: JobSstEvaluation.empty,
      incidents: Incidents.empty,
      minimumAge: 15,
      preInternshipRequest: PreInternshipRequest(requests: []),
      uniform: Uniform(status: UniformStatus.none),
      protections: Protections(status: ProtectionsStatus.none),
    ),
  );

  enterprises.add(
    Enterprise(
      name: 'IGA',
      activityTypes: {activityTypes[12], activityTypes[35]},
      recrutedBy: teachers[0].id,
      shareWith: 'Enseignants FPT de l\'école',
      jobs: jobs,
      contact: Person(
        firstName: 'Gabrielle',
        lastName: 'Fortin',
        phone: PhoneNumber.fromString('514 111 2222'),
        email: 'g.fortin@email.com',
      ),
      contactFunction: 'Gérante',
      address: Address(
          civicNumber: 1415,
          street: 'Rue Jarry E',
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
      specialization: ActivitySectorsService.sectors[0].specializations[7],
      positionsOffered: 2,
      sstEvaluation: JobSstEvaluation.empty,
      incidents: Incidents.empty,
      minimumAge: 15,
      preInternshipRequest: PreInternshipRequest(requests: []),
      uniform: Uniform(status: UniformStatus.none),
      protections: Protections(status: ProtectionsStatus.none),
    ),
  );

  enterprises.add(
    Enterprise(
      name: 'Pharmaprix',
      activityTypes: {activityTypes[19], activityTypes[24]},
      recrutedBy: teachers[3].id,
      shareWith: 'Enseignants PFAE de l\'école',
      jobs: jobs,
      contact: Person(
        firstName: 'Jessica',
        lastName: 'Marcotte',
        phone: PhoneNumber.fromString('514 111 2222'),
        email: 'g.fortin@email.com',
      ),
      contactFunction: 'Pharmacienne',
      address: Address(
          civicNumber: 3611,
          street: 'Rue Jarry E',
          city: 'Montréal',
          postalCode: 'H1Z 2G1'),
      phone: PhoneNumber.fromString('514 654 5444'),
      fax: PhoneNumber.fromString('514 654 5445'),
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
      sstEvaluation: JobSstEvaluation.empty,
      incidents: Incidents.empty,
      minimumAge: 15,
      preInternshipRequest: PreInternshipRequest(requests: []),
      uniform: Uniform(status: UniformStatus.none),
      protections: Protections(status: ProtectionsStatus.none),
    ),
  );

  enterprises.add(
    Enterprise(
      name: 'Subway',
      activityTypes: {activityTypes[30], activityTypes[33]},
      recrutedBy: teachers[3].id,
      shareWith: 'Enseignants PFAE de l\'école',
      jobs: jobs,
      contact: Person(
        firstName: 'Carlos',
        lastName: 'Rodriguez',
        phone: PhoneNumber.fromString('514 555 3333'),
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
      specialization: ActivitySectorsService.sectors[0].specializations[7],
      positionsOffered: 3,
      sstEvaluation: JobSstEvaluation.empty,
      incidents: Incidents.empty,
      minimumAge: 15,
      preInternshipRequest: PreInternshipRequest(requests: []),
      uniform: Uniform(status: UniformStatus.none),
      protections: Protections(status: ProtectionsStatus.none),
    ),
  );

  enterprises.add(
    Enterprise(
      name: 'Walmart',
      activityTypes: {activityTypes[6], activityTypes[19], activityTypes[35]},
      recrutedBy: teachers[0].id,
      shareWith: 'Enseignants PFAE de l\'école',
      jobs: jobs,
      contact: Person(
        firstName: 'France',
        lastName: 'Boissonneau',
        phone: PhoneNumber.fromString('514 879 8654 poste 1112'),
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
      specialization: ActivitySectorsService.sectors[1].specializations[2],
      positionsOffered: 1,
      sstEvaluation: JobSstEvaluation(
        questions: {
          '1': 'Entretenir les fleurs et les plantes, servir les clients, '
              'aider à la préparation de bouquets  ',
          '2': true,
          '2+t': '',
          '3': true,
          '3+t': 'Plusieurs fois par jour, surtout des pots de fleurs.',
          '5': ['Un diable'],
          '6': [],
          '7': ['Un couteau', 'Des ciseaux', 'Un sécateur'],
          '8': [],
          '10': ['Des pesticides (résidus sur les plantes)', 'Engrais'],
          '15': [],
          '16': false,
          '19': false,
          '20': '',
          '21': '',
          '22': true,
          '22+t': 'L\'élève ne portait pas ses gants malgré plusieurs avertissements, '
              'et il s\'est ouvert profondément la paume en voulant couper une tige.',
          '23': 'Joanie, la propriétaire'
        },
      ),
      incidents: Incidents.empty,
      minimumAge: 15,
      preInternshipRequest: PreInternshipRequest(requests: []),
      uniform: Uniform(status: UniformStatus.none),
      protections: Protections(status: ProtectionsStatus.none),
    ),
  );
  enterprises.add(
    Enterprise(
      name: 'Le jardin de Joanie',
      activityTypes: {activityTypes[6], activityTypes[14]},
      recrutedBy: teachers[0].id,
      shareWith: 'Mon centre de services scolaire',
      jobs: jobs,
      contact: Person(
        firstName: 'Joanie',
        lastName: 'Lemieux',
        phone: PhoneNumber.fromString('438 789 6543'),
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
      specialization: ActivitySectorsService.sectors[1].specializations[2],
      positionsOffered: 1,
      sstEvaluation: JobSstEvaluation(
        questions: {
          '1': 'Arroser les fleurs et les plantes, aider à la confection de '
              'couronnes, sortir et ranger les plantes à l\'ouverture et à la '
              'fermeture de la boutique',
          '2': true,
          '2+t': '',
          '3': true,
          '3+t': 'En début et en fin de journée, surtout des pots de fleurs.',
          '5': ['Un diable'],
          '6': [],
          '7': ['Un couteau', 'Des ciseaux'],
          '8': [],
          '10': ['Des pesticides', 'Engrais'],
          '15': [],
          '16': false,
          '19': false,
          '20': '',
          '21': '',
          '22': false,
          '22+t': '',
          '23': 'Gaëtan Munger, le gérant'
        },
      ),
      incidents: Incidents.empty,
      minimumAge: 15,
      preInternshipRequest: PreInternshipRequest(requests: []),
      uniform: Uniform(status: UniformStatus.none),
      protections: Protections(status: ProtectionsStatus.none),
    ),
  );
  enterprises.add(
    Enterprise(
      name: 'Fleuriste Joli',
      activityTypes: {activityTypes[6], activityTypes[14]},
      recrutedBy: teachers[0].id,
      shareWith: 'Mon centre de services scolaire',
      jobs: jobs,
      contact: Person(
        firstName: 'Gaëtan',
        lastName: 'Munger',
        phone: PhoneNumber.fromString('514 987 6543'),
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

Future<void> addDummyStudents(
    StudentsProvider students, TeachersProvider teachers) async {
  students.add(
    Student(
      firstName: 'Cedric',
      lastName: 'Masson',
      dateBirth: DateTime(2005, 5, 20),
      email: 'c.masson@email.com',
      teacherId: teachers.currentTeacherId,
      program: Program.fpt,
      group: '550',
      address: await Address.fromAddress(
          '7248 Rue D\'Iberville, Montréal, QC H2E 2Y6'),
      phone: PhoneNumber.fromString('514 321 8888'),
      contact: Person(
          firstName: 'Paul',
          lastName: 'Masson',
          phone: PhoneNumber.fromString('514 321 9876'),
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
      program: Program.fpt,
      group: '885',
      contact: Person(
          firstName: 'Jean-Pierre',
          lastName: 'Caron Mathieu',
          phone: PhoneNumber.fromString('514 321 9876'),
          email: 'j.caron@email.com'),
      contactLink: 'Père',
      address: await Address.fromAddress(
          '202 Boulevard Saint-Joseph Est, Montréal, QC H1X 2T2'),
      phone: PhoneNumber.fromString('514 222 3344'),
    ),
  );

  students.add(
    Student(
      firstName: 'Mikael',
      lastName: 'Boucher',
      dateBirth: DateTime.now(),
      email: 'm.boucher@email.com',
      teacherId: teachers.currentTeacherId,
      program: Program.fpt,
      group: '885',
      contact: Person(
          firstName: 'Nicole',
          lastName: 'Lefranc',
          phone: PhoneNumber.fromString('514 321 9876'),
          email: 'n.lefranc@email.com'),
      contactLink: 'Mère',
      address: await Address.fromAddress('6723 25e Ave, Montréal, QC H1T 3M1'),
      phone: PhoneNumber.fromString('514 333 4455'),
    ),
  );

  students.add(
    Student(
      firstName: 'Kevin',
      lastName: 'Leblanc',
      dateBirth: DateTime.now(),
      email: 'k.leblanc@email.com',
      teacherId: teachers.currentTeacherId,
      program: Program.fpt,
      group: '550',
      contact: Person(
          firstName: 'Martine',
          lastName: 'Gagnon',
          phone: PhoneNumber.fromString('514 321 9876'),
          email: 'm.gagnon@email.com'),
      contactLink: 'Mère',
      address:
          await Address.fromAddress('9277 Rue Meunier, Montréal, QC H2N 1W4'),
      phone: PhoneNumber.fromString('514 999 8877'),
    ),
  );

  students.add(
    Student(
      firstName: 'Simon',
      lastName: 'Gingras',
      dateBirth: DateTime.now(),
      email: 's.gingras@email.com',
      teacherId: '42', // This is a Roméo Montaigu's student
      program: Program.fms,
      group: '789',
      contact: Person(
          firstName: 'Raoul',
          lastName: 'Gingras',
          email: 'r.gingras@email.com',
          phone: PhoneNumber.fromString('514 321 9876')),
      contactLink: 'Père',
      address: await Address.fromAddress(
          '4517 Rue d\'Assise, Saint-Léonard, QC H1R 1W2'),
      phone: PhoneNumber.fromString('514 888 7766'),
    ),
  );

  students.add(
    Student(
      firstName: 'Diego',
      lastName: 'Vargas',
      dateBirth: DateTime.now(),
      email: 'd.vargas@email.com',
      teacherId: '42', // This is a Roméo Montaigu's student
      program: Program.fpt,
      group: '789',
      contact: Person(
          firstName: 'Laura',
          lastName: 'Vargas',
          phone: PhoneNumber.fromString('514 321 9876'),
          email: 'l.vargas@email.com'),
      contactLink: 'Mère',
      address: await Address.fromAddress(
          '8204 Rue de Blois, Saint-Léonard, QC H1R 2X1'),
      phone: PhoneNumber.fromString('514 444 5566'),
    ),
  );

  students.add(
    Student(
      firstName: 'Jeanne',
      lastName: 'Tremblay',
      dateBirth: DateTime.now(),
      email: 'g.tremblay@email.com',
      teacherId: teachers.currentTeacherId,
      program: Program.fpt,
      group: '885',
      contact: Person(
          firstName: 'Vincent',
          lastName: 'Tremblay',
          phone: PhoneNumber.fromString('514 321 9876'),
          email: 'v.tremblay@email.com'),
      contactLink: 'Père',
      address: await Address.fromAddress(
          '8358 Rue Jean-Nicolet, Saint-Léonard, QC H1R 2R2'),
      phone: PhoneNumber.fromString('514 555 9988'),
    ),
  );

  students.add(
    Student(
      firstName: 'Vincent',
      lastName: 'Picard',
      dateBirth: DateTime.now(),
      email: 'v.picard@email.com',
      teacherId: teachers.currentTeacherId,
      program: Program.fms,
      group: '789',
      contact: Person(
          firstName: 'Jean-François',
          lastName: 'Picard',
          phone: PhoneNumber.fromString('514 321 9876'),
          email: 'jp.picard@email.com'),
      contactLink: 'Père',
      address: await Address.fromAddress(
          '8382 Rue du Laus, Saint-Léonard, QC H1R 2P4'),
      phone: PhoneNumber.fromString('514 778 8899'),
    ),
  );

  students.add(
    Student(
      firstName: 'Vanessa',
      lastName: 'Monette',
      dateBirth: DateTime.now(),
      email: 'v.monette@email.com',
      teacherId: teachers.currentTeacherId,
      program: Program.fms,
      group: '789',
      contact: Person(
          firstName: 'Stéphane',
          lastName: 'Monette',
          phone: PhoneNumber.fromString('514 321 9876'),
          email: 's.monette@email.com'),
      contactLink: 'Père',
      address: await Address.fromAddress(
          '6865 Rue Chaillot, Saint-Léonard, QC H1T 3R5'),
      phone: PhoneNumber.fromString('514 321 6655'),
    ),
  );

  students.add(
    Student(
      firstName: 'Melissa',
      lastName: 'Poulain',
      dateBirth: DateTime.now(),
      email: 'm.poulain@email.com',
      teacherId: teachers.currentTeacherId,
      program: Program.fms,
      group: '789',
      contact: Person(
          firstName: 'Mathieu',
          lastName: 'Poulain',
          phone: PhoneNumber.fromString('514 321 9876'),
          email: 'm.poulain@email.com'),
      contactLink: 'Père',
      address:
          await Address.fromAddress('6585 Rue Lemay, Montréal, QC H1T 2L8'),
      phone: PhoneNumber.fromString('514 567 9999'),
    ),
  );

  await _waitForDatabaseUpdate(students, 10);

  // Simulate that some of the students were actually added by someone else
  {
    final student =
        students.firstWhere((student) => student.fullName == 'Diego Vargas');
    FirebaseDatabase.instance
        .ref('/students-ids/42/')
        .child(student.id)
        .set(true);
    FirebaseDatabase.instance
        .ref(students.pathToAvailableDataIds)
        .child(student.id)
        .remove();
  }
  {
    final student =
        students.firstWhere((student) => student.fullName == 'Simon Gingras');
    FirebaseDatabase.instance
        .ref('/students-ids/42/')
        .child(student.id)
        .set(true);
    FirebaseDatabase.instance
        .ref(students.pathToAvailableDataIds)
        .child(student.id)
        .remove();
  }
  await _waitForDatabaseUpdate(students, 8);
}

Future<void> addDummyInterships(
  InternshipsProvider internships,
  StudentsProvider students,
  EnterprisesProvider enterprises,
  TeachersProvider teachers,
) async {
  final rng = Random();

  var period = DateTimeRange(
      start: DateTime.now(),
      end: DateTime.now().add(Duration(days: rng.nextInt(90))));
  internships.add(Internship(
    versionDate: DateTime.now(),
    studentId: students.firstWhere((e) => e.fullName == 'Cedric Masson').id,
    teacherId: teachers.currentTeacherId,
    enterpriseId: enterprises.firstWhere((e) => e.name == 'Auto Care').id,
    jobId: enterprises.firstWhere((e) => e.name == 'Auto Care').jobs[0].id,
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
  ));

  var startingPeriod = DateTime.now().subtract(Duration(days: rng.nextInt(90)));
  period = DateTimeRange(
      start: startingPeriod,
      end: startingPeriod.add(Duration(days: rng.nextInt(50))));
  internships.add(Internship(
    versionDate: DateTime.now(),
    studentId: students.firstWhere((e) => e.fullName == 'Thomas Caron').id,
    teacherId: teachers.currentTeacherId,
    enterpriseId:
        enterprises.firstWhere((e) => e.name == 'Boucherie Marien').id,
    jobId:
        enterprises.firstWhere((e) => e.name == 'Boucherie Marien').jobs[0].id,
    extraSpecializationsId: [],
    visitingPriority: VisitingPriority.values[0],
    supervisor: Person(firstName: 'Nobody', lastName: 'Forever'),
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
  ));

  period = DateTimeRange(
      start: DateTime.now(),
      end: DateTime.now().add(Duration(days: rng.nextInt(90))));
  var internship = Internship(
    versionDate: DateTime.now(),
    studentId: students.firstWhere((e) => e.fullName == 'Melissa Poulain').id,
    teacherId: teachers.currentTeacherId,
    enterpriseId: enterprises.firstWhere((e) => e.name == 'Subway').id,
    jobId: enterprises.firstWhere((e) => e.name == 'Subway').jobs[0].id,
    extraSpecializationsId: [],
    visitingPriority: VisitingPriority.values[0],
    supervisor: Person(firstName: 'Nobody', lastName: 'Forever'),
    date: period,
    endDate: DateTime.now().add(const Duration(days: 10)),
    expectedLength: 135,
    achievedLength: 125,
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
        ],
        period: period,
      ),
    ],
  );
  internship.enterpriseEvaluation = PostIntershipEnterpriseEvaluation(
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

  period = DateTimeRange(
      start: DateTime.now(),
      end: DateTime.now().add(Duration(days: rng.nextInt(90))));
  internships.add(Internship(
    versionDate: DateTime.now(),
    studentId: students.firstWhere((e) => e.fullName == 'Vincent Picard').id,
    teacherId: teachers.currentTeacherId,
    enterpriseId: enterprises.firstWhere((e) => e.name == 'IGA').id,
    jobId: enterprises.firstWhere((e) => e.name == 'IGA').jobs[0].id,
    extraSpecializationsId: [],
    visitingPriority: VisitingPriority.values[0],
    supervisor: Person(firstName: 'Nobody', lastName: 'Forever'),
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
        ],
        period: period,
      ),
    ],
  ));

  period = DateTimeRange(
      start: DateTime.now(),
      end: DateTime.now().add(Duration(days: rng.nextInt(90))));
  internships.add(Internship(
    versionDate: DateTime.now(),
    studentId: students.firstWhere((e) => e.fullName == 'Simon Gingras').id,
    teacherId: '42', // This is a Roméo Montaigu's student
    enterpriseId: enterprises.firstWhere((e) => e.name == 'Metro Gagnon').id,
    jobId: enterprises.firstWhere((e) => e.name == 'Metro Gagnon').jobs[1].id,
    extraSpecializationsId: [],
    visitingPriority: VisitingPriority.values[0],
    supervisor: Person(firstName: 'Nobody', lastName: 'Forever'),
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
            dayOfWeek: Day.wednesday,
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
  ));

  period = DateTimeRange(
      start: DateTime.now(),
      end: DateTime.now().add(Duration(days: rng.nextInt(90))));
  internships.add(Internship(
    versionDate: DateTime.now(),
    studentId: students.firstWhere((e) => e.fullName == 'Jeanne Tremblay').id,
    teacherId: '42', // Transfered to Roméo Montaigu
    isTransfering: false,
    enterpriseId: enterprises.firstWhere((e) => e.name == 'Metro Gagnon').id,
    jobId: enterprises.firstWhere((e) => e.name == 'Metro Gagnon').jobs[0].id,
    extraSpecializationsId: [],
    visitingPriority: VisitingPriority.values[0],
    supervisor: Person(firstName: 'Nobody', lastName: 'Forever'),
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
  ));

  period = DateTimeRange(
      start: DateTime.now(),
      end: DateTime.now().add(Duration(days: rng.nextInt(90))));
  internships.add(Internship(
    versionDate: DateTime.now(),
    studentId: students.firstWhere((e) => e.fullName == 'Diego Vargas').id,
    teacherId: teachers.currentTeacherId,
    previousTeacherId: '42', // Was transfered from Roméo Montaigu
    isTransfering: true,
    enterpriseId: enterprises.firstWhere((e) => e.name == 'Metro Gagnon').id,
    jobId: enterprises.firstWhere((e) => e.name == 'Metro Gagnon').jobs[1].id,
    extraSpecializationsId: [],
    visitingPriority: VisitingPriority.values[0],
    supervisor: Person(firstName: 'Nobody', lastName: 'Forever'),
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
  ));

  startingPeriod = DateTime.now().subtract(Duration(days: rng.nextInt(250)));
  period = DateTimeRange(
      start: startingPeriod,
      end: startingPeriod.add(Duration(days: rng.nextInt(50))));
  internships.add(
    Internship(
      versionDate: DateTime.now(),
      studentId: students.firstWhere((e) => e.fullName == 'Vanessa Monette').id,
      teacherId: teachers.currentTeacherId,
      isTransfering: false,
      enterpriseId: enterprises.firstWhere((e) => e.name == 'Jean Coutu').id,
      jobId: enterprises.firstWhere((e) => e.name == 'Jean Coutu').jobs[0].id,
      extraSpecializationsId: [],
      visitingPriority: VisitingPriority.values[0],
      supervisor: Person(firstName: 'Un', lastName: 'Ami'),
      date: period,
      endDate: period.end,
      expectedLength: 135,
      achievedLength: 100,
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
          ],
          period: period,
        ),
      ],
    ),
  );

  startingPeriod = DateTime.now().subtract(Duration(days: rng.nextInt(200)));
  period = DateTimeRange(
      start: startingPeriod,
      end: startingPeriod.add(Duration(days: rng.nextInt(50))));
  internships.add(Internship(
    versionDate: DateTime.now(),
    studentId: students.firstWhere((e) => e.fullName == 'Vanessa Monette').id,
    teacherId: teachers.currentTeacherId,
    isTransfering: false,
    enterpriseId: enterprises.firstWhere((e) => e.name == 'Pharmaprix').id,
    jobId: enterprises.firstWhere((e) => e.name == 'Pharmaprix').jobs[0].id,
    extraSpecializationsId: [],
    visitingPriority: VisitingPriority.values[0],
    supervisor: Person(firstName: 'Deux', lastName: 'Ami'),
    date: period,
    endDate: period.end,
    expectedLength: 135,
    achievedLength: 100,
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
        ],
        period: period,
      ),
    ],
  ));
  await _waitForDatabaseUpdate(internships, 9);
}

Future<void> _waitForDatabaseUpdate(
    FirebaseListProvided list, int expectedLength) async {
  // Wait for the database to add all the students
  while (list.length < expectedLength) {
    await Future.delayed(const Duration(milliseconds: 100));
  }
}
