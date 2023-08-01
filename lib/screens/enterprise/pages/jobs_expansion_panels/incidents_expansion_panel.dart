import 'package:crcrme_banque_stages/common/models/enterprise.dart';
import 'package:crcrme_banque_stages/common/models/incidents.dart';
import 'package:crcrme_banque_stages/common/models/job.dart';
import 'package:crcrme_banque_stages/common/widgets/itemized_text.dart';
import 'package:flutter/material.dart';

class IncidentsExpansionPanel extends ExpansionPanel {
  IncidentsExpansionPanel({
    required super.isExpanded,
    required Enterprise enterprise,
    required Job job,
    required void Function(Job job) addSstEvent,
  }) : super(
          canTapOnHeader: true,
          body: _IncidentsBody(enterprise, job, addSstEvent),
          headerBuilder: (context, isExpanded) => ListTile(
            title: const Text('Accidents et incidents en stage'),
            trailing: Visibility(
              visible: job.incidents.hasMajorIncident,
              child: Tooltip(
                message: 'Il y a au moins eu un incident majeur répertorié'
                    ' pour cette entreprise',
                margin: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width / 4, right: 12),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    Icons.warning_amber,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            ),
          ),
        );
}

class _IncidentsBody extends StatelessWidget {
  const _IncidentsBody(
    this.enterprise,
    this.job,
    this.addSstEvent,
  );

  final Enterprise enterprise;
  final Job job;
  final void Function(Job job) addSstEvent;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Size.infinite.width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIncidents(context,
                title: 'Blessures graves d\'élèves',
                incidents: job.incidents.severeInjuries),
            const SizedBox(height: 16),
            _buildIncidents(context,
                title: 'Cas d\'agression ou de harcèlement',
                incidents: job.incidents.verbalAbuses),
            const SizedBox(height: 16),
            _buildIncidents(context,
                title: 'Blessures mineures d\'élèves',
                incidents: job.incidents.minorInjuries),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: () => addSstEvent(job),
                child: const Text('Signaler un incident'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildIncidents(BuildContext context,
      {required String title, required List<Incident> incidents}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        incidents.isEmpty
            ? const Text('Aucun incident rapporté')
            : ItemizedText(incidents.map((e) => e.toString()).toList()),
      ],
    );
  }
}
