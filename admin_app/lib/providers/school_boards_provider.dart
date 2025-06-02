import 'package:admin_app/providers/auth_provider.dart';
import 'package:admin_app/providers/backend_list_provided.dart';
import 'package:admin_app/providers/teachers_provider.dart';
import 'package:common/communication_protocol.dart';
import 'package:common/models/school_boards/school_board.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class SchoolBoardsProvider extends BackendListProvided<SchoolBoard> {
  SchoolBoardsProvider({required super.uri, super.mockMe});

  static SchoolBoardsProvider of(BuildContext context, {listen = false}) =>
      Provider.of<SchoolBoardsProvider>(context, listen: listen);

  @override
  SchoolBoard deserializeItem(data) {
    return SchoolBoard.fromSerialized(data);
  }

  @override
  RequestFields getField([bool asList = false]) =>
      asList ? RequestFields.schoolBoards : RequestFields.schoolBoard;

  // TODO Manage the different access level cases (super admin, admin, user)
  // With super admin who does not have a school board id, admin who has a school board id but no school id,
  // and user who has a school board id and a school id
  static Future<SchoolBoard?> mySchoolBoardOf(
    BuildContext context, {
    listen = false,
  }) async {
    while (true) {
      if (!context.mounted) return null;
      final schoolBoards = SchoolBoardsProvider.of(context, listen: listen);
      final teacher =
          TeachersProvider.of(context, listen: false).currentTeacher;
      final schoolBoard = schoolBoards.fromIdOrNull(teacher.schoolBoardId);
      if (schoolBoard != null) return schoolBoard;
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  void initializeAuth(AuthProvider auth) {
    initializeFetchingData(authProvider: auth);
    auth.addListener(() => initializeFetchingData(authProvider: auth));
  }
}
