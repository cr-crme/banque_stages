import 'package:admin_app/providers/internships_provider.dart';
import 'package:admin_app/providers/school_boards_provider.dart';
import 'package:admin_app/providers/teachers_provider.dart';
import 'package:admin_app/screens/drawer/main_drawer.dart';
import 'package:admin_app/screens/internships/add_internship_dialog.dart';
import 'package:admin_app/screens/internships/internship_list_tile.dart';
import 'package:admin_app/widgets/animated_expanding_card.dart';
import 'package:collection/collection.dart';
import 'package:common/models/internships/internship.dart';
import 'package:common/models/persons/teacher.dart';
import 'package:common/models/school_boards/school.dart';
import 'package:flutter/material.dart';

class InternshipsListScreen extends StatelessWidget {
  const InternshipsListScreen({super.key});

  static const route = '/internships_list';

  Future<Map<bool, Map<School, Map<Teacher, List<Internship>>>>>
  _getInternships(BuildContext context) async {
    final schoolBoards = SchoolBoardsProvider.of(context, listen: true);
    final schools = schoolBoards.firstOrNull?.schools;
    final teachers = TeachersProvider.of(context, listen: true);

    final internshipsTp = [...InternshipsProvider.of(context, listen: true)];
    internshipsTp.sort((a, b) {
      final nameA = a.studentId.toLowerCase();
      final nameB = b.studentId.toLowerCase();
      return nameA.compareTo(nameB);
    });

    final internships = <bool, Map<School, Map<Teacher, List<Internship>>>>{};
    for (final internship in internshipsTp) {
      final teacher = teachers.firstWhereOrNull(
        (teacher) => teacher.id == internship.signatoryTeacherId,
      );
      if (teacher == null) continue;

      final school = schools?.firstWhereOrNull(
        (school) => school.id == teacher.schoolId,
      );
      if (school == null) continue;

      if (!internships.containsKey(internship.isActive)) {
        internships[internship.isActive] = {};
      }
      if (!internships[internship.isActive]!.containsKey(school)) {
        internships[internship.isActive]![school] = {};
      }
      if (!internships[internship.isActive]![school]!.containsKey(teacher)) {
        internships[internship.isActive]![school]![teacher] = [];
      }
      internships[internship.isActive]![school]![teacher]!.add(internship);
    }

    return internships;
  }

  Future<void> _showAddInternshipDialog(BuildContext context) async {
    final answer = await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AddInternshipDialog(),
    );
    if (answer is! Internship || !context.mounted) return;

    InternshipsProvider.of(context, listen: false).replace(answer);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des stages'),
        actions: [
          IconButton(
            onPressed: () => _showAddInternshipDialog(context),
            icon: Icon(Icons.add),
          ),
        ],
      ),
      drawer: const MainDrawer(),

      body: SingleChildScrollView(
        child: FutureBuilder(
          future: Future.wait([_getInternships(context)]),
          builder: (context, snapshot) {
            final internships = snapshot.data?[0];
            if (internships == null) {
              return const Center(child: CircularProgressIndicator());
            }

            Map<School, Map<Teacher, Map<bool, dynamic>>>;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  internships.isEmpty
                      ? [const Center(child: Text('Aucun stage enregistré.'))]
                      : [
                        _InternshipsByActive(
                          key: const ValueKey('active_internships'),
                          areActive: true,
                          internships: internships[true] ?? {},
                        ),
                        _InternshipsByActive(
                          key: const ValueKey('closed_internships'),
                          areActive: false,
                          internships: internships[false] ?? {},
                        ),
                      ],
            );
          },
        ),
      ),
    );
  }
}

class _InternshipsByActive extends StatelessWidget {
  const _InternshipsByActive({
    super.key,
    required this.areActive,
    required this.internships,
  });

  final Map<School, Map<Teacher, List<Internship>>> internships;
  final bool areActive;

  @override
  Widget build(BuildContext context) {
    return AnimatedExpandingCard(
      header: Padding(
        padding: const EdgeInsets.only(left: 12.0, top: 12, bottom: 8.0),
        child: Text(
          areActive ? 'Stages actifs' : 'Stages terminés',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
      initialExpandedState: true,
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: _InternshipsBySchools(internships: internships),
      ),
    );
  }
}

class _InternshipsBySchools extends StatelessWidget {
  const _InternshipsBySchools({required this.internships});

  final Map<School, Map<Teacher, List<Internship>>> internships;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          internships.entries.map((entry) {
            final school = entry.key;
            final teachers = entry.value;

            return AnimatedExpandingCard(
              key: ValueKey(school.id),
              header: Text(
                school.name,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              initialExpandedState: true,
              elevation: 0,
              child: _InternshipsByTeachers(teachers: teachers),
            );
          }).toList(),
    );
  }
}

class _InternshipsByTeachers extends StatelessWidget {
  const _InternshipsByTeachers({required this.teachers});

  final Map<Teacher, List<Internship>> teachers;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...teachers.entries.map((entry) {
          final teacher = entry.key;
          final internshipsList = entry.value;

          return Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: AnimatedExpandingCard(
              key: ValueKey(teacher.id),
              header: Text(
                teacher.fullName,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              elevation: 0,
              initialExpandedState: true,
              child: Column(
                children: [
                  ...internshipsList.map((internship) {
                    return InternshipListTile(
                      key: ValueKey(internship.id),
                      internship: internship,
                    );
                  }),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}
