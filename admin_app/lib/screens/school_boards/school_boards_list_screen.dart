import 'package:admin_app/providers/school_boards_provider.dart';
import 'package:admin_app/screens/drawer/main_drawer.dart';
import 'package:admin_app/screens/school_boards/add_school_board_dialog.dart';
import 'package:admin_app/screens/school_boards/school_board_list_tile.dart';
import 'package:common/models/school_boards/school_board.dart';
import 'package:flutter/material.dart';

class SchoolBoardsListScreen extends StatelessWidget {
  const SchoolBoardsListScreen({super.key});

  static const route = '/schoolboards_list';

  Future<List<SchoolBoard>> _getSchoolBoards(BuildContext context) async {
    final schoolBoards = [...SchoolBoardsProvider.of(context, listen: true)];
    schoolBoards.sort((a, b) {
      final nameA = a.name.toLowerCase();
      final nameB = b.name.toLowerCase();
      return nameA.compareTo(nameB);
    });
    return schoolBoards;
  }

  Future<void> _showAddSchoolBoardDialog(BuildContext context) async {
    final answer = await showDialog(
      barrierDismissible: false,
      context: context,
      builder:
          (context) => AddSchoolBoardDialog(schoolBoard: SchoolBoard.empty),
    );
    if (answer is! SchoolBoard || !context.mounted) return;

    SchoolBoardsProvider.of(context, listen: false).add(answer);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des commissions scolaires'),
        actions: [
          IconButton(
            onPressed: () => _showAddSchoolBoardDialog(context),
            icon: Icon(Icons.add),
          ),
        ],
      ),
      drawer: const MainDrawer(),

      body: SingleChildScrollView(
        child: FutureBuilder(
          future: Future.wait([_getSchoolBoards(context)]),
          builder: (context, snapshot) {
            final schoolBoards = snapshot.data?[0];
            if (schoolBoards == null) {
              return const Center(child: CircularProgressIndicator());
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Liste des commissions scolaires',
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge!.copyWith(color: Colors.black),
                  ),
                ),
                if (schoolBoards.isEmpty)
                  const Center(
                    child: Text('Aucune commission scolaire inscrite'),
                  ),
                if (schoolBoards.isNotEmpty)
                  ...schoolBoards.map(
                    (schoolBoard) =>
                        SchoolBoardListTile(schoolBoard: schoolBoard),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
