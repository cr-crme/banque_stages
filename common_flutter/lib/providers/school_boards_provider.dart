import 'package:common/communication_protocol.dart';
import 'package:common/models/school_boards/school.dart';
import 'package:common/models/school_boards/school_board.dart';
import 'package:common/utils.dart';
import 'package:common_flutter/providers/auth_provider.dart';
import 'package:common_flutter/providers/backend_list_provided.dart';
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

  SchoolBoard? get mySchoolBoard {
    final schoolBoardId = _authProvider?.schoolBoardId;
    if (schoolBoardId == null) return null;

    final schoolBoard = fromIdOrNull(schoolBoardId);
    if (schoolBoard == null) return null;

    return schoolBoard;
  }

  School? get mySchool {
    final schoolBoard = mySchoolBoard;
    if (schoolBoard == null) return null;

    final schoolId = _authProvider?.schoolId;
    if (schoolId == null) return null;

    return schoolBoard.schools.firstWhereOrNull(
      (school) => school.id == schoolId,
    );
  }

  AuthProvider? _authProvider;
  void initializeAuth(AuthProvider auth) {
    _authProvider = auth;
    initializeFetchingData(authProvider: auth);
    auth.addListener(() => initializeFetchingData(authProvider: auth));
  }
}
