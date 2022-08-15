import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '/common/models/job.dart';

class SupervisionExpansionPanel extends ExpansionPanel {
  SupervisionExpansionPanel({
    required super.isExpanded,
    required Job job,
  }) : super(
          canTapOnHeader: true,
          body: _SupervisionBody(job: job),
          headerBuilder: (context, isExpanded) => const ListTile(
            title: Text(
              "Type d'encadrement des stagiaires",
            ),
          ),
        );
}

class _SupervisionBody extends StatelessWidget {
  const _SupervisionBody({Key? key, required this.job}) : super(key: key);

  final Job job;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Size.infinite.width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _RatingBar(
              title: "Accueil de stagiaires TSA",
              rating: job.welcomingTSA,
            ),
            _RatingBar(
              title: "Accueil de stagiaires de classe communication",
              rating: job.welcomingCommunication,
            ),
            _RatingBar(
              title: "Accueil de stagiaires avec une déficience intellectuelle",
              rating: job.welcomingMentalDeficiency,
            ),
            _RatingBar(
              title: "Accueil de stagiaires avec un trouble de santé mentale",
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
    Key? key,
    required this.title,
    required this.rating,
  }) : super(key: key);

  final String title;
  final double rating;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: rating < 0 || rating > 5
                ?
                // If value is invalid
                const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text("Aucune valeur pour l'instant."),
                  )
                :
                // If value is valid
                RatingBarIndicator(
                    rating: rating,
                    itemBuilder: (context, index) => Icon(
                      Icons.star,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
