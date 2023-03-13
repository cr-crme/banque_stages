import 'package:enhanced_containers/enhanced_containers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/common/models/student.dart';
import '/common/models/visiting_priority.dart';

class StudentsProvider extends FirebaseListProvided<Student> {
  StudentsProvider()
      : super(
          pathToData: 'students',
          pathToAvailableDataIds: '',
        );

  static StudentsProvider of(BuildContext context, {listen = true}) {
    return Provider.of<StudentsProvider>(context, listen: listen);
  }

  void replacePriority(
    Student student,
    VisitingPriority priority,
  ) {
    replace(this[student].copyWith(visitingPriority: priority));
  }

  @override
  Student deserializeItem(data) {
    return Student.fromSerialized(data);
  }
}
