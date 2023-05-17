import 'package:flutter/material.dart';

import '/common/models/enterprise.dart';
import '/common/models/job.dart';
import '/common/widgets/sub_title.dart';

class GeneralInformationsStep extends StatelessWidget {
  const GeneralInformationsStep({
    super.key,
    required this.enterprise,
    required this.job,
  });

  final Enterprise enterprise;
  final Job job;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: TextField(
              decoration:
                  const InputDecoration(labelText: 'Nom de l\'entreprise'),
              controller: TextEditingController(text: enterprise.name),
              enabled: false,
            ),
          ),
          ListTile(
            title: TextField(
              decoration:
                  const InputDecoration(labelText: 'Secteur d\'activité'),
              controller:
                  TextEditingController(text: job.specialization.sector.name),
              enabled: false,
            ),
          ),
          ListTile(
            title: TextField(
              decoration:
                  const InputDecoration(labelText: 'Métier semi-spécialisé'),
              controller: TextEditingController(text: job.specialization.name),
              enabled: false,
            ),
          ),
          ListTile(
            title: TextField(
              decoration: const InputDecoration(labelText: 'Année scolaire'),
              controller: TextEditingController(text: '2022-2023'),
              enabled: false,
            ),
          ),
          const SubTitle('Objectifs'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Objectif principal : ',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Padding(
                  padding: EdgeInsets.only(bottom: 16, top: 8),
                  child: Text(
                    'Susciter une discussion sur la santé et la sécurité du '
                    'travail (SST) des stagiaires. Les différentes questions et '
                    'sous-questions visent à favoriser le dialogue avec '
                    'les entreprises.',
                  ),
                ),
                Text(
                  'Objectif spécifiques : ',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 16, top: 8),
                  child: Column(
                    children: [
                      Text(
                        '\u2022 Éclairer les enseignants sur de possibles '
                        'risques pour la santé et la sécurité du travail (SST) '
                        'des élèves en stage.',
                      ),
                      Text(
                        '\u2022 Faire prendre conscience aux personnes de '
                        'l\'entreprise que l\'enseignant est attentif à la SST '
                        'et qu\'il sera un partenaire pour former l\'élève '
                        'sur ce sujet.',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SubTitle('Cible'),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Entreprise dans laquelle un élève est placée pour la '
              'première fois en stage',
            ),
          ),
          const SubTitle('Recommandations'),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Remplir ce formulaire lors d\'un entretien :',
                ),
                Padding(
                  padding: EdgeInsets.only(left: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '\u2022 Avec la personne qui est en charge de former '
                        'l\'élève sur le plancher:',
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '\u2022 C\'est elle qui connait le mieux le poste '
                              'de travail de l\'élève',
                            ),
                            Text(
                              '\u2022 Il sera plus facile d\'aborder avec elle '
                              'qu\'avec les employeurs les questions relatives '
                              'aux dangers et aux accidents)',
                            ),
                          ],
                        ),
                      ),
                      Text('\u2022 La 1ère semaine de stage'),
                      Text(
                        '\u2022 Pendant (ou à la suite) d\'une visite du poste '
                        'de travail de l\'élève',
                      ),
                    ],
                  ),
                ),
                Text(''),
                Text('Durée de remplissage : 15 minutes'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
