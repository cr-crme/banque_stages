import 'package:admin_app/providers/auth_provider.dart';
import 'package:admin_app/providers/school_boards_provider.dart';
import 'package:admin_app/screens/drawer/main_drawer.dart';
import 'package:admin_app/screens/school_boards/add_school_board_dialog.dart';
import 'package:admin_app/screens/school_boards/school_board_list_tile.dart';
import 'package:admin_app/screens/school_boards/school_list_tile.dart';
import 'package:common/models/generic/access_level.dart';
import 'package:common/models/school_boards/school_board.dart';
import 'package:flutter/material.dart';

class SchoolBoardsListScreen extends StatelessWidget {
  const SchoolBoardsListScreen({super.key});

  static const route = '/schoolboards_list';

  List<SchoolBoard> _getSchoolBoards(BuildContext context) {
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
    final authProvider = AuthProvider.of(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          authProvider.databaseAccessLevel == AccessLevel.superAdmin
              ? 'Liste des commissions scolaires'
              : 'Liste des écoles',
        ),
        actions: [
          IconButton(
            onPressed: () => _showAddSchoolBoardDialog(context),
            icon: Icon(Icons.add),
          ),
        ],
      ),
      drawer: const MainDrawer(),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: _buildTiles(authProvider, _getSchoolBoards(context)),
        ),
      ),
    );
  }

  List<Widget> _buildTiles(
    AuthProvider authProvider,
    List<SchoolBoard> schoolBoards,
  ) {
    if (schoolBoards.isEmpty) {
      return [const Center(child: Text('Aucune commission scolaire inscrite'))];
    }

    return switch (authProvider.databaseAccessLevel) {
      AccessLevel.superAdmin =>
        schoolBoards
            .map((schoolBoard) => SchoolBoardListTile(schoolBoard: schoolBoard))
            .toList(),
      AccessLevel.admin || AccessLevel.teacher || null =>
        schoolBoards.firstOrNull?.schools
                .map(
                  (school) => SchoolListTile(
                    school: school,
                    schoolBoard: schoolBoards.firstOrNull ?? SchoolBoard.empty,
                  ),
                )
                .toList() ??
            [],
    };
  }
}
