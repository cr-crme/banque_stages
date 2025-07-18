import 'package:admin_app/screens/teachers/teacher_list_tile.dart';
import 'package:common/models/generic/access_level.dart';
import 'package:common/models/persons/teacher.dart';
import 'package:common/models/school_boards/school_board.dart';
import 'package:common/utils.dart' as utils;
import 'package:common_flutter/providers/auth_provider.dart';
import 'package:flutter/material.dart';

class SchoolTeachersCard extends StatelessWidget {
  const SchoolTeachersCard({
    super.key,
    required this.schoolId,
    required this.teachers,
    required this.schoolBoard,
  });

  final String schoolId;
  final List<Teacher> teachers;
  final SchoolBoard schoolBoard;

  @override
  Widget build(BuildContext context) {
    final authProvider = AuthProvider.of(context, listen: true);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12.0, top: 8, bottom: 8),
          child: Text(
            schoolBoard.schools
                    .firstWhereOrNull((school) => school.id == schoolId)
                    ?.name ??
                'École introuvable',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        if (teachers.isEmpty)
          Center(child: Text('Aucun enseignant·e inscrit·e')),
        if (teachers.isNotEmpty)
          ...teachers.map((Teacher teacher) {
            final canEdit =
                authProvider.databaseAccessLevel >= AccessLevel.admin ||
                (authProvider.databaseAccessLevel == AccessLevel.teacher &&
                    authProvider.teacherId == teacher.id);
            final canDelete =
                authProvider.databaseAccessLevel >= AccessLevel.admin;

            return TeacherListTile(
              key: ValueKey(teacher.id),
              teacher: teacher,
              schoolBoard: schoolBoard,
              canEdit: canEdit,
              canDelete: canDelete,
            );
          }),
      ],
    );
  }
}
