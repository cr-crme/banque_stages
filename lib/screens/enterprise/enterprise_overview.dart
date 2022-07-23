import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/common/models/enterprise.dart';
import '/common/models/job.dart';
import '/common/providers/enterprises_provider.dart';
import '/common/widgets/job_creator_dialog.dart';
import 'enterprise_informations.dart';
import 'enterprise_job_task.dart';

class EnterpriseOverview extends StatefulWidget {
  const EnterpriseOverview(
      {Key? key, required this.enterpriseId, required this.exit})
      : super(key: key);

  static const String route = "/";

  final String enterpriseId;
  final void Function() exit;

  @override
  State<EnterpriseOverview> createState() => _EnterpriseOverviewState();
}

class _EnterpriseOverviewState extends State<EnterpriseOverview> {
  Future<void> _showJobCreator() async {
    EnterprisesProvider provider = context.read<EnterprisesProvider>();

    Job job = await showDialog(
        context: context, builder: (context) => const JobCreatorDialog());

    setState(() {
      provider[widget.enterpriseId].jobs.add(job);
      provider.notifyJobsChanges();
    });
  }

  void _removeJob(int value) {
    EnterprisesProvider provider = context.read<EnterprisesProvider>();

    setState(() {
      provider[widget.enterpriseId].jobs.remove(value);
      provider.notifyJobsChanges();
    });
  }

  void modifyEnterprise(Enterprise newEnterprise) {
    context.read<EnterprisesProvider>()[widget.enterpriseId] = newEnterprise;
  }

  @override
  Widget build(BuildContext context) {
    return Selector<EnterprisesProvider, Enterprise>(
        builder: (context, enterprise, child) => Scaffold(
            appBar: AppBar(
              leading: BackButton(onPressed: widget.exit),
              title: Text(enterprise.name),
              actions: [
                IconButton(
                  onPressed: () => Navigator.pushNamed(
                      context, EnterpriseInformations.route),
                  icon: const Icon(Icons.edit),
                ),
              ],
              bottom: enterprise.jobs.isEmpty
                  ? null
                  : PreferredSize(
                      preferredSize:
                          Size.fromHeight(enterprise.jobs.length * 32 + 35),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 80, vertical: 8.0),
                        child: Column(
                          children: [
                            SizedBox(
                              width: Size.infinite.width,
                              child: Text(
                                "Places de stage disponibles",
                                textAlign: TextAlign.start,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    !.copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary),
                              ),
                            ),
                            SizedBox(
                              height: enterprise.jobs.length * 32,
                              child: ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: enterprise.jobs.length,
                                itemBuilder: (context, i) => Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.circle,
                                        color: enterprise.jobs[i].totalSlot >
                                                enterprise.jobs[i].occupiedSlot
                                            ? Colors.green
                                            : Colors.red,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                            enterprise.jobs[i].specialization
                                                .toString(),
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleSmall
                                                !.copyWith(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .onPrimary)),
                                      ),
                                      Text(
                                          "${enterprise.jobs[i].totalSlot - enterprise.jobs[i].occupiedSlot} / ${enterprise.jobs[i].totalSlot}",
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall
                                              !.copyWith(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onPrimary)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  ListTile(
                    title: const Text("Types d'activités"),
                    trailing: Text(
                      enterprise.activityTypes.join(", "),
                      maxLines: 2,
                    ),
                  ),
                  ListTile(
                    title: const Text("Adresse"),
                    trailing: Text(enterprise.address),
                  ),
                  Card(
                    child: ListTile(
                      title: const Text("Plus d'informations"),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => Navigator.pushNamed(
                        context,
                        EnterpriseInformations.route,
                      ),
                    ),
                  ),
                  ListTile(
                    title: Text(
                      "Métiers proposés en stage",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    trailing: IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: _showJobCreator),
                  ),
                  Visibility(
                    visible: enterprise.jobs.isNotEmpty,
                    replacement: Text(
                      "Cette entreprise n'a aucun stage disponible",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    child: ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: enterprise.jobs.length,
                      itemBuilder: (context, index) => Card(
                        child: ListTile(
                          title: Text(
                              enterprise.jobs[index].specialization.toString()),
                          subtitle: Text(
                              enterprise.jobs[index].activitySector.toString()),
                          trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _removeJob(index)),
                          onTap: () => Navigator.pushNamed(
                              context, EnterpriseJobTask.route,
                              arguments: enterprise.jobs[index].id),
                        ),
                      ),
                    ),
                  ),
                  const Divider(),
                  Card(
                    child: ListTile(
                      title: const Text("Historique des stages"),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {},
                    ),
                  ),
                ],
              ),
            )),
        selector: (context, enterprises) => enterprises[widget.enterpriseId]);
  }
}
