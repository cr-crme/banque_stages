import 'package:flutter/material.dart';

class tile_job_risk extends StatelessWidget {
  const tile_job_risk(this.switchRisk, {super.key});
  final bool switchRisk;

  bool get getSwitchRisk {
    return switchRisk;
  }

/**
 * create the expansion tile widget
 */

  Widget riskTitle() {
    if (switchRisk) {
      return Text(
        "Nom risque - Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do",
        style: TextStyle(fontSize: 17),
      );
    } else
      return Text(
          "Nom compétence - Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do",
          style: TextStyle(fontSize: 17));
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
          textColor: Colors.black,
          collapsedTextColor: Colors.black,
          title: riskTitle(),
          children: [
            for (int i = 0; i < 5; i++) dropdown_obect(switchRisk),
          ]),
    );
  }
}

/**
 * Create the texte inside de expansion list tiles 
 */
class dropdown_obect extends StatelessWidget {
  dropdown_obect(this.switchRisk);
  final bool switchRisk;

  Widget dropdownRisk() {
    if (switchRisk) {
      return Text(
        "Compétence - Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor",
        style: TextStyle(color: Color.fromARGB(255, 113, 111, 111)),
      );
    } else
      return Text(
          "Risque - Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor",
          style: TextStyle(color: Color.fromARGB(255, 113, 111, 111)));
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: dropdownRisk(),
      minVerticalPadding: 20,
    );
  }
}
