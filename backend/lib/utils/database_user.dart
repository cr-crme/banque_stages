import 'package:common/models/generic/access_level.dart';

class DatabaseUser {
  bool get isVerified {
    if (_authenticatorId.isEmpty) return false;
    switch (accessLevel) {
      case AccessLevel.superAdmin:
        return _authenticatorId.isNotEmpty;
      case AccessLevel.admin:
        return _authenticatorId.isNotEmpty &&
            schoolBoardId != null &&
            schoolBoardId!.isNotEmpty;
      case AccessLevel.teacher:
        return _authenticatorId.isNotEmpty &&
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
  final String _authenticatorId;
  final String? schoolBoardId;
  final String? schoolId;
  final bool shouldChangePassword;
  final AccessLevel accessLevel;

  DatabaseUser._({
    required this.userId,
    required String authenticatorId,
    required this.schoolBoardId,
    required this.schoolId,
    required this.shouldChangePassword,
    required this.accessLevel,
  }) : _authenticatorId = authenticatorId;

  DatabaseUser.empty({
    String authenticatorId = '',
  })  : _authenticatorId = authenticatorId,
        userId = '',
        schoolBoardId = null,
        schoolId = null,
        shouldChangePassword = false,
        accessLevel = AccessLevel.teacher;

  DatabaseUser copyWith({
    String? userId,
    String? schoolBoardId,
    String? schoolId,
    bool? shouldChangePassword,
    AccessLevel? accessLevel,
  }) {
    return DatabaseUser._(
      userId: userId ?? this.userId,
      authenticatorId: _authenticatorId,
      schoolBoardId: schoolBoardId ?? this.schoolBoardId,
      schoolId: schoolId ?? this.schoolId,
      shouldChangePassword: shouldChangePassword ?? this.shouldChangePassword,
      accessLevel: accessLevel ?? this.accessLevel,
    );
  }

  Map<String, dynamic> serialize() {
    return {
      'user_id': userId,
      'school_board_id': schoolBoardId,
      'school_id': schoolId,
      'should_change_password': shouldChangePassword,
      'access_level': accessLevel.serialize(),
    };
  }
}
