import 'package:common/models/generic/access_level.dart';

class DatabaseUser {
  bool get isVerified {
    if (authenticatorId.isEmpty) return false;
    switch (accessLevel) {
      case AccessLevel.superAdmin:
        return authenticatorId.isNotEmpty;
      case AccessLevel.admin:
        return authenticatorId.isNotEmpty &&
            schoolBoardId != null &&
            schoolBoardId!.isNotEmpty;
      case AccessLevel.teacher:
        return authenticatorId.isNotEmpty &&
            userId != null &&
            userId!.isNotEmpty &&
            schoolBoardId != null &&
            schoolBoardId!.isNotEmpty &&
            schoolId != null &&
            schoolId!.isNotEmpty;
    }
  }

  bool get isNotVerified => !isVerified;
  final String? userId;
  final String authenticatorId;
  final String? schoolBoardId;
  final String? schoolId;
  final AccessLevel accessLevel;

  DatabaseUser._({
    required this.userId,
    required this.authenticatorId,
    required this.schoolBoardId,
    required this.schoolId,
    required this.accessLevel,
  });

  DatabaseUser.empty({
    this.authenticatorId = '',
  })  : userId = '',
        schoolBoardId = null,
        schoolId = null,
        accessLevel = AccessLevel.teacher;

  DatabaseUser copyWith({
    String? userId,
    String? authenticatorId,
    String? schoolBoardId,
    String? schoolId,
    AccessLevel? accessLevel,
  }) {
    return DatabaseUser._(
      userId: userId ?? this.userId,
      authenticatorId: authenticatorId ?? this.authenticatorId,
      schoolBoardId: schoolBoardId ?? this.schoolBoardId,
      schoolId: schoolId ?? this.schoolId,
      accessLevel: accessLevel ?? this.accessLevel,
    );
  }
}
