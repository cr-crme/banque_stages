import 'package:admin_app/providers/school_boards_provider.dart';
import 'package:admin_app/providers/students_provider.dart';
import 'package:admin_app/screens/drawer/main_drawer.dart';
import 'package:admin_app/screens/students/add_student_dialog.dart';
import 'package:admin_app/screens/students/school_students_card.dart';
import 'package:admin_app/widgets/animated_expanding_card.dart';
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
  Future<Map<SchoolBoard, Map<School, Map<String, List<Student>>>>>
  _getStudents(BuildContext context) async {
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
    final schoolBoard = await SchoolBoardsProvider.mySchoolBoardOf(context);
    if (schoolBoard == null || context.mounted == false) return;

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
        child: FutureBuilder(
          future: Future.wait([_getStudents(context)]),
          builder: (context, snapshot) {
            final schoolBoards = snapshot.data?[0];
            if (schoolBoards == null) {
              return const Center(child: CircularProgressIndicator());
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (schoolBoards.isEmpty)
                  const Center(
                    child: Text('Aucune commission scolaire inscrite'),
                  ),
                if (schoolBoards.isNotEmpty)
                  ...schoolBoards.entries.map(
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
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
