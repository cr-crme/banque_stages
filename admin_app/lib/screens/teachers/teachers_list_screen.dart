import 'package:admin_app/providers/auth_provider.dart';
import 'package:admin_app/providers/school_boards_provider.dart';
import 'package:admin_app/providers/teachers_provider.dart';
import 'package:admin_app/screens/drawer/main_drawer.dart';
import 'package:admin_app/screens/teachers/add_teacher_dialog.dart';
import 'package:admin_app/screens/teachers/school_teachers_card.dart';
import 'package:admin_app/widgets/animated_expanding_card.dart';
import 'package:common/models/persons/teacher.dart';
import 'package:common/models/school_boards/school.dart';
import 'package:common/models/school_boards/school_board.dart';
import 'package:flutter/material.dart';

class TeachersListScreen extends StatelessWidget {
  const TeachersListScreen({super.key});

  static const route = '/teachers_list';

  Future<Map<SchoolBoard, Map<School, List<Teacher>>>> _getTeachers(
    BuildContext context,
  ) async {
    final teachersProvider = TeachersProvider.of(context, listen: true);
    final schoolBoards = SchoolBoardsProvider.of(context);

    // Sort by school name
    final teachers = <SchoolBoard, Map<School, List<Teacher>>>{};
    for (final schoolBoard in schoolBoards) {
      final teachersBySchool = <School, List<Teacher>>{};

      for (final school in schoolBoard.schools) {
        final schoolTeachers =
            teachersProvider
                .where((teacher) => teacher.schoolId == school.id)
                .toList();

        schoolTeachers.sort((a, b) {
          final lastNameA = a.lastName.toLowerCase();
          final lastNameB = b.lastName.toLowerCase();
          var comparison = lastNameA.compareTo(lastNameB);
          if (comparison != 0) return comparison;

          final firstNameA = a.firstName.toLowerCase();
          final firstNameB = b.firstName.toLowerCase();
          return firstNameA.compareTo(firstNameB);
        });
        teachersBySchool[school] = schoolTeachers;
      }

      teachers[schoolBoard] = teachersBySchool;
    }

    return teachers;
  }

  Future<void> _showAddTeacherDialog(BuildContext context) async {
    final schoolBoardId = AuthProvider.of(context, listen: false).schoolBoardId;
    if (schoolBoardId == null || schoolBoardId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aucune commission scolaire associée à votre compte.'),
        ),
      );
      return;
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
          future: Future.wait([_getTeachers(context)]),
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
                              (schoolEntry) => SchoolTeachersCard(
                                schoolId: schoolEntry.key.id,
                                teachers: schoolEntry.value,
                                schoolBoard: schoolBoardEntry.key,
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
