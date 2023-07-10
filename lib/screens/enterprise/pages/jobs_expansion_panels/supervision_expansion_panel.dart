import 'package:crcrme_banque_stages/common/models/job.dart';
import 'package:crcrme_banque_stages/common/widgets/form_fields/low_high_slider_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class SupervisionExpansionPanel extends ExpansionPanel {
  SupervisionExpansionPanel({
    required super.isExpanded,
    required Job job,
  }) : super(
          canTapOnHeader: true,
          body: _SupervisionBody(job: job),
          headerBuilder: (context, isExpanded) => const ListTile(
            title: Text('Encadrement des stagiaires'),
          ),
        );
}

class _SupervisionBody extends StatelessWidget {
  const _SupervisionBody({required this.job});

  final Job job;

  @override
  Widget build(BuildContext context) {
    final evaluations = job.postInternshipEnterpriseEvaluations(context);
    final skillsRequired = evaluations.expand((e) => e.skillsRequired).toList();

    return SizedBox(
      width: Size.infinite.width,
      child: Padding(
        padding: const EdgeInsets.only(left: 24.0, right: 24),
        child: evaluations.isNotEmpty
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Variété des tâches',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  LowHighSliderFormField(
                    initialValue: meanOf(evaluations, (e) => e.taskVariety),
                    enabled: false,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Habiletés obligatoires',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: skillsRequired.isEmpty
                        ? [const Text('Aucune habileté requise')]
                        : skillsRequired
                            .map((skills) => Text('- $skills'))
                            .toList(),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Niveau d\'autonomie souhaité',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  LowHighSliderFormField(
                    initialValue:
                        meanOf(evaluations, (e) => e.autonomyExpected),
                    enabled: false,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Rendement attendu',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  LowHighSliderFormField(
                    initialValue:
                        meanOf(evaluations, (e) => e.efficiencyWanted),
                    enabled: false,
                  ),
                  const SizedBox(height: 12),
                  _RatingBar(
                    title:
                        'Accueil de stagiaires avec un trouble du spectre de l\'autisme (TSA)',
                    rating: meanOf(evaluations, (e) => e.welcomingTsa),
                  ),
                  _RatingBar(
                    title: 'Accueil de stagiaires avec un trouble du langage',
                    rating:
                        meanOf(evaluations, (e) => e.welcomingCommunication),
                  ),
                  _RatingBar(
                    title:
                        'Accueil de stagiaires avec une déficience intellectuelle',
                    rating:
                        meanOf(evaluations, (e) => e.welcomingMentalDeficiency),
                  ),
                  _RatingBar(
                    title:
                        'Accueil de stagiaires avec un trouble de santé mentale',
                    rating: meanOf(
                        evaluations, (e) => e.welcomingMentalHealthIssue),
                  ),
                ],
              )
            : const Center(
                child: Padding(
                padding: EdgeInsets.only(bottom: 12.0),
                child: Text('Aucune donnée pour l\'instant'),
              )),
      ),
    );
  }
}

class _RatingBar extends StatelessWidget {
  const _RatingBar({
    required this.title,
    required this.rating,
  });

  final String title;
  final double rating;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        rating < 0 || rating > 5
            ?
            // If value is invalid
            const Text('Aucune donnée pour l\'instant.')
            :
            // If value is valid
            RatingBarIndicator(
                rating: rating,
                itemBuilder: (context, index) => Icon(
                  Icons.star,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
        const SizedBox(height: 12),
      ],
    );
  }
}
