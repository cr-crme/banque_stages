import 'package:collection/collection.dart';
import 'package:crcrme_banque_stages/common/models/student.dart';
import 'package:enhanced_containers/enhanced_containers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth_provider.dart';
import 'internships_provider.dart';
import 'teachers_provider.dart';

class StudentsProvider extends FirebaseListProvided<Student> {
  StudentsProvider()
      : super(
          pathToData: 'students',
          pathToAvailableDataIds: '',
        );

  ///
  /// This returns the students the teacher should have read/write access too.
  /// These are the students from the group the teacher teaches too (even though
  /// they are not supervising them personnally)
  static List<Student> studentsInMyGroup(context, {listen = true}) {
    final acceptedGroups =
        TeachersProvider.of(context, listen: false).currentTeacher.groups;
    return _of(context, listen: listen)
        .where((e) => acceptedGroups.contains(e.group))
        .toList();
  }

  ///
  /// Get the subset of students who the current teacher is assigned to.
  static List<Student> myAssignedStudents(BuildContext context,
      {listen = true}) {
    final myTeacherId =
        TeachersProvider.of(context, listen: false).currentTeacherId;

    // Get all the student in my group, but only keep those I supervise
    return studentsInMyGroup(context, listen: false)
        .where((e) => e.teacherId == myTeacherId)
        .toList();
  }

  ///
  /// Get all the supervized students, that is the assigned students, plus
  /// those from another teacher that transfered them. This does not include
  /// the transfered internships that have ended, unless
  /// [includeFinishedFromTransfered] is set to true.
  static List<Student> mySupervizedStudents(BuildContext context,
      {listen = true, bool includeFinishedFromTransfered = false}) {
    final allStudents = studentsInMyGroup(context, listen: listen);
    final internships = InternshipsProvider.of(context, listen: false);
    final myTeacherId =
        TeachersProvider.of(context, listen: false).currentTeacherId;

    // Get the student I supervise by default
    final out = myAssignedStudents(context);
    // Add them those that were transfered to me
    for (final internship in internships) {
      // If I am not in charge of this internship
      if (internship.teacherId != myTeacherId) continue;

      // If it is not active (or that we should keep the inactive)
      if (internship.isNotActive || includeFinishedFromTransfered) continue;

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

  void initializeAuth(AuthProvider auth) {
    // This makes each student separated by teacher
    // pathToAvailableDataIds = auth.currentUser == null
    //     ? ''
    //     : '/students-ids/${auth.currentUser!.uid}/';

    // This makes all students available for all teachers
    pathToAvailableDataIds = '/students-ids/all/';

    initializeFetchingData();
  }
}
