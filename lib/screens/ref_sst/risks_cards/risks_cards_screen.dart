import 'package:flutter/material.dart';

import 'package:crcrme_banque_stages/misc/risk_data_file_service.dart';
import 'package:crcrme_banque_stages/screens/ref_sst/common/Risk.dart';

import 'package:crcrme_banque_stages/screens/ref_sst/risks_cards/widgets/link.dart';
import 'package:crcrme_banque_stages/screens/ref_sst/risks_cards/widgets/main_title.dart';

import 'widgets/sub_risk.dart';

class RisksCardsScreen extends StatefulWidget {
  const RisksCardsScreen(this.id, {super.key});
  final String id;
  // Risk? risk;

  static const route = "/risks-cards";

  @override
  State<RisksCardsScreen> createState() => _RisksCardsScreenState();
}

class _RisksCardsScreenState extends State<RisksCardsScreen> {
  //To remove when cache and proxy work

  Risk? risk;

  @override
  void initState() {
    risk = RiskDataFileService.fromId(widget.id);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Fiche ${risk!.number}"),
        ),
        body: ListView(
          children: [
            MainTitle(RiskDataFileService.risks[0].name),
            SubRiskBuilding(risk!.subrisks),
            Link(RiskDataFileService.risks[0].links)
          ],
        ));
  }
}
