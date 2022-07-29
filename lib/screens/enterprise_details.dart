import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/common/models/enterprise.dart';
import '/common/providers/enterprises_provider.dart';

class EnterpriseDetails extends StatefulWidget {
  const EnterpriseDetails({Key? key}) : super(key: key);

  static const String route = "/enterprise-details";

  @override
  State<EnterpriseDetails> createState() => _EnterpriseDetailsState();
}

class _EnterpriseDetailsState extends State<EnterpriseDetails> {
  late final String enterpriseId =
      ModalRoute.of(context)!.settings.arguments as String;

  @override
  Widget build(BuildContext context) {
    return Selector<EnterprisesProvider, Enterprise>(
        builder: (context, enterprise, child) => Scaffold(
            appBar: AppBar(
              title: Text(enterprise.name),
              actions: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.edit),
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                      "Informations générales",
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        // TODO: Display an image
                        Container(
                          width: 120,
                          height: 90,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: "Nom de l'entreprise",
                            ),
                            initialValue: enterprise.name,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    title: Text(
                      "Places de stage disponibles",
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: enterprise.jobs
                          .map(
                            (job) => ListTile(
                              visualDensity: VisualDensity.compact,
                              // TODO: Extract circle as a widget
                              leading: Icon(
                                Icons.circle,
                                color: job.totalSlot > job.occupiedSlot
                                    ? Colors.green
                                    : Theme.of(context).colorScheme.error,
                                size: 16,
                              ),
                              title: Text(job.specialization),
                              trailing: Text(
                                  "${job.totalSlot - job.occupiedSlot} / ${job.totalSlot}"),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            )),
        selector: (context, enterprises) => enterprises[enterpriseId]);
  }
}
