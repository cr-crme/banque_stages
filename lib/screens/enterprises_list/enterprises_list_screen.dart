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

class _EnterprisesListScreenState extends State<EnterprisesListScreen>
    with SingleTickerProviderStateMixin {
  bool _withSearchBar = false;
  late final _tabController =
      TabController(initialIndex: 0, length: 2, vsync: this)
        ..addListener(() => setState(() {}));

  void _search() => setState(() => _withSearchBar = !_withSearchBar);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Entreprises'),
        actions: [
          if (_tabController.index == 0)
            IconButton(
              onPressed: _search,
              icon: const Icon(Icons.search),
            ),
          IconButton(
            onPressed: () =>
                GoRouter.of(context).goNamed(Screens.addEnterprise),
            tooltip: 'Ajouter une entreprise',
            icon: const Icon(Icons.add),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
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
      body: TabBarView(
        controller: _tabController,
        children: [
          _EnterprisesByList(withSearchBar: _withSearchBar),
          _EnterprisesByList(withSearchBar: _withSearchBar),
        ],
      ),
    );
  }
}

class _EnterprisesByList extends StatefulWidget {
  const _EnterprisesByList({required this.withSearchBar});

  final bool withSearchBar;

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
      // Remove if should not be shown by filter availability filter
      if (_hideNotAvailable &&
          !enterprise.jobs
              .any((job) => job.positionsOccupied < job.positionsOffered)) {
        return false;
      }

      // Perform the searchbar filter
      if (enterprise.name
          .toLowerCase()
          .contains(_searchController.text.toLowerCase())) {
        return true;
      }
      if (enterprise.jobs.any((job) {
        final hasSpecialization = job.specialization?.name
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()) ??
            false;
        final hasSector = job.activitySector?.name
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()) ??
            false;
        return hasSpecialization || hasSector;
      })) {
        return true;
      }
      if (enterprise.activityTypes.any((type) =>
          type.toLowerCase().contains(_searchController.text.toLowerCase()))) {
        return true;
      }
      if (enterprise.address
          .toString()
          .toLowerCase()
          .contains(_searchController.text.toLowerCase())) {
        return true;
      }
      return false;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.withSearchBar) SearchBar(controller: _searchController),
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
