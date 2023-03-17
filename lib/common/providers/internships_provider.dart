import 'package:enhanced_containers/enhanced_containers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/common/models/internship.dart';
import '/common/models/visiting_priority.dart';

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

  List<Internship> byStudentId(String studentId) {
    return where((intership) => intership.studentId == studentId).toList();
  }

  @override
  Internship deserializeItem(data) {
    return Internship.fromSerialized(data);
  }
}
