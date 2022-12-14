import 'package:enhanced_containers/enhanced_containers.dart';

import '/common/models/teacher.dart';

class TeachersProvider extends FirebaseListProvided<Teacher> {
  TeachersProvider() : super(pathToData: "teachers");

  @override
  Teacher deserializeItem(data) {
    return Teacher.fromSerialized(data);
  }

  String _currentId = "";
  String get currentTeacherId => _currentId;
  set currentTeacherId(String id) {
    _currentId = id;
    notifyListeners();
  }

  Teacher get currentTeacher => this[_currentId];
}
