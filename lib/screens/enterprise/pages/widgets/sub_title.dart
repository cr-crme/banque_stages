import 'package:flutter/material.dart';

class SubTitle extends StatelessWidget {
  const SubTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(text, style: Theme.of(context).textTheme.titleLarge),
    );
  }
}
