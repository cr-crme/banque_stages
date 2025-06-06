import 'package:admin_app/providers/school_boards_provider.dart';
import 'package:admin_app/providers/teachers_provider.dart';
import 'package:admin_app/screens/drawer/main_drawer.dart';
import 'package:admin_app/screens/teachers/add_teacher_dialog.dart';
import 'package:admin_app/screens/teachers/school_teachers_card.dart';
import 'package:common/models/persons/teacher.dart';
import 'package:common/models/school_boards/school_board.dart';
import 'package:flutter/material.dart';

class TeachersListScreen extends StatelessWidget {
  const TeachersListScreen({super.key});

  static const route = '/teachers_list';

  Future<Map<String, List<Teacher>>> getTeachers(BuildContext context) async {
    final teachersTp = TeachersProvider.of(context, listen: true);
    final schoolBoard = await SchoolBoardsProvider.mySchoolBoardOf(context);
    final schools = schoolBoard?.schools ?? [];

    // Sort by school name
    final teachers = <String, List<Teacher>>{}; // Teachers by school
    for (final school in schools) {
      final schoolTeachers =
          teachersTp.where((teacher) => teacher.schoolId == school.id).toList();

      schoolTeachers.sort((a, b) {
        final lastNameA = a.lastName.toLowerCase();
        final lastNameB = b.lastName.toLowerCase();
        var comparison = lastNameA.compareTo(lastNameB);
        if (comparison != 0) return comparison;

        final firstNameA = a.firstName.toLowerCase();
        final firstNameB = b.firstName.toLowerCase();
        return firstNameA.compareTo(firstNameB);
      });
      teachers[school.id] = schoolTeachers;
    }

    return teachers;
  }

  Future<void> _showAddTeacherDialog(BuildContext context) async {
    final schoolBoard = await SchoolBoardsProvider.mySchoolBoardOf(context);
    if (schoolBoard == null || context.mounted == false) return;

    final answer = await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AddTeacherDialog(schoolBoard: schoolBoard),
    );
    if (answer is! Teacher || !context.mounted) return;

    TeachersProvider.of(context, listen: false).add(answer);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des enseignant·e·s'),
        actions: [
          IconButton(
            onPressed: () => _showAddTeacherDialog(context),
            icon: Icon(Icons.add),
          ),
        ],
      ),
      drawer: const MainDrawer(),

      body: SingleChildScrollView(
        child: FutureBuilder(
          future: Future.wait([
            SchoolBoardsProvider.mySchoolBoardOf(context),
            getTeachers(context),
          ]),
          builder: (context, snapshot) {
            final schoolBoard = snapshot.data?[0] as SchoolBoard?;
            final schoolTeachers =
                snapshot.data?[1] as Map<String, List<Teacher>>?;
            if (schoolBoard == null || schoolTeachers == null) {
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
                ...schoolTeachers.keys.map(
                  (String schoolId) => SchoolTeachersCard(
                    schoolId: schoolId,
                    teachers: schoolTeachers[schoolId] ?? [],
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
