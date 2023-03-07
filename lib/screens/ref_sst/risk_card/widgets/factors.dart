import 'package:flutter/material.dart';

import '/screens/ref_sst/risk_card/widgets/paragraph.dart';

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
          title: const Padding(
            padding: EdgeInsets.only(bottom: 5),
            child: Text(
              'PRINCIPAUX FACTEURS AGGRAVANTS',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 190, 77, 81)),
            ),
          ),
          subtitle: Paragraph(texts),
        ),
      )
    ]);
  }
}
