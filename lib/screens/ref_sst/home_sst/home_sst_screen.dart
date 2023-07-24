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
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _TextWithBoldTitle(
            title: 'Par compétence\u00a0: ',
            text: 'nombre de risques potentiellement présents'),
        _TextWithBoldTitle(
            title: 'Par risque\u00a0: ',
            text: 'nombre de compétences possiblement concernées'),
        SizedBox(height: 4),
        SizedBox(height: 12),
        SstSearchBar(),
        SizedBox(height: 12),
        Center(
          child: Text(
            '** Attention, l\'évaluation indique \nles risques potentiellement '
            'présents \npour un métier donné, \nsans considérer leur dangerosité! ** ',
            style: TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: 24),
        Text(
          'Évaluation des risques\u00a0:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        _TextWithBoldTitle(
            title: 'Basée sur la description des compétences de chaque métier ',
            text: 'figurant dans le répertoire des métiers semi-spécialisés du '
                'Ministère'),
        _TextWithBoldTitle(
            title: 'Pour les 45 métiers les plus populaires ',
            text: 'du répertoire'),
        _TextWithBoldTitle(
            title: 'Théorique\u00a0: ',
            text: 'ne tient pas compte du contexte de chaque milieu de stage'),
        SizedBox(height: 24),
        _BoxWarning(),
        SizedBox(height: 24),
      ],
    );
  }
}

class _BoxWarning extends StatelessWidget {
  const _BoxWarning();

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(color: Colors.grey[400]),
        child: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'POUR CONNAITRE LES RISQUES DANS UNE ENTREPRISE SPÉCIFIQUE',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Remplir le formulaire "Aborder la SST avec l\'entreprise" '
                'accessible sur la fiche de chaque entreprise.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ));
  }
}

class _TextWithBoldTitle extends StatelessWidget {
  const _TextWithBoldTitle({
    required this.title,
    required this.text,
  });

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('\u2022 '),
        Flexible(
          child: RichText(
              text: TextSpan(children: [
            TextSpan(
                text: title,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .copyWith(fontWeight: FontWeight.bold)),
            TextSpan(text: text, style: Theme.of(context).textTheme.bodyLarge)
          ])),
        )
      ],
    );
  }
}
