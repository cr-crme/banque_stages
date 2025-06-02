import 'package:admin_app/providers/enterprises_provider.dart';
import 'package:admin_app/providers/school_boards_provider.dart';
import 'package:admin_app/screens/drawer/main_drawer.dart';
import 'package:admin_app/screens/enterprises/add_enterprise_dialog.dart';
import 'package:admin_app/screens/enterprises/enterprise_list_tile.dart';
import 'package:admin_app/widgets/animated_expanding_card.dart';
import 'package:common/models/enterprises/enterprise.dart';
import 'package:common/models/school_boards/school_board.dart';
import 'package:flutter/material.dart';

class EnterprisesListScreen extends StatelessWidget {
  const EnterprisesListScreen({super.key});

  static const route = '/enterprises_list';

  Future<Map<SchoolBoard, List<Enterprise>>> _getEnterprises(
    BuildContext context,
  ) async {
    final schoolBoards = SchoolBoardsProvider.of(context, listen: true);

    final allEnterprises = [...EnterprisesProvider.of(context, listen: true)];
    allEnterprises.sort((a, b) {
      final nameA = a.name.toLowerCase();
      final nameB = b.name.toLowerCase();
      return nameA.compareTo(nameB);
    });

    final enterprises = <SchoolBoard, List<Enterprise>>{};
    for (final schoolBoard in schoolBoards) {
      enterprises[schoolBoard] =
          allEnterprises
              .where((enterprise) => enterprise.schoolBoardId == schoolBoard.id)
              .toList();
    }
    return enterprises;
  }

  Future<void> _showAddEnterpriseDialog(BuildContext context) async {
    final answer = await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AddEnterpriseDialog(),
    );
    if (answer is! Enterprise || !context.mounted) return;

    EnterprisesProvider.of(context, listen: false).replace(answer);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Liste des entreprises'),
        actions: [
          IconButton(
            onPressed: () => _showAddEnterpriseDialog(context),
            icon: Icon(Icons.add),
          ),
        ],
      ),
      drawer: const MainDrawer(),

      body: SingleChildScrollView(
        child: FutureBuilder(
          future: Future.wait([_getEnterprises(context)]),
          builder: (context, snapshot) {
            final schoolBoards = snapshot.data?[0];
            if (schoolBoards == null) {
              return const Center(child: CircularProgressIndicator());
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (schoolBoards.isEmpty)
                  const Center(child: Text('Aucune entreprise inscrite')),
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
                            ...schoolBoardEntry.value.map(
                              (enterprise) => EnterpriseListTile(
                                key: ValueKey(enterprise.id),
                                enterprise: enterprise,
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
