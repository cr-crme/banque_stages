import 'package:flutter/material.dart';

import '/misc/risk_data_file_service.dart';
import '/screens/ref_sst/common/risk.dart' as common_risk;
import '/screens/ref_sst/risk_card/widgets/link.dart';
import '/screens/ref_sst/risk_card/widgets/main_title.dart';
import 'widgets/sub_risk.dart';

class RisksCardsScreen extends StatelessWidget {
  const RisksCardsScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    common_risk.Risk risk = RiskDataFileService.fromId(id)!;
    return ListView(
      children: [
        MainTitle(risk.name),
        SubRisk(risk.subrisks),
        Link(risk.links)
      ],
    );
  }
}
