import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'package:crcrme_banque_stages/common/models/job.dart';

class SupervisionExpansionPanel extends ExpansionPanel {
  SupervisionExpansionPanel({
    required super.isExpanded,
    required Job job,
  }) : super(
          canTapOnHeader: true,
          body: _SupervisionBody(job: job),
          headerBuilder: (context, isExpanded) => const ListTile(
            title: Text('Type d\'encadrement des stagiaires'),
          ),
        );
}

class _SupervisionBody extends StatelessWidget {
  const _SupervisionBody({required this.job});

  final Job job;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Size.infinite.width,
      child: Padding(
        padding: const EdgeInsets.only(left: 24.0, right: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (job.welcomingTsa != -1)
              _RatingBar(
                title:
                    'Accueil de stagiaires avec un trouble du spectre de l\'autisme (TSA)',
                rating: job.welcomingTsa,
              ),
            _RatingBar(
              title: 'Accueil de stagiaires avec un trouble du langage',
              rating: job.welcomingCommunication,
            ),
            _RatingBar(
              title: 'Accueil de stagiaires avec une déficience intellectuelle',
              rating: job.welcomingMentalDeficiency,
            ),
            _RatingBar(
              title: 'Accueil de stagiaires avec un trouble de santé mentale',
              rating: job.welcomingMentalHealthIssue,
            ),
          ],
        ),
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
