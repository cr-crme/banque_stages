import 'package:common/models/generic/access_level.dart';

class DatabaseUser {
  bool get isVerified =>
      databaseId.isNotEmpty &&
      authenticatorId.isNotEmpty &&
      ((schoolBoardId?.isNotEmpty ?? false) ||
          accessLevel >= AccessLevel.superAdmin);
  bool get isNotVerified => !isVerified;
  final String databaseId;
  final String authenticatorId;
  final String? schoolBoardId;
  final AccessLevel accessLevel;

  DatabaseUser._({
    required this.databaseId,
    required this.authenticatorId,
    required this.schoolBoardId,
    required this.accessLevel,
  });

  DatabaseUser.empty({
    this.authenticatorId = '',
  })  : databaseId = '',
        schoolBoardId = null,
        accessLevel = AccessLevel.user;

  DatabaseUser copyWith({
    String? databaseId,
    String? authenticatorId,
    String? schoolBoardId,
    AccessLevel? accessLevel,
  }) {
    return DatabaseUser._(
      databaseId: databaseId ?? this.databaseId,
      authenticatorId: authenticatorId ?? this.authenticatorId,
      schoolBoardId: schoolBoardId ?? this.schoolBoardId,
      accessLevel: accessLevel ?? this.accessLevel,
    );
  }
}
