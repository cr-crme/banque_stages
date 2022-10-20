import 'package:crcrme_banque_stages/crcrme_enhanced_containers/lib/firebase_list_provided.dart';

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
