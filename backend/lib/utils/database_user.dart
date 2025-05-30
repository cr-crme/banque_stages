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
      case AccessLevel.user:
        return authenticatorId.isNotEmpty &&
            teacherId != null &&
            teacherId!.isNotEmpty &&
            schoolBoardId != null &&
            schoolBoardId!.isNotEmpty &&
            schoolId != null &&
            schoolId!.isNotEmpty;
    }
  }

  bool get isNotVerified => !isVerified;
  final String? teacherId;
  final String authenticatorId;
  final String? schoolBoardId;
  final String? schoolId;
  final AccessLevel accessLevel;

  DatabaseUser._({
    required this.teacherId,
    required this.authenticatorId,
    required this.schoolBoardId,
    required this.schoolId,
    required this.accessLevel,
  });

  DatabaseUser.empty({
    this.authenticatorId = '',
  })  : teacherId = '',
        schoolBoardId = null,
        schoolId = null,
        accessLevel = AccessLevel.user;

  DatabaseUser copyWith({
    String? teacherId,
    String? authenticatorId,
    String? schoolBoardId,
    String? schoolId,
    AccessLevel? accessLevel,
  }) {
    return DatabaseUser._(
      teacherId: teacherId ?? this.teacherId,
      authenticatorId: authenticatorId ?? this.authenticatorId,
      schoolBoardId: schoolBoardId ?? this.schoolBoardId,
      schoolId: schoolId ?? this.schoolId,
      accessLevel: accessLevel ?? this.accessLevel,
    );
  }
}
