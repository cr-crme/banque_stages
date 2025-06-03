import 'package:admin_app/providers/auth_provider.dart';
import 'package:admin_app/providers/school_boards_provider.dart';
import 'package:admin_app/providers/students_provider.dart';
import 'package:admin_app/screens/drawer/main_drawer.dart';
import 'package:admin_app/screens/students/add_student_dialog.dart';
import 'package:admin_app/screens/students/school_students_card.dart';
import 'package:admin_app/widgets/animated_expanding_card.dart';
import 'package:admin_app/widgets/select_school_board_dialog.dart';
import 'package:common/models/generic/access_level.dart';
import 'package:common/models/persons/student.dart';
import 'package:common/models/school_boards/school.dart';
import 'package:common/models/school_boards/school_board.dart';
import 'package:flutter/material.dart';

class StudentsListScreen extends StatelessWidget {
  const StudentsListScreen({super.key});

  static const route = '/students_list';

  ///
  /// This complicate structure is basically separating the students by
  /// school and then by class group (associated with a teacher).
  Map<SchoolBoard, Map<School, Map<String, List<Student>>>> _getStudents(
    BuildContext context,
  ) {
    final schoolBoards = SchoolBoardsProvider.of(context);

    final allStudents = [...StudentsProvider.of(context, listen: true)];
    allStudents.sort((a, b) {
      final lastNameA = a.lastName.toLowerCase();
      final lastNameB = b.lastName.toLowerCase();
      var comparison = lastNameA.compareTo(lastNameB);
      if (comparison != 0) return comparison;

      final firstNameA = a.firstName.toLowerCase();
      final firstNameB = b.firstName.toLowerCase();
      comparison = firstNameA.compareTo(firstNameB);
      return comparison;
    });

    // Dispatch students
    final students = <SchoolBoard, Map<School, Map<String, List<Student>>>>{};
    for (final schoolBoard in schoolBoards) {
      final studentsBySchoolsAndGroups = <School, Map<String, List<Student>>>{};
      for (final school in schoolBoard.schools) {
        final studentsInSchool =
            allStudents
                .where((student) => student.schoolId == school.id)
                .toList();
        final studentsByGroups = <String, List<Student>>{};
        for (final student in studentsInSchool) {
          if (!studentsByGroups.containsKey(student.group)) {
            studentsByGroups[student.group] = [];
          }
          studentsByGroups[student.group]!.add(student);
        }
        studentsBySchoolsAndGroups[school] = studentsByGroups;
      }
      students[schoolBoard] = studentsBySchoolsAndGroups;
    }
    return students;
  }

  Future<void> _showAddStudentDialog(BuildContext context) async {
    final authProvider = AuthProvider.of(context, listen: false);
    var schoolBoardId = authProvider.schoolBoardId;
    if (schoolBoardId == null) {
      if (authProvider.databaseAccessLevel == AccessLevel.superAdmin) {
        final answer = await showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) => SelectSchoolBoardDialog(),
        );
        if (answer is! String || !context.mounted) return;
        schoolBoardId = answer;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Aucune commission scolaire associée à votre compte.',
            ),
          ),
        );
        return;
      }
    }

    final schoolBoard = SchoolBoardsProvider.of(
      context,
    ).firstWhereOrNull((e) => e.id == schoolBoardId);
    if (schoolBoard == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Commission scolaire introuvable.')),
      );
      return;
    }

    final answer = await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AddStudentDialog(schoolBoard: schoolBoard),
    );
    if (answer is! Student || !context.mounted) return;

    StudentsProvider.of(context, listen: false).add(answer);
  }

  @override
  Widget build(BuildContext context) {
    final schoolBoardStudents = _getStudents(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des élèves'),
        actions: [
          IconButton(
            onPressed: () => _showAddStudentDialog(context),
            icon: Icon(Icons.add),
          ),
        ],
      ),
      drawer: const MainDrawer(),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _buildTiles(context, schoolBoardStudents),
        ),
      ),
    );
  }

  List<Widget> _buildTiles(
    BuildContext context,
    Map<SchoolBoard, Map<School, Map<String, List<Student>>>>
    schoolBoardStudents,
  ) {
    final authProvider = AuthProvider.of(context, listen: true);

    if (schoolBoardStudents.isEmpty) {
      return [const Center(child: Text('Aucun élève inscrit·e'))];
    }

    return switch (authProvider.databaseAccessLevel) {
      AccessLevel.superAdmin =>
        schoolBoardStudents.entries
            .map(
              (schoolBoardEntry) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: AnimatedExpandingCard(
                  header: Text(
                    schoolBoardEntry.key.name,
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge!.copyWith(color: Colors.black),
                  ),
                  elevation: 0.0,
                  initialExpandedState: true,
                  child: Column(
                    children: [
                      ...schoolBoardEntry.value.entries.map(
                        (schoolEntry) => Column(
                          children: [
                            SchoolStudentsCard(
                              schoolId: schoolEntry.key.id,
                              studentsByGroups: schoolEntry.value,
                              schoolBoard: schoolBoardEntry.key,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
            .toList(),
      AccessLevel.admin || AccessLevel.teacher || null =>
        schoolBoardStudents.values.firstOrNull?.entries
                .map(
                  (schoolEntry) => Column(
                    children: [
                      SchoolStudentsCard(
                        schoolId: schoolEntry.key.id,
                        studentsByGroups: schoolEntry.value,
                        schoolBoard:
                            schoolBoardStudents.keys.firstOrNull ??
                            SchoolBoard.empty,
                      ),
                    ],
                  ),
                )
                .toList() ??
            [],
    };
  }
}
