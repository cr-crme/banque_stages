import 'package:admin_app/providers/school_boards_provider.dart';
import 'package:admin_app/providers/students_provider.dart';
import 'package:admin_app/screens/drawer/main_drawer.dart';
import 'package:admin_app/screens/students/add_student_dialog.dart';
import 'package:admin_app/screens/students/school_students_card.dart';
import 'package:common/models/persons/student.dart';
import 'package:common/models/school_boards/school_board.dart';
import 'package:flutter/material.dart';

class StudentsListScreen extends StatelessWidget {
  const StudentsListScreen({super.key});

  static const route = '/students_list';

  Future<Map<String, List<Student>>> getStudents(BuildContext context) async {
    final studentsTp = StudentsProvider.of(context, listen: true);
    final schoolBoard = await SchoolBoardsProvider.mySchoolBoardOf(context);
    final schools = schoolBoard?.schools ?? [];

    // Sort by school name
    final students = <String, List<Student>>{}; // Students by school
    for (final school in schools) {
      final schoolStudents =
          studentsTp.where((student) => student.schoolId == school.id).toList();

      // Do the secondary sort by first name before the primary sort
      schoolStudents.sort((a, b) {
        final firstNameA = a.firstName.toLowerCase();
        final firstNameB = b.firstName.toLowerCase();
        return firstNameA.compareTo(firstNameB);
      });

      // Sort by last name then first name
      schoolStudents.sort((a, b) {
        final lastNameA = a.lastName.toLowerCase();
        final lastNameB = b.lastName.toLowerCase();
        return lastNameA.compareTo(lastNameB);
      });

      students[school.id] = schoolStudents;
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
          future: Future.wait([
            SchoolBoardsProvider.mySchoolBoardOf(context),
            getStudents(context),
          ]),
          builder: (context, snapshot) {
            final schoolBoard = snapshot.data?[0] as SchoolBoard?;
            final schoolStudents =
                snapshot.data?[1] as Map<String, List<Student>>?;
            if (schoolBoard == null || schoolStudents == null) {
              return const Center(child: CircularProgressIndicator());
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    schoolBoard.name,
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge!.copyWith(color: Colors.black),
                  ),
                ),
                ...schoolStudents.keys.map(
                  (String schoolId) => SchoolStudentsCard(
                    schoolId: schoolId,
                    students: schoolStudents[schoolId] ?? [],
                    schoolBoard: schoolBoard,
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
