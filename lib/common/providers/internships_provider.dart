import 'package:enhanced_containers/enhanced_containers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/common/models/internship.dart';
import '/common/models/student.dart';
import '/common/models/visiting_priority.dart';
import '/common/providers/students_provider.dart';
import '/common/providers/teachers_provider.dart';

class InternshipsProvider extends FirebaseListProvided<Internship> {
  InternshipsProvider() : super(pathToData: "internships") {
    initializeFetchingData();
  }

  static InternshipsProvider of(BuildContext context, {listen = true}) =>
      Provider.of<InternshipsProvider>(context, listen: listen);

  void replacePriority(
    String studentId,
    VisitingPriority priority,
  ) {
    // It makes sense to only prioretize the last intership
    replace(byStudentId(studentId).last.copyWith(visitingPriority: priority));
  }

  void transferStudent(
      {required String studentId, required String newTeacherId}) {
    final internship = byStudentId(studentId);
    if (internship.isEmpty || internship.last.isTransfering) return;

    replace(internship.last.copyWith(
        teacherId: newTeacherId,
        previousTeacherId: internship.last.teacherId,
        isTransfering: true));
  }

  ///
  /// Get all the students who the current teacher is assigned to, meaning
  /// they supervise this student for their internship
  ///
  static List<Student> mySupervisedStudents(BuildContext context, {listen = true}) {
    final myId = TeachersProvider.of(context, listen: false).currentTeacherId;
    final internships = InternshipsProvider.of(context, listen: listen);
    final students = StudentsProvider.of(context, listen: listen);

    return students
        .map<Student?>((student) {
          final studentInternships = internships.byStudentId(student.id);
          if (studentInternships.isEmpty) {
            // Even though the student does not have an internship yet, the
            // current teacher supervise them if they are assigned to them
            return student.teacherId == myId ? student : null;
          }
          return studentInternships.last.teacherId == myId ? student : null;
        })
        .where((e) => e != null)
        .toList()
        .cast<Student>();
  }

  void acceptTransfer({required String studentId}) {
    final internship = byStudentId(studentId);
    replace(internship.last.copyWith(isTransfering: false));
  }

  void refuseTransfer({required String studentId}) {
    final internship = byStudentId(studentId);
    replace(internship.last.copyWith(
        teacherId: internship.last.previousTeacherId, isTransfering: false));
  }

  List<Internship> byStudentId(String studentId) {
    return where((intership) => intership.studentId == studentId).toList();
  }

  @override
  Internship deserializeItem(data) {
    return Internship.fromSerialized(data);
  }
}
