// coverage:ignore-file
import 'dart:developer' as dev;

import 'package:admin_app/providers/school_boards_provider.dart';
import 'package:admin_app/providers/teachers_provider.dart';
import 'package:common/models/generic/address.dart';
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
  // TODO Enterprises should store all the teachers that have recruited them and
  // fixed the shareWith field to be a list of teacher ids

  await _removeAll(teachers, schoolBoards);

  // TODO Look for Quebec servers (OVH, Akamai, Vultr, etc.) to host the database
  await _addDummySchoolBoards(schoolBoards);
  await _addDummyTeachers(teachers, schoolBoards);

  dev.log('Dummy reset data done');
}

Future<void> _removeAll(
  TeachersProvider teachers,
  SchoolBoardsProvider schoolBoards,
) async {
  dev.log('Removing dummy data');
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
