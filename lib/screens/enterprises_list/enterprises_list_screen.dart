import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '/common/models/enterprise.dart';
import '/common/providers/enterprises_provider.dart';
import '/common/widgets/main_drawer.dart';
import '/common/widgets/search_bar.dart';
import '/router.dart';
import '/screens/visiting_students/models/waypoints.dart';
import '/screens/visiting_students/widgets/routing_map.dart';
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
    final appBar = AppBar(
      title: const Text('Entreprises'),
      actions: [
        if (_tabController.index == 0)
          IconButton(
            onPressed: _search,
            icon: const Icon(Icons.search),
          ),
        IconButton(
          onPressed: () => GoRouter.of(context).goNamed(Screens.addEnterprise),
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
    );
    return Scaffold(
      appBar: appBar,
      drawer: const MainDrawer(),
      body: TabBarView(
        controller: _tabController,
        children: [
          _EnterprisesByList(withSearchBar: _withSearchBar),
          const _EnterprisesByMap(),
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

class _EnterprisesByMap extends StatelessWidget {
  const _EnterprisesByMap();

  List<Marker> _latlngToMarkers(Map<Enterprise, Waypoint> enterprises) {
    List<Marker> out = [];

    const double markerSize = 40;
    for (final enterprise in enterprises.keys) {
      double nameWidth = 160;
      double nameHeight = 100;
      final waypoint = enterprises[enterprise]!;

      out.add(
        Marker(
          point: waypoint.toLatLng(),
          anchorPos: AnchorPos.exactly(
              Anchor(markerSize / 2 + nameWidth, nameHeight / 2)),
          width: markerSize + nameWidth, //markerSize + 1,
          height: markerSize + nameHeight, //markerSize + 1,
          builder: (context) => Row(
            children: [
              GestureDetector(
                onTap: () => GoRouter.of(context).goNamed(
                  Screens.enterprise,
                  params: Screens.withId(enterprise),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(75),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_on_sharp,
                    size: markerSize,
                    color: Colors.green,
                  ),
                ),
              ),
              if (waypoint.showTitle)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                      color: Colors.green.withAlpha(125),
                      shape: BoxShape.rectangle),
                  child: Text(waypoint.title),
                )
            ],
          ),
        ),
      );
    }
    return out;
  }

  Future<Map<Enterprise, Waypoint>> _fetchEnterprisesCoordinates(
      BuildContext context) async {
    final enterprises = EnterprisesProvider.of(context, listen: false);
    final Map<Enterprise, Waypoint> out = {};
    for (final enterprise in enterprises) {
      out[enterprise] = await Waypoint.fromAddress(
          enterprise.name, enterprise.address.toString());
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const ScrollPhysics(),
      child: FutureBuilder<Map<Enterprise, Waypoint>>(
          future: _fetchEnterprisesCoordinates(context),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            Map<Enterprise, Waypoint> locations = snapshot.data!;
            return SizedBox(
              height: MediaQuery.of(context).size.height - 150,
              child: FlutterMap(
                options: MapOptions(
                    center: locations[locations.keys.first]!.toLatLng(),
                    zoom: 14),
                nonRotatedChildren: const [ZoomButtons()],
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'dev.fleaflet.flutter_map.example',
                  ),
                  MarkerLayer(markers: _latlngToMarkers(locations)),
                ],
              ),
            );
          }),
    );
  }
}
