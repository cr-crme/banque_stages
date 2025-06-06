import 'package:collection/collection.dart';
import 'package:common/communication_protocol.dart';
import 'package:common/models/school_boards/school.dart';
import 'package:common/models/school_boards/school_board.dart';
import 'package:common_flutter/providers/auth_provider.dart';
import 'package:crcrme_banque_stages/common/providers/backend_list_provided.dart';
import 'package:crcrme_banque_stages/common/providers/teachers_provider.dart';
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

  static Future<SchoolBoard?> mySchoolBoardOf(BuildContext context,
      {listen = false}) async {
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

  static Future<School?> mySchoolOf(BuildContext context,
      {listen = false}) async {
    final teacher = TeachersProvider.of(context, listen: false).currentTeacher;
    final schoolBoards =
        await SchoolBoardsProvider.mySchoolBoardOf(context, listen: listen);
    if (schoolBoards == null) return null;

    return schoolBoards.schools
        .firstWhereOrNull((school) => school.id == teacher.schoolId);
  }

  void initializeAuth(AuthProvider auth) {
    initializeFetchingData(authProvider: auth);
  }
}
