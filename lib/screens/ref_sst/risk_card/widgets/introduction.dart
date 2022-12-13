import 'package:crcrme_banque_stages/screens/ref_sst/common/Risk.dart';
import 'package:flutter/material.dart';

class Introduction extends StatelessWidget {
  //params and variables
  const Introduction(this.intro, {super.key});
  final String intro;
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Center(
        child: Container(
          margin: const EdgeInsets.only(top: 0, right: 25, left: 25),
          child: Text(
            intro,
            style: const TextStyle(fontSize: 15),
          ),
        ),
      )
    ]);
  }
}
