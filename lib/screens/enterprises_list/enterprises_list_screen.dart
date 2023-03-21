import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '/common/models/enterprise.dart';
import '/common/providers/enterprises_provider.dart';
import '/common/widgets/main_drawer.dart';
import '/common/widgets/search_bar.dart';
import '/router.dart';
import 'widgets/enterprise_card.dart';

class EnterprisesListScreen extends StatelessWidget {
  const EnterprisesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
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
          bottom: TabBar(
            tabs: [
              Tab(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                    Icon(Icons.list),
                    SizedBox(width: 8),
                    Text('Vue liste')
                  ])),
              Tab(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                    Icon(Icons.map),
                    SizedBox(width: 8),
                    Text('Vue carte')
                  ])),
            ],
          ),
        ),
        drawer: const MainDrawer(),
        body: const TabBarView(children: [
          _EnterprisesByList(),
          _EnterprisesByList(),
        ]),
      ),
    );
  }
}

class _EnterprisesByList extends StatefulWidget {
  const _EnterprisesByList();

  @override
  State<_EnterprisesByList> createState() => _EnterprisesByListState();
}

class _EnterprisesByListState extends State<_EnterprisesByList> {
  bool _hideNotAvailable = false;
  late final _searchController = TextEditingController()
    ..addListener(() => setState(() {}));

  List<Enterprise> _sortEnterprisesByName(List<Enterprise> enterprises) {
    final res = List<Enterprise>.from(enterprises);
    res.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    return res.toList();
  }

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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SearchBar(controller: _searchController),
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
    );
  }
}
