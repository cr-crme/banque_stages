import 'package:flutter/material.dart';

class Paragraph extends StatelessWidget {
  //params and variables
  const Paragraph(this.texts, {super.key});
  final Map<String, List<String>> texts;
  @override
  Widget build(BuildContext context) {
    var widgetList = <Widget>[];
    for (MapEntry<String, dynamic> point in texts.entries) {
      widgetList.add(BuildLineWithDot(point.key));
      for (String subPoint in point.value) {
        widgetList.add(BuildSubPoint(subPoint));
      }
      widgetList.add(const SizedBox(
        height: 5.0,
      ));
    }
    return Center(
      child: Column(children: widgetList),
    );
  }
}

class BuildLineWithDot extends StatelessWidget {
  const BuildLineWithDot(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          '• ',
          style: TextStyle(fontSize: 15, color: Colors.red),
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

class BuildSubPoint extends StatelessWidget {
  const BuildSubPoint(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          '      ◦ ',
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
