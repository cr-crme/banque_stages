import 'package:flutter/material.dart';

import '/common/models/enterprise.dart';

class StagePage extends StatefulWidget {
  const StagePage({
    Key? key,
    required this.enterprise,
  }) : super(key: key);

  final Enterprise enterprise;

  @override
  State<StagePage> createState() => StagePageState();
}

class StagePageState extends State<StagePage> {
  void Function() get actionButtonOnPressed => _addStage;
  Icon get actionButtonIcon => const Icon(Icons.add);

  void _addStage() {}

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
