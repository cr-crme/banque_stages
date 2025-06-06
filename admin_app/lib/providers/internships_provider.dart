import 'package:admin_app/providers/backend_list_provided.dart';
import 'package:common/communication_protocol.dart';
import 'package:common/models/internships/internship.dart';
import 'package:common/models/itineraries/visiting_priority.dart';
import 'package:common_flutter/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InternshipsProvider extends BackendListProvided<Internship> {
  InternshipsProvider({required super.uri, super.mockMe});

  static InternshipsProvider of(BuildContext context, {listen = true}) =>
      Provider.of<InternshipsProvider>(context, listen: listen);

  void replacePriority(String studentId, VisitingPriority priority) {
    replace(byStudentId(studentId).last.copyWith(visitingPriority: priority));
  }

  void updateTeacherNote(String studentId, String notes) {
    replace(byStudentId(studentId).last.copyWith(teacherNotes: notes));
  }

  List<Internship> byStudentId(String studentId) {
    return where((internship) => internship.studentId == studentId).toList();
  }

  @override
  Internship deserializeItem(data) {
    return Internship.fromSerialized(data);
  }

  void initializeAuth(AuthProvider auth) {
    initializeFetchingData(authProvider: auth);
    auth.addListener(() => initializeFetchingData(authProvider: auth));
  }

  @override
  RequestFields getField([bool asList = false]) =>
      asList ? RequestFields.internships : RequestFields.internship;
}
