import 'package:flutter/material.dart';

import 'add_enterprise.dart';

class EnterprisesList extends StatefulWidget {
  const EnterprisesList({Key? key}) : super(key: key);

  static const route = "/enterprises";

  @override
  State<EnterprisesList> createState() => _EnterprisesListState();
}

class _EnterprisesListState extends State<EnterprisesList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Entreprises")),
      body: SingleChildScrollView(
          child: Column(
        children: [],
      )),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, AddEnterprise.route),
        child: const Icon(Icons.add),
      ),
    );
  }
}
