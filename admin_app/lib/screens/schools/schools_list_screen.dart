import 'package:admin_app/providers/school_boards_provider.dart';
import 'package:admin_app/screens/drawer/main_drawer.dart';
import 'package:admin_app/screens/schools/add_school_dialog.dart';
import 'package:admin_app/screens/schools/school_list_tile.dart';
import 'package:collection/collection.dart';
import 'package:common/models/school_boards/school.dart';
import 'package:flutter/material.dart';

class SchoolsListScreen extends StatelessWidget {
  const SchoolsListScreen({super.key});

  static const route = '/schools_list';

  Future<void> _showAddSchoolDialog(BuildContext context) async {
    final schoolBoard = await SchoolBoardsProvider.mySchoolBoardOf(context);
    if (schoolBoard == null || context.mounted == false) return;

    final answer = await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AddSchoolDialog(schoolBoard: schoolBoard),
    );
    if (answer is! School || !context.mounted) return;

    schoolBoard.schools.add(answer);
    SchoolBoardsProvider.of(context, listen: false).replace(schoolBoard);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des écoles'),
        actions: [
          IconButton(
            onPressed: () => _showAddSchoolDialog(context),
            icon: Icon(Icons.add),
          ),
        ],
      ),
      drawer: const MainDrawer(),

      body: SingleChildScrollView(
        child: FutureBuilder(
          future: SchoolBoardsProvider.mySchoolBoardOf(context, listen: true),
          builder: (context, snapshot) {
            final schoolBoard = snapshot.data;
            if (schoolBoard == null) {
              return const Center(child: CircularProgressIndicator());
            }
            final schools = schoolBoard.schools.sorted((a, b) {
              final nameA = a.name.toLowerCase();
              final nameB = b.name.toLowerCase();
              return nameA.compareTo(nameB);
            });

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
                if (schools.isEmpty)
                  const Center(child: Text('Aucune école inscrite')),
                if (schools.isNotEmpty)
                  ...schools.map(
                    (school) => SchoolListTile(
                      school: school,
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
