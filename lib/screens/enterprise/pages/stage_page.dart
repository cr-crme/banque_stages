import 'package:flutter/material.dart';

import '/common/models/enterprise.dart';

class StagePage extends StatefulWidget {
  const StagePage({
    super.key,
    required this.enterprise,
  });

  final Enterprise enterprise;

  @override
  State<StagePage> createState() => StagePageState();
}

class StagePageState extends State<StagePage> {
  void addStage() {}

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          ListTile(
            title: Text(
              "Historique des stages",
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const Divider(),
        ],
      ),
    );
  }
}
