import 'package:admin_app/screens/students/student_list_tile.dart';
import 'package:common/models/persons/student.dart';
import 'package:common/models/school_boards/school_board.dart';
import 'package:common/utils.dart' as utils;
import 'package:flutter/material.dart';

class SchoolStudentsCard extends StatelessWidget {
  const SchoolStudentsCard({
    super.key,
    required this.schoolId,
    required this.students,
    required this.schoolBoard,
  });

  final String schoolId;
  final List<Student> students;
  final SchoolBoard schoolBoard;

  @override
  Widget build(BuildContext context) {
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
        if (students.isEmpty) Center(child: Text('Aucun élève inscrit·e')),
        if (students.isNotEmpty)
          ...students.map(
            (Student student) => StudentListTile(
              key: ValueKey(student.id),
              student: student,
              schoolBoard: schoolBoard,
            ),
          ),
      ],
    );
  }
}
