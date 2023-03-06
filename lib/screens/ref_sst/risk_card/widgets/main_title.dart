import 'package:flutter/material.dart';

class MainTitle extends StatelessWidget {
  //params and variables
  const MainTitle(this.mainTitle, {super.key});
  final String mainTitle;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 30, right: 25, left: 25, bottom: 25),
      child: Text(
        mainTitle,
        style: Theme.of(context).textTheme.titleLarge,
        textAlign: TextAlign.left,
      ),
    );
  }
}
