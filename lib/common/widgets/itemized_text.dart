import 'package:flutter/material.dart';

class ItemizedText extends StatelessWidget {
  const ItemizedText({super.key, required this.elements, this.interline = 0});

  final List<String> elements;
  final double interline;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: elements
          .asMap()
          .keys
          .map(
            (i) => Padding(
              padding: EdgeInsets.only(top: i != 0 ? interline : 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('\u2022 '),
                  Flexible(child: Text(elements[i])),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
