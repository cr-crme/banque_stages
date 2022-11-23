import 'package:flutter/material.dart';
import 'package:crcrme_banque_stages/screens/ref_sst/common/risk.dart';
import 'package:crcrme_banque_stages/screens/ref_sst/risks_cards/widgets/list_links.dart';

class Link extends StatelessWidget {
  //params and variables
  const Link(this.links, {super.key});
  final List<RiskLink> links;
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        margin: const EdgeInsets.only(top: 30, right: 25, left: 10),
        child: ListTile(
          tileColor: Colors.grey[300],
          textColor: Colors.black,
          title: const Padding(
            padding: EdgeInsets.only(bottom: 5, top: 15),
            child: Text(
              "POUR ALLER PLUS LOIN",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 0, 0, 0)),
            ),
          ),
          subtitle: ListLinks(links),
        ),
      )
    ]);
  }
}
