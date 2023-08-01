import 'package:crcrme_banque_stages/common/widgets/itemized_text.dart';
import 'package:crcrme_banque_stages/misc/job_data_file_service.dart';
import 'package:crcrme_banque_stages/screens/ref_sst/incident_history/models/incidents_by_enterprise.dart';
import 'package:flutter/material.dart';

class IncidentListTile extends StatelessWidget {
  const IncidentListTile({
    super.key,
    required this.specializationId,
    required this.incidents,
  });

  final String specializationId;
  final IncidentsByEnterprise incidents;

  @override
  Widget build(BuildContext context) {
    final specialization =
        ActivitySectorsService.specialization(specializationId);

    return Card(
      elevation: 10,
      child: ExpansionTile(
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(
            specialization.name,
            style: Theme.of(context)
                .textTheme
                .titleMedium!
                .copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        trailing: Tooltip(
          message: 'Nombre d\'accidents pour ce métier',
          child: Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: const [
                    BoxShadow(
                      spreadRadius: 1,
                      blurRadius: 5,
                      color: Colors.grey,
                    )
                  ],
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(100)),
              child: Center(
                child: Text(
                  '${incidents.length}',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              )),
        ),
        expandedAlignment: Alignment.topLeft,
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        childrenPadding: const EdgeInsets.only(left: 24),
        children: incidents.enterprises
            .map((enterprise) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(enterprise.name),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: ItemizedText(
                        incidents.description(enterprise)!,
                        interline: 8,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ))
            .toList(),
      ),
    );
  }
}
