import 'package:crcrme_banque_stages/misc/job_data_file_service.dart';
import 'package:crcrme_banque_stages/screens/ref_sst/accident_history/models/accidents_by_enterprise.dart';
import 'package:flutter/material.dart';

class AccidentListTile extends StatelessWidget {
  const AccidentListTile({
    super.key,
    required this.specializationId,
    required this.accidents,
  });

  final String specializationId;
  final AccidentsByEnterprise accidents;

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
                  '${accidents.length}',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              )),
        ),
        expandedAlignment: Alignment.topLeft,
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        childrenPadding: const EdgeInsets.only(left: 24),
        children: accidents.enterprises
            .map((enterprise) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(enterprise.name),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, bottom: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: accidents
                            .description(enterprise)!
                            .map((accident) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text('\u2022'),
                                      Flexible(child: Text(accident)),
                                    ],
                                  ),
                                ))
                            .toList(),
                      ),
                    ),
                  ],
                ))
            .toList(),
      ),
    );
  }
}
