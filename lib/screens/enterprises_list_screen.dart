import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/common/models/enterprise.dart';
import '/common/providers/enterprises_provider.dart';
import '/dummy_data.dart';
import 'add_enterprise_screen.dart';
import 'enterprise/enterprise_screen.dart';

class EnterprisesListScreen extends StatefulWidget {
  const EnterprisesListScreen({Key? key}) : super(key: key);

  static const route = "/enterprises-list";

  @override
  State<EnterprisesListScreen> createState() => _EnterprisesListScreenState();
}

class _EnterprisesListScreenState extends State<EnterprisesListScreen> {
  bool _hideNotAvailable = true;

  void _openEnterpriseDetails(Enterprise enterprise) {
    Navigator.pushNamed(context, EnterpriseScreen.route,
        arguments: enterprise.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Entreprises"),
        actions: [
          IconButton(
            onPressed: () {},
            tooltip: "Rechercher un stage",
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () =>
                Navigator.pushNamed(context, AddEnterpriseScreen.route),
            tooltip: "Ajouter une entreprise",
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SwitchListTile(
                title: const Text("Cacher les stages indisponibles"),
                value: _hideNotAvailable,
                onChanged: (value) =>
                    setState(() => _hideNotAvailable = value)),
            Consumer<EnterprisesProvider>(
              builder: (context, enterprises, child) => Column(
                children: enterprises
                    .map(
                      (enterprise) => ListTile(
                        title: Text(enterprise.name),
                        subtitle: Column(
                          children: enterprise.jobs
                              .map(
                                (job) => Row(
                                  children: [
                                    Text(
                                      job.specialization.toString(),
                                    )
                                  ],
                                ),
                              )
                              .toList(),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _openEnterpriseDetails(enterprise),
                      ),
                    )
                    .toList(),
              ),
            ),
            Consumer<EnterprisesProvider>(
              builder: (context, enterprises, child) => Visibility(
                visible: enterprises.isEmpty,
                child: ElevatedButton(
                    onPressed: () => addDummyEnterprises(enterprises),
                    child: const Text("Add dummy enterprises")),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
