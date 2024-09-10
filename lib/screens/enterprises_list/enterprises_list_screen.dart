import 'package:crcrme_banque_stages/common/models/enterprise.dart';
import 'package:crcrme_banque_stages/common/models/job_list.dart';
import 'package:crcrme_banque_stages/common/models/person.dart';
import 'package:crcrme_banque_stages/common/models/waypoints.dart';
import 'package:crcrme_banque_stages/common/providers/enterprises_provider.dart';
import 'package:crcrme_banque_stages/common/providers/schools_provider.dart';
import 'package:crcrme_banque_stages/common/providers/teachers_provider.dart';
import 'package:crcrme_banque_stages/common/widgets/main_drawer.dart';
import 'package:crcrme_banque_stages/common/widgets/search.dart';
import 'package:crcrme_banque_stages/router.dart';
import 'package:crcrme_banque_stages/screens/visiting_students/widgets/zoom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'widgets/enterprise_card.dart';

class EnterpriseController {
  EnterpriseController();
  List<Enterprise> selectedEnterprises = [];
}

class EnterprisesListScreen extends StatefulWidget {
  const EnterprisesListScreen({super.key});

  @override
  State<EnterprisesListScreen> createState() => _EnterprisesListScreenState();
}

class _EnterprisesListScreenState extends State<EnterprisesListScreen>
    with SingleTickerProviderStateMixin {
  final _enterpriseKey = GlobalKey<_EnterprisesByListState>();
  bool _withSearchBar = false;
  final _enterpriseController = EnterpriseController();

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
          onPressed: () {
            _withSearchBar = false;
            _enterpriseKey.currentState!.searchController.text = '';
            GoRouter.of(context).goNamed(Screens.addEnterprise);
          },
          tooltip: 'Ajouter une entreprise',
          icon: const Icon(Icons.add),
        ),
      ],
      bottom: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.list),
                SizedBox(width: 8),
                Text('Vue liste')
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.map),
                SizedBox(width: 8),
                Text('Vue carte')
              ],
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      appBar: appBar,
      drawer: const MainDrawer(),
      body: TabBarView(
        controller: _tabController,
        children: [
          _EnterprisesByList(
            key: _enterpriseKey,
            withSearchBar: _withSearchBar,
            enterpriseController: _enterpriseController,
          ),
          _EnterprisesByMap(enterpriseController: _enterpriseController),
        ],
      ),
    );
  }
}

class _EnterprisesByList extends StatefulWidget {
  const _EnterprisesByList({
    super.key,
    required this.withSearchBar,
    required this.enterpriseController,
  });

  final bool withSearchBar;
  final EnterpriseController enterpriseController;

  @override
  State<_EnterprisesByList> createState() => _EnterprisesByListState();
}

class _EnterprisesByListState extends State<_EnterprisesByList> {
  bool _hideNotAvailable = false;
  late final searchController = TextEditingController()
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
          !enterprise.jobs.any(
              (job) => job.positionsOccupied(context) < job.positionsOffered)) {
        return false;
      }

      final textToSearch = searchController.text.toLowerCase().trim();

      // Perform the searchbar filter
      if (enterprise.name.toLowerCase().contains(textToSearch)) {
        return true;
      }
      if (enterprise.jobs.any((job) {
        final hasSpecialization =
            job.specialization.name.toLowerCase().contains(textToSearch);
        final hasSector =
            job.specialization.sector.name.toLowerCase().contains(textToSearch);
        return hasSpecialization || hasSector;
      })) {
        return true;
      }
      if (enterprise.activityTypes
          .any((type) => type.toLowerCase().contains(textToSearch))) {
        return true;
      }
      if (enterprise.address.toString().toLowerCase().contains(textToSearch)) {
        return true;
      }
      return false;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.withSearchBar)
          Container(
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              child: Search(controller: searchController)),
        SwitchListTile(
          title: const Text('N\'afficher que les stages disponibles'),
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
                  pathParameters: Screens.params(enterprise),
                  queryParameters: Screens.queryParams(pageIndex: '0'),
                ),
              ),
            ),
          ),
          selector: (context, enterprises) {
            widget.enterpriseController.selectedEnterprises =
                _filterSelectedEnterprises(enterprises.toList());
            return _sortEnterprisesByName(
                widget.enterpriseController.selectedEnterprises);
          },
        ),
      ],
    );
  }
}

class _EnterprisesByMap extends StatelessWidget {
  const _EnterprisesByMap({required this.enterpriseController});

  final EnterpriseController enterpriseController;

  List<Marker> _latlngToMarkers(
      context, Map<Enterprise, Waypoint> enterprises) {
    List<Marker> out = [];

    const double markerSize = 40;
    for (final i in enterprises.keys.toList().asMap().keys) {
      // i == 0 is the school
      final enterprise = enterprises.keys.toList()[i];

      double nameWidth = 160;
      double nameHeight = 100;
      final waypoint = enterprises[enterprise]!;
      final color = i == 0
          ? Colors.purple
          : enterprise.availableJobs(context).isNotEmpty
              ? Colors.green
              : Colors.red;

      out.add(
        Marker(
          point: waypoint.toLatLng(),
          alignment: const Alignment(0.8, 0.0), // Centered almost at max right
          width: markerSize + nameWidth,
          height: markerSize + nameHeight,
          child: Row(
            children: [
              GestureDetector(
                onTap: i == 0
                    ? null
                    : () => GoRouter.of(context).goNamed(
                          Screens.enterprise,
                          pathParameters: Screens.params(enterprise),
                          queryParameters: Screens.queryParams(pageIndex: '0'),
                        ),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(75),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    i == 0 ? Icons.school : Icons.location_on_sharp,
                    size: markerSize,
                    color: color,
                  ),
                ),
              ),
              if (waypoint.showTitle)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                      color: color.withAlpha(125), shape: BoxShape.rectangle),
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
    final enterprises = enterpriseController.selectedEnterprises;
    final Map<Enterprise, Waypoint> out = {};

    final teacher = TeachersProvider.of(context, listen: false).currentTeacher;
    final school =
        SchoolsProvider.of(context, listen: false).fromId(teacher.schoolId);

    final schoolAsEnterprise = Enterprise(
      name: school.name,
      activityTypes: {},
      recrutedBy: '',
      shareWith: '',
      jobs: JobList(),
      contact: Person.empty,
      address: school.address,
    );
    out[schoolAsEnterprise] = await Waypoint.fromAddress(
        title: school.name, address: school.address.toString());

    for (final enterprise in enterprises) {
      out[enterprise] = await Waypoint.fromAddress(
          title: enterprise.name, address: enterprise.address.toString());
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
              return SizedBox(
                height: MediaQuery.of(context).size.height,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            Map<Enterprise, Waypoint> locations = snapshot.data!;
            return SizedBox(
              height: MediaQuery.of(context).size.height - 150,
              child: FlutterMap(
                options: MapOptions(
                    initialCenter: locations[locations.keys.first]!.toLatLng(),
                    initialZoom: 14),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'dev.fleaflet.flutter_map.example',
                  ),
                  MarkerLayer(markers: _latlngToMarkers(context, locations)),
                  const ZoomButtons(),
                ],
              ),
            );
          }),
    );
  }
}
