import 'package:crcrme_banque_stages/common/models/internship.dart';
import 'package:crcrme_banque_stages/common/models/visiting_priority.dart';
import 'package:enhanced_containers/enhanced_containers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InternshipsProvider extends FirebaseListProvided<Internship> {
  InternshipsProvider({super.mockMe}) : super(pathToData: 'internships') {
    initializeFetchingData();
  }

  static InternshipsProvider of(BuildContext context, {listen = true}) =>
      Provider.of<InternshipsProvider>(context, listen: listen);

  void replacePriority(
    String studentId,
    VisitingPriority priority,
  ) {
    // TODO async here and await to replace
    // It makes sense to only prioretize the last intership
    replace(byStudentId(studentId).last.copyWith(visitingPriority: priority));
  }

  List<Internship> byStudentId(String studentId) {
    return where((internship) => internship.studentId == studentId).toList();
  }

  @override
  Internship deserializeItem(data) {
    return Internship.fromSerialized(data);
  }
}
