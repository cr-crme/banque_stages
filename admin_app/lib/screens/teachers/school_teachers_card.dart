import 'package:admin_app/providers/school_boards_provider.dart';
import 'package:admin_app/screens/teachers/teacher_list_tile.dart';
import 'package:common/models/persons/teacher.dart';
import 'package:common/utils.dart' as utils;
import 'package:flutter/material.dart';

class SchoolTeachersCard extends StatelessWidget {
  const SchoolTeachersCard({
    super.key,
    required this.schoolId,
    required this.teachers,
  });

  final String schoolId;
  final List<Teacher> teachers;

  @override
  Widget build(BuildContext context) {
    final schoolBoards = SchoolBoardsProvider.of(context, listen: true);
    if (schoolBoards.length > 1) {
      // TODO: Support multiple school boards
      throw Exception('More than on school boards is not supported yet.');
    }
    final schools = schoolBoards.firstOrNull?.schools ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12.0, top: 8, bottom: 8),
          child: Text(
            schools.firstWhereOrNull((school) => school.id == schoolId)?.name ??
                'École introuvable',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        if (teachers.isEmpty)
          Center(child: Text('Aucun enseignant·e inscrit·e')),
        if (teachers.isNotEmpty)
          ...teachers.map(
            (Teacher teacher) =>
                TeacherListTile(key: ValueKey(teacher.id), teacher: teacher),
          ),
      ],
    );
  }
}
