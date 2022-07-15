import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/common/models/enterprise.dart';
import '/common/providers/enterprises_provider.dart';
import '/screens/enterprises/enterprise_details.dart';
import 'add_enterprise.dart';

class EnterprisesList extends StatefulWidget {
  const EnterprisesList({Key? key}) : super(key: key);

  static const route = "/enterprises";

  @override
  State<EnterprisesList> createState() => _EnterprisesListState();
}

class _EnterprisesListState extends State<EnterprisesList> {
  bool _hideNotAvailable = true;

  void _openEnterpriseDetails(Enterprise enterprise) {
    Navigator.pushNamed(context, EnterpriseDetails.route,
        arguments: context
            .read<EnterprisesProvider>()
            .enterprises
            .indexOf(enterprise));
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
              icon: const Icon(Icons.search))
        ],
      ),
      body: SingleChildScrollView(
          child: Column(
        children: [
          SwitchListTile(
              title: const Text("Cacher les stages indisponibles"),
              value: _hideNotAvailable,
              onChanged: (value) => setState(() => _hideNotAvailable = value)),
          Consumer<EnterprisesProvider>(
              builder: (context, enterprisesProvider, child) => Column(
                  children: enterprisesProvider.enterprises
                      .map((enterprise) => InkWell(
                            onTap: () => _openEnterpriseDetails(enterprise),
                            child: ListTile(
                              title: Text(enterprise.name),
                              subtitle: Column(
                                  children: enterprise.jobs
                                      .map((job) => Row(
                                            children: [
                                              Text(
                                                job.specialization.toString(),
                                              )
                                            ],
                                          ))
                                      .toList()),
                            ),
                          ))
                      .toList()))
        ],
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, AddEnterprise.route),
        child: const Icon(Icons.add),
      ),
    );
  }
}