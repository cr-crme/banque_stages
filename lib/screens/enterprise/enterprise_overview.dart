import 'package:crcrme_banque_stages/screens/enterprise/enterprise_contact.dart';
import 'package:crcrme_banque_stages/screens/enterprise/enterprise_general_informations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/common/models/enterprise.dart';
import '/common/providers/enterprises_provider.dart';

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
  bool _panelOpen = false;
  late final List<bool> _jobPanelOpen = List<bool>.filled(
      context.read<EnterprisesProvider>()[widget.enterpriseId].jobs.length,
      false);

  void modifyEnterprise(Enterprise newEnterprise) {
    context.read<EnterprisesProvider>()[widget.enterpriseId] = newEnterprise;
  }

  @override
  Widget build(BuildContext context) {
    return Selector<EnterprisesProvider, Enterprise>(
        builder: (context, enterprise, child) => Scaffold(
            appBar: AppBar(
              leading: BackButton(
                onPressed: widget.exit,
              ),
              title: Text(enterprise.name),
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  ListTile(
                    title: const Text("Informations générales"),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.pushNamed(
                        context, EnterpriseGeneralInformation.route),
                  ),
                  ListTile(
                    title: const Text("Contact"),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () =>
                        Navigator.pushNamed(context, EnterpriseContact.route),
                  ),
                  ExpansionPanelList(
                    expansionCallback: (index, expanded) {
                      setState(() {
                        _panelOpen = !expanded;
                        _jobPanelOpen.fillRange(0, _jobPanelOpen.length, false);
                      });
                    },
                    children: [
                      ExpansionPanel(
                          canTapOnHeader: true,
                          isExpanded: _panelOpen,
                          headerBuilder: (context, isExpanded) =>
                              const ListTile(
                                  title: Text("Métiers proposés en stage")),
                          body: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: ExpansionPanelList(
                              expansionCallback: (panelIndex, isExpanded) =>
                                  setState(() =>
                                      _jobPanelOpen[panelIndex] = !isExpanded),
                              children: enterprise.jobs
                                  .map((job) => ExpansionPanel(
                                      canTapOnHeader: true,
                                      isExpanded: _jobPanelOpen[enterprise.jobs
                                          .indexWhere((j) => j == job)],
                                      headerBuilder: (context, isExpanded) =>
                                          ListTile(
                                              title: Text(job.activitySector
                                                  .toString())),
                                      body: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20.0),
                                        child: Column(
                                          children: [
                                            ListTile(
                                              title: const Text(
                                                  "Tâches et photos"),
                                              trailing: const Icon(
                                                  Icons.chevron_right),
                                              onTap: () {},
                                            ),
                                            ListTile(
                                              title: const Text(
                                                  "Santé et sécurité du travail (SST)"),
                                              trailing: const Icon(
                                                  Icons.chevron_right),
                                              onTap: () {},
                                            ),
                                            ListTile(
                                              title: const Text(
                                                  "Exigences et encadrement"),
                                              trailing: const Icon(
                                                  Icons.chevron_right),
                                              onTap: () {},
                                            ),
                                          ],
                                        ),
                                      )))
                                  .toList(),
                            ),
                          ))
                    ],
                  ),
                  ListTile(
                    title: const Text("Historique des stages"),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                ],
              ),
            )),
        selector: (context, enterprises) => enterprises[widget.enterpriseId]);
  }
}
