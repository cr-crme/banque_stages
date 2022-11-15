import 'package:flutter/material.dart';

import 'package:crcrme_banque_stages/screens/ref_sst/common/card_sst.dart';
import 'package:crcrme_banque_stages/screens/ref_sst/risks_cards/widgets/introduction.dart';
import 'package:crcrme_banque_stages/screens/ref_sst/risks_cards/widgets/link.dart';
import 'package:crcrme_banque_stages/screens/ref_sst/risks_cards/widgets/main_title.dart';
import 'package:crcrme_banque_stages/screens/ref_sst/risks_cards/widgets/sub_title.dart';
import 'package:crcrme_banque_stages/screens/ref_sst/risks_cards/widgets/situation_risk.dart';
import 'package:crcrme_banque_stages/screens/ref_sst/risks_cards/widgets/factors.dart';
import 'package:crcrme_banque_stages/screens/ref_sst/risks_cards/widgets/symptoms.dart';

class RisksCardsScreen extends StatefulWidget {
  const RisksCardsScreen(this.nmb, {super.key});
  final int nmb;

  static const route = "/risks-cards";

  @override
  State<RisksCardsScreen> createState() => _RisksCardsScreenState();
}

class _RisksCardsScreenState extends State<RisksCardsScreen> {
  //To remove when cache and proxy work
  final String intro =
      "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip";
  final String mainTitle =
      "Nom risque - Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt";
  final int index = 1;
  final String subTitle = "TITRE 1 - TYPE DE RISQUE";
  final Map<String, List<String>> listText = ({
    "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. UtA":
        [
      "Lorem ipsum dolor sit amet",
      "Lorem ipsum dolor sit amet",
      "Lorem ipsum dolor sit amet"
    ],
    "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. UtB":
        ["Lorem ipsum dolor sit amet", "Lorem ipsum dolor sit amet"],
    "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. UtC":
        ["Lorem ipsum dolor sit amet"],
    "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. UtD":
        []
  });

  final List<RiskLink> links = [
    const RiskLink(
        source: "CNESST",
        title: "Prot\u00e9gez-vous contre les risques biologiques",
        url: "https://www.google.ca/"),
    const RiskLink(
        source: "CNESST",
        title: "Prot\u00e9gez-vous contre les risques biologiques",
        url: "https://www.google.ca/"),
    const RiskLink(
        source: "CNESST",
        title: "Prot\u00e9gez-vous contre les risques biologiques",
        url: "https://www.google.ca/")
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Fiche ${widget.nmb}"),
        ),
        body: ListView(
          children: [
            MainTitle(mainTitle),
            SubTitle(index, subTitle),
            Introduction(intro),
            Image.asset('assets/1.png'), //Testing how the picture is display
            Container(
              margin: const EdgeInsets.only(left: 20),
              child: const Text(
                  "Illustration: Hervé Charbonneau"), //It will be with the picture
            ),
            SituationRisk(listText),
            Factors(listText),
            Symptoms(listText),
            Link(links)
          ],
        ));
  }
}
