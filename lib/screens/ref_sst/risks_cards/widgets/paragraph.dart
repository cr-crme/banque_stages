import 'package:flutter/material.dart';

class Paragraph extends StatelessWidget {
  //params and variables
  const Paragraph(this.texts, {super.key});
  final List<String> texts;
  @override
  Widget build(BuildContext context) {
    var widgetList = <Widget>[];
    for (var text in texts) {
      widgetList.add(ConstructParagraph(text));
      widgetList.add(const SizedBox(
        height: 5.0,
      ));
    }
    return Column(children: widgetList);
  }
}

class ConstructParagraph extends StatelessWidget {
  const ConstructParagraph(this.text, {super.key});
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
