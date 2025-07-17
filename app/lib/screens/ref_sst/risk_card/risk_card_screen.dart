import 'package:flutter/material.dart';

import 'package:crcrme_banque_stages/misc/risk_data_file_service.dart';
import 'package:crcrme_banque_stages/screens/ref_sst/common/risk.dart'
    as common_risk;
import 'package:crcrme_banque_stages/screens/ref_sst/risk_card/widgets/link.dart';
import 'package:logging/logging.dart';
import 'widgets/sub_risk.dart';

final _logger = Logger('RiskCardScreen');

class RisksCardsScreen extends StatelessWidget {
  const RisksCardsScreen({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context) {
    _logger.finer('Building RisksCardsScreen for risk ID: $id');

    common_risk.Risk risk = RiskDataFileService.fromId(id)!;
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: SubRisk(risk.subrisks),
        ),
        Link(risk.links)
      ],
    );
  }
}
