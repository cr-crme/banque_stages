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
  /// Get the subset of students who the current teacher is assigned to, meaning
  /// they supervise this student for their internship.
  /// If [onlyActiveInternship] is set to true, then the student must have an
  /// active internship to be added. Otherwise all students from the teachers
  /// are returned (even though they are not assigned to a particular
  /// internship)
  ///
  static List<Student> mySupervizedStudents(BuildContext context,
      {listen = true, bool onlyActiveInternship = false}) {
    final myTeacherId =
        TeachersProvider.of(context, listen: false).currentTeacherId;

    // Get all the student in my group, but only keep those I supervise
    var students = studentsInMyGroup(context, listen: false);
    students = students.where((e) => e.teacherId == myTeacherId).toList();

    // If we don't need the active interships, we are done
    if (!onlyActiveInternship) return students;

    final internships = InternshipsProvider.of(context, listen: false);
    final List<Student> out = [];
    for (final internship in internships) {
      // If it is not active or an internship I am in charge
      if (internship.isNotActive || internship.teacherId != myTeacherId) {
        continue;
      }

      // If none of my students is assigned to that internship
      if (!students.any((e) => e.id == internship.studentId)) continue;

      // If the student assigned to that internship was already added
      final student =
          students.firstWhereOrNull((e) => e.id == internship.studentId);
      if (student == null) continue;

      out.add(student);
    }

    return out;
  }

  ///
  /// This is an instance to the Provider, 99% of the time this should not be called
  static StudentsProvider instance(context, {bool listen = true}) {
    return _of(context, listen: listen);
  }

  ///
  /// This retunrs all the students from the database. This should be a limited
  /// access!
  static List<Student> allStudents(context) {
    return [..._of(context, listen: false)];
  }

  ///
  /// Internal accessor to the provider
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

  // /// This allows to get access in read only to a student of id [studentId]
  // /// outside of the available ones, so all the student can be shown if needed
  // ///
  // static Future<Student?> fromLimitedId(context,
  //     {required String studentId}) async {
  //   final students = StudentsProvider.of(context, listen: false);
  //   // In case this is a student we happen to already have access, we can
  //   // return this one already instead of fetching it from the database
  //   if (students.hasId(studentId)) {
  //     return students.deserializeItem(students[studentId].serialize());
  //   }

  //   final snapshot = await FirebaseDatabase.instance
  //       .ref(students.pathToData)
  //       .child(studentId)
  //       .get();
  //   if (!snapshot.exists) {
  //     return null;
  //   }

  //   return students.deserializeItem(snapshot.value);
  // }
}
