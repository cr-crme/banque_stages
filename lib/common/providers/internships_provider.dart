import 'package:enhanced_containers/enhanced_containers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/common/models/internship.dart';
import '/common/models/student.dart';
import '/common/models/visiting_priority.dart';

class InternshipsProvider extends FirebaseListProvided<Internship> {
  InternshipsProvider() : super(pathToData: "internships") {
    initializeFetchingData();
  }

  static InternshipsProvider of(BuildContext context, {listen = true}) =>
      Provider.of<InternshipsProvider>(context, listen: listen);

  void replacePriority(
    Student student,
    VisitingPriority priority,
  ) {
    // It makes senst to only prioretize the last intership
    replace(byStudent(student).last.copyWith(visitingPriority: priority));
  }

  List<Internship> byStudent(Student student) {
    return where((intership) => intership.studentId == student.id).toList();
  }

  @override
  Internship deserializeItem(data) {
    return Internship.fromSerialized(data);
  }
}
