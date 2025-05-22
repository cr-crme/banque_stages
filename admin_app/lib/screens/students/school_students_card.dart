import 'package:admin_app/providers/teachers_provider.dart';
import 'package:admin_app/screens/students/student_list_tile.dart';
import 'package:common/models/persons/student.dart';
import 'package:common/models/school_boards/school_board.dart';
import 'package:common/utils.dart' as utils;
import 'package:flutter/material.dart';

class SchoolStudentsCard extends StatelessWidget {
  const SchoolStudentsCard({
    super.key,
    required this.schoolId,
    required this.studentsByGroups,
    required this.schoolBoard,
  });

  final String schoolId;
  final Map<String, List<Student>> studentsByGroups;
  final SchoolBoard schoolBoard;

  @override
  Widget build(BuildContext context) {
    final teachers = TeachersProvider.of(context, listen: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 12.0, top: 8, bottom: 8),
          child: Text(
            utils.IterableExtensions(
                  schoolBoard.schools,
                ).firstWhereOrNull((school) => school.id == schoolId)?.name ??
                'École introuvable',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        if (studentsByGroups.isEmpty)
          Center(child: Text('Aucun élève inscrit·e à cette école')),
        if (studentsByGroups.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 12.0),
            child: Column(
              children: [
                ...studentsByGroups.keys.map((group) {
                  final teacherForGroup = teachers
                      .where((teacher) => teacher.groups.contains(group))
                      .map((teacher) => teacher.fullName);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Groupe : $group - ${teacherForGroup.isNotEmpty ? teacherForGroup.join(', ') : 'Aucun enseignant·e'}',
                        ),
                        if (studentsByGroups[group]!.isEmpty)
                          Center(
                            child: Text('Aucun élève inscrit·e dans ce groupe'),
                          ),
                        if (studentsByGroups[group]!.isNotEmpty)
                          ...studentsByGroups[group]!.map(
                            (student) => StudentListTile(
                              key: ValueKey(student.id),
                              student: student,
                              schoolBoard: schoolBoard,
                            ),
                          ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
      ],
    );
  }
}
