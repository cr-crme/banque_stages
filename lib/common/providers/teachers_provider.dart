import 'package:crcrme_banque_stages/common/models/teacher.dart';
import 'package:enhanced_containers/enhanced_containers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth_provider.dart';

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

  Teacher get currentTeacher => isEmpty
      ? Teacher(
          firstName: 'Error',
          lastName: 'Error',
          email: 'error@error.error',
          schoolId: '-1',
          groups: [])
      : this[_currentId];

  void initializeAuth(AuthProvider auth) {
    currentTeacherId = auth.currentUser?.uid ?? (kDebugMode ? 'default' : '');
    initializeFetchingData();
  }
}
