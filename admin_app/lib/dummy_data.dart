// coverage:ignore-file
import 'dart:developer' as dev;

import 'package:admin_app/providers/school_boards_provider.dart';
import 'package:admin_app/providers/students_provider.dart';
import 'package:admin_app/providers/teachers_provider.dart';
import 'package:common/models/generic/address.dart';
import 'package:common/models/generic/phone_number.dart';
import 'package:common/models/persons/person.dart';
import 'package:common/models/persons/student.dart';
import 'package:common/models/persons/teacher.dart';
import 'package:common/models/school_boards/school.dart';
import 'package:common/models/school_boards/school_board.dart';
import 'package:common/utils.dart';
import 'package:enhanced_containers/enhanced_containers.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

Future<void> resetDummyData(BuildContext context) async {
  final schoolBoards = SchoolBoardsProvider.of(context, listen: false);
  final teachers = TeachersProvider.of(context, listen: false);
  final students = StudentsProvider.of(context, listen: false);
  // TODO Enterprises should store all the teachers that have recruited them and
  // fixed the shareWith field to be a list of teacher ids

  await _removeAll(students, teachers, schoolBoards);

  // TODO Look for Quebec servers (OVH, Akamai, Vultr, etc.) to host the database
  await _addDummySchoolBoards(schoolBoards);
  await _addDummyTeachers(teachers, schoolBoards);
  await _addDummyStudents(students, teachers);

  dev.log('Dummy reset data done');
}

Future<void> _removeAll(
  StudentsProvider students,
  TeachersProvider teachers,
  SchoolBoardsProvider schoolBoards,
) async {
  dev.log('Removing dummy data');

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
        postalCode: 'H2N 1Y5',
      ),
    ),
    School(
      name: 'Ma deuxième école',
      address: Address(
        civicNumber: 9105,
        street: 'Rue Verville',
        city: 'Montréal',
        postalCode: 'H2N 1Y5',
      ),
    ),
  ];
  schoolBoards.add(
    SchoolBoard(
      id: DevAuth.devMySchoolBoardId,
      name: 'Ma commission scolaire',
      schools: schools.toList(),
    ),
  );
  await _waitForDatabaseUpdate(schoolBoards, 1);

  // Test the replace function

  // Change the name of the schoolboard
  schoolBoards.replace(
    schoolBoards[0].copyWith(name: 'Ma première commission scolaire'),
  );
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
  TeachersProvider teachers,
  SchoolBoardsProvider schoolBoards,
) async {
  dev.log('Adding dummy teachers');

  teachers.add(
    Teacher(
      id: _partnerTeacherId,
      firstName: 'Roméo',
      middleName: null,
      lastName: 'Montaigu',
      schoolBoardId: schoolBoards[0].id,
      schoolId: schoolBoards[0].schools[0].id,
      groups: ['550', '551'],
      email: 'romeo.montaigu@shakespeare.qc',
      phone: null,
      address: null,
      dateBirth: null,
      itineraries: [],
    ),
  );

  teachers.add(
    Teacher(
      id: teachers.currentTeacherId,
      firstName: 'Juliette',
      middleName: null,
      lastName: 'Capulet',
      schoolBoardId: schoolBoards[0].id,
      schoolId: schoolBoards[0].schools[0].id,
      groups: ['550', '551'],
      email: 'juliette.capulet@shakespeare.qc',
      phone: null,
      address: null,
      dateBirth: null,
      itineraries: [],
    ),
  );

  teachers.add(
    Teacher(
      firstName: 'Tybalt',
      middleName: null,
      lastName: 'Capulet',
      schoolBoardId: schoolBoards[0].id,
      schoolId: schoolBoards[0].schools[0].id,
      groups: ['550', '551'],
      email: 'tybalt.capulet@shakespeare.qc',
      phone: null,
      address: null,
      dateBirth: null,
      itineraries: [],
    ),
  );

  teachers.add(
    Teacher(
      firstName: 'Benvolio',
      middleName: null,
      lastName: 'Montaigu',
      schoolBoardId: schoolBoards[0].id,
      schoolId: schoolBoards[0].schools[0].id,
      groups: ['552'],
      email: 'benvolio.montaigu@shakespeare.qc',
      phone: null,
      address: null,
      dateBirth: null,
      itineraries: [],
    ),
  );
  await _waitForDatabaseUpdate(teachers, 4);
}

