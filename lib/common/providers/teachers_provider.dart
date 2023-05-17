import 'package:enhanced_containers/enhanced_containers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/common/models/teacher.dart';
import 'auth_provider.dart';
import 'internships_provider.dart';
import 'students_provider.dart';

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

  /// Returns if the current teacher can control the internship that has the
  /// id [internshipId].
  Future<bool> canControlInternship(context,
      {bool listen = true, required String internshipId}) async {
    final internship =
        InternshipsProvider.of(context, listen: listen)[internshipId];
    final student = await StudentsProvider.fromLimitedId(context,
        studentId: internship.studentId);

    return student.teacherId == _currentId ||
        internship.teacherId == _currentId;
  }

  void initializeAuth(AuthProvider auth) {
    currentTeacherId = auth.currentUser!.uid;
    initializeFetchingData();
  }
}
