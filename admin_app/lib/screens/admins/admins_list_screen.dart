import 'package:admin_app/providers/admins_provider.dart';
import 'package:admin_app/providers/school_boards_provider.dart';
import 'package:admin_app/screens/admins/add_admin_dialog.dart';
import 'package:admin_app/screens/admins/admin_list_tile.dart';
import 'package:admin_app/screens/drawer/main_drawer.dart';
import 'package:admin_app/widgets/animated_expanding_card.dart';
import 'package:common/models/persons/admin.dart';
import 'package:common/models/school_boards/school_board.dart';
import 'package:flutter/material.dart';

class AdminsListScreen extends StatelessWidget {
  const AdminsListScreen({super.key});

  static const route = '/admins_list';

  Future<Map<SchoolBoard?, List<Admin>>> _getAdmins(
    BuildContext context,
  ) async {
    final allAdmins = [...AdminsProvider.of(context, listen: true)];
    allAdmins.sort((a, b) {
      final lastNameA = a.lastName.toLowerCase();
      final lastNameB = b.lastName.toLowerCase();
      var comparison = lastNameA.compareTo(lastNameB);
      if (comparison != 0) return comparison;

      final firstNameA = a.firstName.toLowerCase();
      final firstNameB = b.firstName.toLowerCase();
      return firstNameA.compareTo(firstNameB);
    });

    final schoolBoards = SchoolBoardsProvider.of(context);

    final admins = <SchoolBoard?, List<Admin>>{};
    for (final schoolBoard in schoolBoards) {
      admins[schoolBoard] =
          allAdmins
              .where((admin) => admin.schoolBoardId == schoolBoard.id)
              .toList();
    }
    admins[null] =
        allAdmins.where((admin) => admin.schoolBoardId == '').toList();

    return admins;
  }

  Future<void> _showAddAdminDialog(BuildContext context) async {
    final answer = await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AddAdminDialog(),
    );
    if (answer is! Admin || !context.mounted) return;

    AdminsProvider.of(context, listen: false).add(answer);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des administrateurs·trices'),
        actions: [
          IconButton(
            onPressed: () => _showAddAdminDialog(context),
            icon: Icon(Icons.add),
          ),
        ],
      ),
      drawer: const MainDrawer(),

      body: SingleChildScrollView(
        child: FutureBuilder(
          future: Future.wait([_getAdmins(context)]),
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
                          schoolBoardEntry.key?.name ??
                              'Super administrateurs·trices',
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge!.copyWith(color: Colors.black),
                        ),
                        elevation: 0.0,
                        initialExpandedState: true,
                        child: Column(
                          children: [
                            ...schoolBoardEntry.value.map(
                              (adminEntry) => AdminListTile(admin: adminEntry),
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
