import 'package:flutter/material.dart';

class Paragraph extends StatelessWidget {
  //params and variables
  const Paragraph(this.texts, {super.key});
  final Map<String, List<String>> texts;
  @override
  Widget build(BuildContext context) {
    var widgetList = <Widget>[];
    for (MapEntry<String, dynamic> point in texts.entries) {
      widgetList.add(ConstructLineWithDot(point.key));
      for (String subPoint in point.value) {
        widgetList.add(ConstructSubPoint(subPoint));
      }
      widgetList.add(const SizedBox(
        height: 5.0,
      ));
    }
    return Center(
      child: Container(
        margin: const EdgeInsets.only(
          top: 30,
          right: 25,
          left: 25,
        ),
        child: Column(children: widgetList),
      ),
    );
  }
}

class ConstructLineWithDot extends StatelessWidget {
  const ConstructLineWithDot(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text("• "),
        Expanded(
          child: Text(text),
        ),
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
        const Text("      ◦ "),
        Expanded(
          child: Text(text),
        ),
      ],
    );
  }
}
