import 'package:admin_app/providers/enterprises_provider.dart';
import 'package:admin_app/screens/drawer/main_drawer.dart';
import 'package:admin_app/screens/enterprises/add_enterprise_dialog.dart';
import 'package:admin_app/screens/enterprises/enterprise_list_tile.dart';
import 'package:common/models/enterprises/enterprise.dart';
import 'package:flutter/material.dart';

class EnterprisesListScreen extends StatelessWidget {
  const EnterprisesListScreen({super.key});

  static const route = '/enterprises_list';

  Future<List<Enterprise>> _getEnterprises(BuildContext context) async {
    final enterprises = [...EnterprisesProvider.of(context, listen: true)];
    enterprises.sort((a, b) {
      final nameA = a.name.toLowerCase();
      final nameB = b.name.toLowerCase();
      return nameA.compareTo(nameB);
    });
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
            final enterprises = snapshot.data?[0];
            if (enterprises == null) {
              return const Center(child: CircularProgressIndicator());
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (enterprises.isEmpty)
                  const Center(child: Text('Aucune entreprise inscrite')),
                if (enterprises.isNotEmpty)
                  ...enterprises.map(
                    (enterprise) => EnterpriseListTile(
                      key: ValueKey(enterprise.id),
                      enterprise: enterprise,
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
