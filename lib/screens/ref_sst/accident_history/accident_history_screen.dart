import 'package:crcrme_banque_stages/common/providers/enterprises_provider.dart';
import 'package:crcrme_banque_stages/screens/ref_sst/accident_history/models/accidents_by_enterprise.dart';
import 'package:crcrme_banque_stages/screens/ref_sst/accident_history/widgets/accident_list_tile.dart';
import 'package:flutter/material.dart';

class AccidentHistoryScreen extends StatelessWidget {
  const AccidentHistoryScreen({super.key});

  static const route = '/accident-history-screen';

  Map<String, AccidentsByEnterprise> _fetchAllAccidents(context) {
    final enterprises = EnterprisesProvider.of(context);

    Map<String, AccidentsByEnterprise> out = {};
    for (final enterprise in enterprises) {
      for (final job in enterprise.jobs) {
        // Do not add if there is no incident
        if (job.sstEvaluation.incidents.isEmpty) continue;

        if (!out.containsKey(job.specialization.id)) {
          out[job.specialization.id] = AccidentsByEnterprise();
        }
        out[job.specialization.id]!
            .add(enterprise, job.sstEvaluation.incidents);
      }
    }

    return out;
  }

  @override
  Widget build(BuildContext context) {
    final accidents = _fetchAllAccidents(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique d\'accidents'),
        leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back)),
      ),
      body: ListView.builder(
        itemCount: accidents.length,
        itemBuilder: (context, index) {
          final specializationId = accidents.keys.toList()[index];
          return AccidentListTile(
              specializationId: specializationId,
              accidents: accidents[specializationId]!);
        },
      ),
    );
  }
}
