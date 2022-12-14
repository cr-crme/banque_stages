import 'package:flutter/material.dart';

import 'package:crcrme_banque_stages/misc/risk_data_file_service.dart';
import 'package:crcrme_banque_stages/screens/ref_sst/common/Risk.dart';

import 'package:crcrme_banque_stages/screens/ref_sst/risk_card/widgets/link.dart';
import 'package:crcrme_banque_stages/screens/ref_sst/risk_card/widgets/main_title.dart';

import 'widgets/sub_risk.dart';

class RisksCardsScreen extends StatelessWidget {
  static const route = "/risks-cards";

  const RisksCardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    //late final _riskID = ModalRoute.of(context)!.settings.arguments as String;
    Risk? risk = RiskDataFileService.fromId(
        ModalRoute.of(context)!.settings.arguments as String);
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
