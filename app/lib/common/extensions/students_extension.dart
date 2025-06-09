import 'package:common/models/persons/student.dart';
import 'package:common_flutter/providers/internships_provider.dart';
import 'package:flutter/material.dart';

extension StudentsExtension on Student {
  bool hasActiveInternship(BuildContext context) {
    final internships = InternshipsProvider.of(context, listen: false);
    for (final internship in internships) {
      if (internship.isActive && internship.studentId == id) return true;
    }
    return false;
  }

  Widget get avatar =>
      CircleAvatar(backgroundColor: Color(int.parse(photo)).withAlpha(255));
}
