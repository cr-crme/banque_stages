import 'package:flutter/material.dart';

class TileJobRisk extends StatelessWidget {
  const TileJobRisk({
    super.key,
    required this.title,
    required this.elements,
    required this.nbMaximumElements,
    required this.tooltipMessage,
  });

  final String title;
  final List<dynamic> elements;
  final int nbMaximumElements;
  final String tooltipMessage;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
          textColor: Colors.black,
          collapsedTextColor: Colors.black,
          title: Text(
            title,
            style: const TextStyle(fontSize: 17),
          ),
          trailing: Material(
            elevation: 10,
            borderRadius: BorderRadius.circular(100),
            child: Tooltip(
              margin: EdgeInsets.only(
                  left: MediaQuery.of(context).size.width * 1 / 3, right: 10),
              message: tooltipMessage,
              child: Container(
                  height: 30,
                  width: 30,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: const [
                        BoxShadow(
                          spreadRadius: 1,
                          blurRadius: 5,
                          color: Colors.grey,
                        )
                      ],
                      color: elements.length / nbMaximumElements > 0.5
                          ? Colors.red
                          : Colors.orange,
                      borderRadius: BorderRadius.circular(100)),
                  child: Center(
                    child: Text(
                      elements.length.toString(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  )),
            ),
          ),
          //more than 50% of width makes circle,
          children: elements
              .map<Widget>((e) => ListTile(
                    title: Text(e.name,
                        style: const TextStyle(
                            color: Color.fromARGB(255, 113, 111, 111))),
                    minVerticalPadding: 20,
                  ))
              .toList()),
    );
  }
}
