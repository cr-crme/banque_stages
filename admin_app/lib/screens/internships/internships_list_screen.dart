import 'package:admin_app/providers/internships_provider.dart';
import 'package:admin_app/screens/drawer/main_drawer.dart';
import 'package:admin_app/screens/internships/add_internship_dialog.dart';
import 'package:admin_app/screens/internships/internship_list_tile.dart';
import 'package:common/models/internships/internship.dart';
import 'package:flutter/material.dart';

class InternshipsListScreen extends StatelessWidget {
  const InternshipsListScreen({super.key});

  static const route = '/internships_list';

  Future<List<Internship>> _getInternships(BuildContext context) async {
    // TODO Sort by school, enterprise, teacher, student
    final internships = [...InternshipsProvider.of(context, listen: true)];
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

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (internships.isEmpty)
                  const Center(child: Text('Aucune stage enregistré.')),
                if (internships.isNotEmpty)
                  ...internships.map(
                    (internship) => InternshipListTile(internship: internship),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
