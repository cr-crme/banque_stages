import 'package:enhanced_containers/enhanced_containers.dart';

import '/common/models/student.dart';

class StudentsProvider extends FirebaseListProvided<Student> {
  StudentsProvider()
      : super(
          pathToData: "students",
          pathToAvailableDataIds: "void",
        );

  @override
  Student deserializeItem(data) {
    return Student.fromSerialized(data);
  }
}
