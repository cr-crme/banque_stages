import 'package:flutter/material.dart';

import '/misc/risk_data_file_service.dart';
import '/screens/ref_sst/common/risk.dart';
import '/screens/ref_sst/risk_card/widgets/link.dart';
import '/screens/ref_sst/risk_card/widgets/main_title.dart';
import 'widgets/sub_risk.dart';

class RisksCardsScreen extends StatelessWidget {
  const RisksCardsScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    //late final _riskID = ModalRoute.of(context)!.settings.arguments as String;
    Risk? risk = RiskDataFileService.fromId(id);
    return Scaffold(
        appBar: AppBar(
          title: Text("Fiche ${risk!.number}"),
        ),
        body: ListView(
          children: [
            MainTitle(risk.name),
            SubRiskBuilding(risk.subrisks),
            Link(risk.links)
          ],
        ));
  }
}
