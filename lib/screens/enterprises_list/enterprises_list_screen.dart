import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '/common/models/enterprise.dart';
import '/common/providers/enterprises_provider.dart';
import '/common/widgets/main_drawer.dart';
import '/common/widgets/search_bar.dart';
import '/router.dart';
import 'widgets/enterprise_card.dart';

class EnterprisesListScreen extends StatefulWidget {
  const EnterprisesListScreen({super.key});

  @override
  State<EnterprisesListScreen> createState() => _EnterprisesListScreenState();
}

class _EnterprisesListScreenState extends State<EnterprisesListScreen> {
  bool _hideNotAvailable = false;

  final _searchController = TextEditingController();

  List<Enterprise> _filterSelectedEnterprises(List<Enterprise> enterprises) {
    return enterprises.where((enterprise) {
      if (_hideNotAvailable &&
          !enterprise.jobs
              .any((job) => job.positionsOccupied < job.positionsOffered)) {
      } else if (enterprise.name
          .toLowerCase()
          .contains(_searchController.text.toLowerCase())) {
        return true;
      } else if (enterprise.jobs.any((job) =>
          job.specialization?.name
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()) ??
          false)) {
        return true;
      } else if (enterprise.activityTypes.any((type) =>
          type.toLowerCase().contains(_searchController.text.toLowerCase()))) {
        return true;
      }
      return false;
    }).toList();
  }

  List<Enterprise> _sortEnterprisesByName(List<Enterprise> enterprises) {
    final res = List<Enterprise>.from(enterprises);
    res.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return res.toList();
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Entreprises'),
        actions: [
          IconButton(
            onPressed: () =>
                GoRouter.of(context).goNamed(Screens.addEnterprise),
            tooltip: 'Ajouter une entreprise',
            icon: const Icon(Icons.add),
          ),
        ],
        bottom: SearchBar(controller: _searchController),
      ),
      drawer: const MainDrawer(),
      body: Column(
        children: [
          SwitchListTile(
            title: const Text('Afficher que les stages disponibles'),
            value: _hideNotAvailable,
            onChanged: (value) => setState(() => _hideNotAvailable = value),
          ),
          Selector<EnterprisesProvider, List<Enterprise>>(
            builder: (context, enterprises, child) => Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: enterprises.length,
                itemBuilder: (context, index) => EnterpriseCard(
                  enterprise: enterprises.elementAt(index),
                  onTap: (enterprise) => GoRouter.of(context).goNamed(
                    Screens.enterprise,
                    params: Screens.withId(enterprise),
                  ),
                ),
              ),
            ),
            selector: (context, enterprises) => _sortEnterprisesByName(
              _filterSelectedEnterprises(enterprises.toList()),
            ),
          ),
        ],
      ),
    );
  }
}
