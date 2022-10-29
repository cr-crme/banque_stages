import 'dart:collection';
import 'package:flutter/services.dart';

import 'package:flutter/material.dart';

import 'package:crcrme_banque_stages/screens/ref_sst/common/card_sst.dart';

class ListLinks extends StatelessWidget {
  //params and variables
  const ListLinks(this.links, {super.key});
  final List<LinkSST> links;
  @override
  Widget build(BuildContext context) {
    var widgetList = <Widget>[];
    for (LinkSST entry in links) {
      widgetList.add(ConstructLineWithDot(entry));

      widgetList.add(const SizedBox(
        height: 5.0,
      ));
    }
    return Center(
      child: Container(
        child: Column(children: widgetList),
      ),
    );
  }
}

class ConstructLineWithDot extends StatelessWidget {
  const ConstructLineWithDot(this.link, {super.key});
  final LinkSST link;

  @override
  Widget build(BuildContext context) {
    final String linkTitle = link.title;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          link.source,
          style: TextStyle(fontSize: 15),
        ),
        Expanded(
          child: Text(
            " : ",
            style: const TextStyle(fontSize: 15),
          ),
        ),
        Expanded(
          child: Text(linkTitle),
          flex: 20,
        )
      ],
    );
  }
}

class ConstructSubPoint extends StatelessWidget {
  const ConstructSubPoint(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          "      ◦ ",
          style: TextStyle(fontSize: 15),
        ),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 15),
          ),
        ),
      ],
    );
  }
}
