import 'package:flutter/material.dart';

import '/screens/ref_sst/risk_card/widgets/paragraph.dart';

class SituationRisk extends StatelessWidget {
  //params and variables
  const SituationRisk(this.texts, {super.key});
  final Map<String, List<String>> texts;
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        margin: const EdgeInsets.only(top: 30, right: 25, left: 10),
        child: ListTile(
          textColor: Colors.black,
          title: Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Text(
              'Exemples de situation à risque',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ),
          subtitle: Paragraph(texts),
        ),
      )
    ]);
  }
}
