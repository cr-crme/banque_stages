import 'package:collection/collection.dart';
import 'package:common/services/job_data_file_service.dart';
import 'package:common_flutter/providers/enterprises_provider.dart';
import 'package:crcrme_banque_stages/common/extensions/enterprise_extension.dart';
import 'package:crcrme_banque_stages/common/widgets/search.dart';
import 'package:crcrme_banque_stages/screens/ref_sst/incident_history/models/incidents_by_enterprise.dart';
import 'package:crcrme_banque_stages/screens/ref_sst/incident_history/widgets/incident_list_tile.dart';
import 'package:flutter/material.dart';

enum _FilterType {
  bySpecialization,
  byNumberOfIncident,
}

class IncidentHistoryScreen extends StatefulWidget {
  const IncidentHistoryScreen({super.key});

  static const route = '/accident-history-screen';

  @override
  State<IncidentHistoryScreen> createState() => _IncidentHistoryScreenState();
}

class _IncidentHistoryScreenState extends State<IncidentHistoryScreen> {
  final _searchController = TextEditingController();
  bool _showSearchBar = false;
  var _currentFilter = _FilterType.byNumberOfIncident;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    super.dispose();
    _searchController.dispose();
  }

  Map<Specialization, IncidentsByEnterprise> _fetchAllIncidents(context) {
    final enterprises = [...EnterprisesProvider.of(context)]..sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
    final textToSearch = _searchController.text.toLowerCase().trim();

    Map<Specialization, IncidentsByEnterprise> out = {};
    for (final enterprise in enterprises) {
      for (final job in enterprise.availablejobs(context)) {
        // Do not add if there is no incident
        if (job.incidents.isEmpty) continue;

        // If a search filter is added
        if (_showSearchBar && textToSearch != '') {
          if (!job.specialization.idWithName
              .toLowerCase()
              .contains(textToSearch)) {
            continue;
          }
        }

        if (!out.containsKey(job.specialization)) {
          out[job.specialization] = IncidentsByEnterprise();
        }
        out[job.specialization]!
            .add(enterprise, job.incidents.all.map((e) => e.incident).toList());
      }
    }

    return out;
  }

  List<Specialization> _filterBySpecialization(
      Map<Specialization, IncidentsByEnterprise> incidents) {
    return incidents.keys.sorted((a, b) => a.name.compareTo(b.name)).toList();
  }

  List<Specialization> _filterByNumberOfIncident(
      Map<Specialization, IncidentsByEnterprise> incidents) {
    return incidents.keys
        .sorted((a, b) => incidents[b]!.length - incidents[a]!.length);
  }

  @override
  Widget build(BuildContext context) {
    final incidents = _fetchAllIncidents(context);

    late List<Specialization> sortedSpecializationId;
    switch (_currentFilter) {
      case _FilterType.bySpecialization:
        sortedSpecializationId = _filterBySpecialization(incidents);
        break;
      case _FilterType.byNumberOfIncident:
        sortedSpecializationId = _filterByNumberOfIncident(incidents);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique d\'accidents'),
        leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back)),
        actions: [
          IconButton(
            onPressed: () => setState(() => _showSearchBar = !_showSearchBar),
            icon: const Icon(Icons.search),
          )
        ],
        bottom: _showSearchBar ? Search(controller: _searchController) : null,
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _FilterTile(
                  title: 'Nom métier',
                  onTap: () => setState(
                      () => _currentFilter = _FilterType.bySpecialization),
                  isSelected: _currentFilter == _FilterType.bySpecialization,
                ),
              ),
              Expanded(
                child: _FilterTile(
                  title: 'Nombre accidents',
                  onTap: () => setState(
                      () => _currentFilter = _FilterType.byNumberOfIncident),
                  isSelected: _currentFilter == _FilterType.byNumberOfIncident,
                ),
              ),
            ],
          ),
          if (incidents.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 12.0, left: 36, right: 36),
                child: Text(
                  'Aucun incident ou blessure d\'élève n\'a été rapporté '
                  'par le personnel enseignant',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
          if (incidents.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: incidents.length,
                itemBuilder: (context, index) {
                  final specialization = sortedSpecializationId[index];
                  return IncidentListTile(
                      specializationId: specialization.id,
                      incidents: incidents[specialization]!);
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _FilterTile extends StatelessWidget {
  const _FilterTile({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final bool isSelected;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        color:
            isSelected ? Theme.of(context).primaryColor.withAlpha(150) : null,
        child: Row(
          children: [
            const SizedBox(height: 48, width: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.swap_vert,
              color: Colors.black,
            ),
          ],
        ),
      ),
    );
  }
}
