import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/common/providers/enterprises_provider.dart';
import 'add_enterprise.dart';

class EnterprisesList extends StatefulWidget {
  const EnterprisesList({Key? key}) : super(key: key);

  static const route = "/enterprises";

  @override
  State<EnterprisesList> createState() => _EnterprisesListState();
}

class _EnterprisesListState extends State<EnterprisesList> {
  bool _hideNotAvailable = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Entreprises")),
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
                      .map((enterprise) =>
                          ListTile(title: Text(enterprise.name)))
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