Future<void> _addDummyStudents(
  StudentsProvider students,
  TeachersProvider teachers,
) async {
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
        postalCode: 'H2E 2Y6',
      ),
      phone: PhoneNumber.fromString('514 321 8888'),
      contact: Person(
        firstName: 'Paul',
        middleName: null,
        lastName: 'Masson',
        dateBirth: null,
        phone: PhoneNumber.fromString('514 321 9876'),
        address: null,
        email: 'p.masson@email.com',
      ),
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
        address: null,
        email: 'j.caron@email.com',
      ),
      contactLink: 'Père',
      address: Address(
        civicNumber: 202,
        street: 'Boulevard Saint-Joseph Est',
        city: 'Montréal',
        postalCode: 'H1X 2T2',
      ),
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
        address: null,
        email: 'n.lefranc@email.com',
      ),
      contactLink: 'Mère',
      address: Address(
        civicNumber: 6723,
        street: '25e Ave',
        city: 'Montréal',
        postalCode: 'H1T 3M1',
      ),
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
        address: null,
        email: 'm.gagnon@email.com',
      ),
      contactLink: 'Mère',
      address: Address(
        civicNumber: 9277,
        street: 'Rue Meunier',
        city: 'Montréal',
        postalCode: 'H2N 1W4',
      ),
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
        address: null,
      ),
      contactLink: 'Père',
      address: Address(
        civicNumber: 4517,
        street: 'Rue d\'Assise',
        city: 'Saint-Léonard',
        postalCode: 'H1R 1W2',
      ),
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
        address: null,
        email: 'l.vargas@email.com',
      ),
      contactLink: 'Mère',
      address: Address(
        civicNumber: 8204,
        street: 'Rue de Blois',
        city: 'Saint-Léonard',
        postalCode: 'H1R 2X1',
      ),
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
        address: null,
        email: 'v.tremblay@email.com',
      ),
      contactLink: 'Père',
      address: Address(
        civicNumber: 8358,
        street: 'Rue Jean-Nicolet',
        city: 'Saint-Léonard',
        postalCode: 'H1R 2R2',
      ),
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
        address: null,
        email: 'jp.picard@email.com',
      ),
      contactLink: 'Père',
      address: Address(
        civicNumber: 8382,
        street: 'Rue du Laus',
        city: 'Saint-Léonard',
        postalCode: 'H1R 2P4',
      ),
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
        address: null,
        email: 's.monette@email.com',
      ),
      contactLink: 'Père',
      address: Address(
        civicNumber: 6865,
        street: 'Rue Chaillot',
        city: 'Saint-Léonard',
        postalCode: 'H1T 3R5',
      ),
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
        address: null,
        email: 'm.poulain@email.com',
      ),
      contactLink: 'Père',
      address: Address(
        civicNumber: 6585,
        street: 'Rue Lemay',
        city: 'Montréal',
        postalCode: 'H1T 2L8',
      ),
      phone: PhoneNumber.fromString('514 567 9999'),
    ),
  );

  await _waitForDatabaseUpdate(students, 10);
}

Future<void> _waitForDatabaseUpdate(
  DatabaseListProvided list,
  int expectedDuration, {
  bool strictlyEqualToExpected = false,
}) async {
  // Wait for the database to add all the students
  while (strictlyEqualToExpected
      ? list.length != expectedDuration
      : list.length < expectedDuration) {
    await Future.delayed(const Duration(milliseconds: 100));
  }
}
