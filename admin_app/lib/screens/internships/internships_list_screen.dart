import 'package:admin_app/providers/internships_provider.dart';
import 'package:admin_app/screens/drawer/main_drawer.dart';
import 'package:admin_app/screens/internships/add_internship_dialog.dart';
import 'package:admin_app/screens/internships/internship_list_tile.dart';
import 'package:common/models/internships/internship.dart';
import 'package:flutter/material.dart';

class InternshipsListScreen extends StatelessWidget {
  const InternshipsListScreen({super.key});

  static const route = '/internships_list';

  Future<List<Internship>> _getInternships(
    InternshipsProvider internshipsProvider, {
    required bool active,
  }) async {
    // TODO Sort by school, enterprise, teacher, student
    final internships =
        internshipsProvider
            .where(
              (internship) =>
                  active ? internship.isActive : !internship.isActive,
            )
            .toList();

    internships.sort((a, b) {
      final nameA = a.studentId.toLowerCase();
      final nameB = b.studentId.toLowerCase();
      return nameA.compareTo(nameB);
    });
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
    final internshipsProvider = InternshipsProvider.of(context, listen: true);

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
          future: Future.wait([
            _getInternships(internshipsProvider, active: true),
            _getInternships(internshipsProvider, active: false),
          ]),
          builder: (context, snapshot) {
            final activeInternships = snapshot.data?[0];
            final inactiveInternships = snapshot.data?[1];
            if (activeInternships == null || inactiveInternships == null) {
              return const Center(child: CircularProgressIndicator());
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (activeInternships.isEmpty && inactiveInternships.isEmpty)
                  const Center(child: Text('Aucune stage enregistré.')),
                if (activeInternships.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Stages actifs (${activeInternships.length})',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                if (activeInternships.isNotEmpty)
                  ...activeInternships.map(
                    (internship) => InternshipListTile(
                      key: ValueKey(internship.id),
                      internship: internship,
                    ),
                  ),

                if (inactiveInternships.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Stages inactifs (${inactiveInternships.length})',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                if (inactiveInternships.isNotEmpty)
                  ...inactiveInternships.map(
                    (internship) => InternshipListTile(
                      key: ValueKey(internship.id),
                      internship: internship,
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
