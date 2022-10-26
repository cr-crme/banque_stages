import 'package:flutter/material.dart';

class SubTitle extends StatelessWidget {
  //params and variables
  const SubTitle(this.index, this.title, {super.key});
  final int index;
  final String title;

  @override
  Widget build(BuildContext context) {
    return ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color.fromARGB(255, 190, 77, 81),
          child: Text(
            index.toString(),
            style: const TextStyle(
                color: Color.fromARGB(255, 255, 255, 255),
                fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
              color: const Color.fromARGB(255, 1, 1, 1),
              fontWeight: FontWeight.bold),
        ));
  }
}
