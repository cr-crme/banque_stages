import 'package:flutter/material.dart';

import '/common/models/enterprise.dart';
import '/common/widgets/disponibility_circle.dart';

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
                enterprise.headquartersAddress != null
                    ? enterprise.headquartersAddress.toString()
                    : enterprise.address.toString(),
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
                .toList()
          ],
        ),
      ),
    );
  }
}
