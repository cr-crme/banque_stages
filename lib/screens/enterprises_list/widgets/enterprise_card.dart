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
      elevation: 0.5,
      child: InkWell(
        onTap: () => onTap(enterprise),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 60,
                color: Theme.of(context).disabledColor,
                child: enterprise.photo.isNotEmpty
                    ? Image.network(enterprise.photo)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      enterprise.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Visibility(
                      visible: enterprise.address.isNotEmpty ||
                          enterprise.headquartersAddress.isNotEmpty,
                      child: Column(
                        children: [
                          const SizedBox(height: 8),
                          Text(
                            enterprise.address.isEmpty
                                ? enterprise.headquartersAddress
                                : enterprise.address,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: enterprise.jobs
                          .map((job) => Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Row(
                                  children: [
                                    DisponibilityCircle(
                                        positionsOffered: job.positionsOffered,
                                        positionsOccupied:
                                            job.positionsOccupied),
                                    const SizedBox(width: 8),
                                    Text(
                                      job.specialization?.idWithName ??
                                          "bad id",
                                    ),
                                  ],
                                ),
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).hintColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
