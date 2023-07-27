import 'package:crcrme_banque_stages/common/widgets/main_drawer.dart';
import 'package:crcrme_banque_stages/screens/ref_sst/accident_history/accident_history_screen.dart';
import 'package:crcrme_banque_stages/screens/ref_sst/home_sst/widgets/sst_main_card.dart';
import 'package:crcrme_banque_stages/screens/ref_sst/risks_list/risks_list_screen.dart';
import 'package:flutter/material.dart';

import 'widgets/sst_search_bar.dart';

class HomeSstScreen extends StatefulWidget {
  const HomeSstScreen({Key? key}) : super(key: key);

  static const route = '/home-sst';

  @override
  State<HomeSstScreen> createState() => _HomeSstScreenState();
}

class _HomeSstScreenState extends State<HomeSstScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  bool test = true;

  @override
  Widget build(BuildContext context) {
    Widget body;
    body = ListView(
      children: [
        SstMainCard(
            title: 'Fiches de risques SST',
            content: const Text(
              'Principaux risques à la santé et à la sécurité en milieu de travail ',
            ),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const SstCardsScreen(),
                ))),
        SstMainCard(
          title: 'Historique d\'accidents et d\'incidents',
          content: const Text(
            'Blessures d\'élèves et incidents en stage rapportés par le personnel enseignant',
          ),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => const AccidentHistoryScreen(),
          )),
        ),
        SstMainCard(
            title: 'Aperçu des risques SST par métier',
            content: _buildRiskCard(),
            onTap: null),
      ],
    );
    // To refresh the scaffold body after the data are fetched
    WidgetsBinding.instance.addPostFrameCallback((_) => setState(() {}));
    return Scaffold(
        appBar: AppBar(
          title: const Text('Santé et sécurité au PFAE'),
        ),
        drawer: const MainDrawer(),
        body: body);
  }

  Widget _buildRiskCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
            'Analyse des risques basée sur la description des compétences '
            'de chaque métier figurant dans le répertoire'),
        const SizedBox(height: 24),
        const SstSearchBar(),
        const SizedBox(height: 24),
        Center(
          child: Text(
            '** Attention, l\'analyse indique \nles risques potentiellement '
            'présents \npour un métier donné, \nsans considérer leur dangerosité! ** ',
            style: Theme.of(context)
                .textTheme
                .titleSmall!
                .copyWith(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
