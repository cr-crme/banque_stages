import 'package:flutter/material.dart';

import 'package:crcrme_banque_stages/screens/ref_sst/risk_card/widgets/paragraph.dart';

class Factors extends StatelessWidget {
  //params and variables
  const Factors(this.texts, {super.key});
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
              'Principaux facteurs aggravants',
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
