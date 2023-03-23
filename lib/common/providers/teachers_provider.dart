import 'package:enhanced_containers/enhanced_containers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/common/models/student.dart';
import '/common/models/teacher.dart';
import '/common/providers/internships_provider.dart';
import '/common/providers/students_provider.dart';

class TeachersProvider extends FirebaseListProvided<Teacher> {
  TeachersProvider() : super(pathToData: 'teachers');

  static TeachersProvider of(BuildContext context, {listen = false}) =>
      Provider.of<TeachersProvider>(context, listen: listen);

  @override
  Teacher deserializeItem(data) {
    return Teacher.fromSerialized(data);
  }

  String _currentId = '';
  String get currentTeacherId => _currentId;
  set currentTeacherId(String id) {
    _currentId = id;
    notifyListeners();
  }

  Teacher get currentTeacher => this[_currentId];

  ///
  /// Get all the who the current teacher is in charge. Meaning they are
  /// responsible in a more general way
  ///
  static List<Student> getInChargeStudents(BuildContext context,
      {listen = true}) {
    final myId = TeachersProvider.of(context, listen: listen).currentTeacherId;
    final allStudents = StudentsProvider.of(context, listen: false);

    return allStudents
        .mapRemoveNull<Student>(
            (student) => student!.teacherId == myId ? student : null)
        .toList();
  }

  ///
  /// Get all the students who the current teacher is assigned to, meaning
  /// they supervise this student for their internship
  ///
  static List<Student> getSupervizedStudents(BuildContext context,
      {listen = true}) {
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
}
