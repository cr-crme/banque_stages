import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import 'package:crcrme_banque_stages/common/models/enterprise.dart';
import 'package:crcrme_banque_stages/common/widgets/disponibility_circle.dart';

class EnterpriseCard extends StatelessWidget {
  const EnterpriseCard({
    super.key,
    required this.enterprise,
    required this.onTap,
  });

  final Enterprise enterprise;
  final void Function(Enterprise enterprise) onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      child: ListTile(
        onTap: () => onTap(enterprise),
        title: Text(
          enterprise.name,
          style: Theme.of(context)
              .textTheme
              .titleMedium!
              .copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Visibility(
              visible: enterprise.address != null ||
                  enterprise.headquartersAddress != null,
              child: Text(
                enterprise.address != null
                    ? enterprise.address.toString()
                    : enterprise.headquartersAddress.toString(),
                style: TextStyle(color: Colors.grey[800]),
              ),
            ),
            ...enterprise.jobs
                .map((job) => Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(children: [
                      DisponibilityCircle(
                          positionsOffered: job.positionsOffered,
                          positionsOccupied: job.positionsOccupied(context)),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          job.specialization.idWithName,
                          style: TextStyle(color: Colors.grey[800]),
                        ),
                      ),
                    ])))
                .toList(),
          ],
        ),
        trailing: Visibility(
          visible: enterprise.jobs
                  .lastWhereOrNull((e) => e.incidents.hasMajorIncident) !=
              null,
          child: Tooltip(
            message:
                'Il y a au moins eu un accident répertorié pour cette entreprise',
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
}
