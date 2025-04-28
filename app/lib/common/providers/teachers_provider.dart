import 'package:common/communication_protocol.dart';
import 'package:common/models/persons/teacher.dart';
import 'package:crcrme_banque_stages/common/providers/auth_provider.dart';
import 'package:crcrme_banque_stages/common/providers/backend_list_provided.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class TeachersProvider extends BackendListProvided<Teacher> {
  TeachersProvider({required super.uri, super.mockMe});

  static TeachersProvider of(BuildContext context, {listen = false}) =>
      Provider.of<TeachersProvider>(context, listen: listen);

  @override
  RequestFields getField([bool asList = false]) =>
      asList ? RequestFields.teachers : RequestFields.teacher;

  @override
  Teacher deserializeItem(data) {
    return Teacher.fromSerialized(data);
  }

  String? _currentId;
  String get currentTeacherId {
    if (_currentId == null) throw Exception('Teacher is not logged in');

    return _currentId!;
  }

  set currentTeacherId(String? id) {
    var uuid = Uuid();
    final namespace = UuidValue.fromNamespace(Namespace.dns);
    _currentId = uuid.v5(namespace.toString(), id!);
    notifyListeners();
  }

  Teacher get currentTeacher =>
      isEmpty || _currentId == null || !hasId(_currentId!)
          ? Teacher.empty
          : this[_currentId];

  void initializeAuth(AuthProvider auth) {
    currentTeacherId = auth.currentUser?.uid;

    initializeFetchingData(authProvider: auth);
  }
}
