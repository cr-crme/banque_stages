import 'package:enhanced_containers/enhanced_containers.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:crcrme_banque_stages/common/models/student.dart';
import 'auth_provider.dart';
import 'internships_provider.dart';
import 'teachers_provider.dart';

class StudentsProvider extends FirebaseListProvided<Student> {
  StudentsProvider()
      : super(
          pathToData: 'students',
          pathToAvailableDataIds: '',
        );

  static StudentsProvider of(BuildContext context, {listen = true}) {
    return Provider.of<StudentsProvider>(context, listen: listen);
  }

  @override
  Student deserializeItem(data) {
    return Student.fromSerialized(data);
  }

  void initializeAuth(AuthProvider auth) {
    pathToAvailableDataIds = auth.currentUser == null
        ? ''
        : '/students-ids/${auth.currentUser!.uid}/';
    initializeFetchingData();
  }

  ///
  /// Get all the students who the current teacher is assigned to, meaning
  /// they supervise this student for their internship (which
  /// includes students that are not in charge of the current teacher).
  /// If [onlyActiveInternship] is set to true, then the student must have an
  /// active internship to be added. Otherwise all students from the teachers
  /// are returned (even though they are not assigned to a particular
  /// internship)
  ///
  static Future<List<Student>> getMySupervizedStudents(BuildContext context,
      {listen = true, bool onlyActiveInternship = false}) async {
    final myId = TeachersProvider.of(context, listen: false).currentTeacherId;
    final List<Student> out = onlyActiveInternship
        ? []
        : of(context, listen: false).map((e) => e).toList();

    for (final internship in InternshipsProvider.of(context, listen: listen)) {
      if (internship.isNotActive || internship.teacherId != myId) continue;
      if (out.any((e) => e.id == internship.studentId)) continue;

      final student =
          await fromLimitedId(context, studentId: internship.studentId);
      if (student == null) continue;
      out.add(student);
    }

    return out;
  }

  /// This allows to get access in read only to a student of id [studentId]
  /// outside of the available ones, so all the student can be shown if needed
  ///
  static Future<Student?> fromLimitedId(context,
      {required String studentId}) async {
    final students = StudentsProvider.of(context, listen: false);
    // In case this is a student we happen to already have access, we can
    // return this one already instead of fetching it from the database
    if (students.hasId(studentId)) {
      return students.deserializeItem(students[studentId].serialize());
    }

    final snapshot = await FirebaseDatabase.instance
        .ref(students.pathToData)
        .child(studentId)
        .get();
    if (!snapshot.exists) {
      return null;
    }

    return students.deserializeItem(snapshot.value);
  }
}
