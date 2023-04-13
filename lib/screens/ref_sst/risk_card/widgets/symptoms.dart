import 'package:flutter/material.dart';

import '/screens/ref_sst/risk_card/widgets/paragraph.dart';

class Symptoms extends StatelessWidget {
  //params and variables
  const Symptoms(this.texts, {super.key});
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
              'Symptômes et effets sur la santé les plus fréquents',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Color(0xFFE65D4E)),
            ),
          ),
          subtitle: Paragraph(texts),
        ),
      )
    ]);
  }
}
