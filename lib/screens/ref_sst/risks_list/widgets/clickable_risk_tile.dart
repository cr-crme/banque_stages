//import 'dart:js_util';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '/router.dart';
import '../../common/risk.dart';

//SST
class SSTCard extends StatelessWidget {
  //params and variables
  const SSTCard(this.risk, {super.key});
  final Risk risk;

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 0.5,
        child: ListTile(
          title: Text(
            'FICHE ${risk.number}',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          subtitle: Text(
            risk.name,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          isThreeLine: true,
          //onTap should redirect to the risk
          onTap: () => GoRouter.of(context)
              .goNamed(Screens.risksCardsSST, params: {'id': risk.id}),
        ));
  }
}
