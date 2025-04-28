import 'package:collection/collection.dart';
import 'package:common/communication_protocol.dart';
import 'package:common/models/persons/student.dart';
import 'package:crcrme_banque_stages/common/providers/auth_provider.dart';
import 'package:crcrme_banque_stages/common/providers/backend_list_provided.dart';
import 'package:crcrme_banque_stages/common/providers/internships_provider.dart';
import 'package:crcrme_banque_stages/common/providers/teachers_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StudentsProvider extends BackendListProvided<Student> {
  StudentsProvider({required super.uri, super.mockMe});

  @override
  RequestFields getField([bool asList = false]) {
    return asList ? RequestFields.students : RequestFields.student;
  }

  ///
  /// This returns the students the teacher should have read/write access too.
  /// These are the students from the group the teacher teaches too (even though
  /// they are not supervising them personnally)
  static List<Student> studentsInMyGroups(context, {listen = true}) {
    final acceptedGroups =
        TeachersProvider.of(context, listen: false).currentTeacher.groups;
    return _of(context, listen: listen)
        .where((e) => acceptedGroups.contains(e.group))
        .toList();
  }

  ///
  /// Get all the supervized students. If [activeOnly], the students without an
  /// active internship are ignored
  static List<Student> mySupervizedStudents(BuildContext context,
      {listen = true, bool activeOnly = false}) {
    final allStudents = studentsInMyGroups(context, listen: listen);
    final internships = InternshipsProvider.of(context, listen: false);
    final myTeacherId =
        TeachersProvider.of(context, listen: false).currentTeacherId;

    // Get the student I supervise by default
    final List<Student> out = [];
    // Add them those that were transfered to me
    for (final internship in internships) {
      // If I am not in charge of this internship
      if (!internship.supervisingTeacherIds.contains(myTeacherId)) continue;

      // If it is not active (or that we should keep the inactive)
      if (activeOnly && internship.isNotActive) continue;

      // Get the student from that internship
      final student =
          allStudents.firstWhereOrNull((e) => e.id == internship.studentId);

      // If none of the students I can access is assigned to that internship
      if (student == null) continue;

      // If the student assigned to that internship was already added
      if (out.any((e) => e.id == student.id)) continue;

      // Otherwise all this, add it to the pool
      out.add(student);
    }

    return out;
  }

  ///
  /// This is an instance to the Provider, 99% of the time this should not be called.
  /// Using this can lead to a potential security breach as it access all the students
  /// info without restriction. It is used for debug purposes.
  static StudentsProvider instance(context, {bool listen = true}) {
    if (!kDebugMode) throw 'This should not be called in production';
    return _of(context, listen: listen);
  }

  ///
  /// This returns all the students from the database but with very limited info
  static List<Student> allStudentsLimitedInfo(context) {
    return _of(context, listen: false).map((e) => e.limitedInfo).toList();
  }

  ///
  /// Internal accessor to the provider. This holds ALL the students, including
  /// those that the teacher should not have access to.
  static StudentsProvider _of(BuildContext context, {listen = true}) {
    return Provider.of<StudentsProvider>(context, listen: listen);
  }

  @override
  Student deserializeItem(data) {
    return Student.fromSerialized(data);
  }

  Future<void> initializeAuth(AuthProvider auth) async {
    await initializeFetchingData(authProvider: auth);
  }
}
