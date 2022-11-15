import 'package:flutter/material.dart';

import 'package:crcrme_banque_stages/screens/ref_sst/common/card_sst.dart';

class ListLinks extends StatelessWidget {
  //params and variables
  const ListLinks(this.links, {super.key});
  final List<RiskLink> links;
  @override
  Widget build(BuildContext context) {
    var widgetList = <Widget>[];
    for (RiskLink link in links) {
      widgetList.add(BuildALineOfALink(link));
    }
    return Center(
      child: Column(children: widgetList),
    );
  }
}

class BuildALineOfALink extends StatelessWidget {
  const BuildALineOfALink(this.link, {super.key});
  final RiskLink link;

  @override
  Widget build(BuildContext context) {
    final String linkTitle = link.title;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          link.source,
          style: const TextStyle(fontSize: 15),
        ),
        const Expanded(
          child: Text(
            " : ",
            style: TextStyle(fontSize: 15),
          ),
        ),
        Expanded(
          flex: 20,
          child: Text(linkTitle),
        )
      ],
    );
  }
}
