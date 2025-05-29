import 'package:common/models/generic/access_level.dart';

class DatabaseUser {
  final bool isVerified;
  bool get isNotVerified => !isVerified;
  final String databaseId;
  final String authenticatorId;
  final String schoolBoardId;
  final AccessLevel accessLevel;

  DatabaseUser.verified({
    required this.databaseId,
    required this.authenticatorId,
    required this.schoolBoardId,
    required this.accessLevel,
  }) : isVerified = true;

  DatabaseUser.unverified()
      : isVerified = false,
        databaseId = '',
        authenticatorId = '',
        schoolBoardId = '',
        accessLevel = AccessLevel.user;
}
