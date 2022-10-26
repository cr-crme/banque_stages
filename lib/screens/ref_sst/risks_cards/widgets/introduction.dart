import 'package:flutter/material.dart';

import 'package:crcrme_banque_stages/screens/ref_sst/risks_cards/risks_cards_screen.dart';

class Introduction extends StatelessWidget {
  //params and variables
  const Introduction(this.intro, {super.key});
  final String intro;

  @override
  Widget build(BuildContext context) {
    return Text(intro);
  }
}
