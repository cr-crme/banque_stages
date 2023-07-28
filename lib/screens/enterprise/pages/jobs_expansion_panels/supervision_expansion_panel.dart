import 'package:crcrme_banque_stages/common/models/internship.dart';
import 'package:crcrme_banque_stages/common/models/job.dart';
import 'package:crcrme_banque_stages/common/widgets/form_fields/low_high_slider_form_field.dart';
import 'package:crcrme_banque_stages/common/widgets/itemized_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

double _meanOf(
    List list, double Function(PostIntershipEnterpriseEvaluation) value) {
  var runningSum = 0.0;
  var nElements = 0;
  for (final e in list) {
    final valueTp = value(e);
    if (valueTp < 0) continue;
    runningSum += valueTp;
    nElements++;
  }
  return nElements == 0 ? -1 : runningSum / nElements;
}

class SupervisionExpansionPanel extends ExpansionPanel {
  SupervisionExpansionPanel({
    required super.isExpanded,
    required Job job,
  }) : super(
          canTapOnHeader: true,
          body: _SupervisionBody(job: job),
          headerBuilder: (context, isExpanded) => ListTile(
            title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Encadrement des stagiaires'),
                  if (isExpanded) _buildInfoButton(context),
                ]),
          ),
        );

  static Widget _buildInfoButton(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(25)),
        child: InkWell(
          borderRadius: BorderRadius.circular(25),
          onTap: () =>
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  duration: Duration(seconds: 10),
                  content: Text('Les résultats sont le cumul des '
                      'évaluations des personnes ayant '
                      'supervisé des élèves dans cette entreprise. '
                      '\nIls sont différenciés entre '
                      'FMS et FPT.'))),
          child: Icon(
            Icons.info,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
    );
  }
}

Widget _printCountedList<T>(Iterable iterable, String Function(T) toString) {
  var out = iterable.map<String>((e) => toString(e)).toList();

  out = out
      .toSet()
      .map((e) =>
          '$e (${out.fold<int>(0, (prev, e2) => prev + (e == e2 ? 1 : 0))})')
      .toList();
  return ItemizedText(out);
}

class _SupervisionBody extends StatelessWidget {
  const _SupervisionBody({required this.job});

  final Job job;

  @override
  Widget build(BuildContext context) {
    final evaluations = job.postInternshipEnterpriseEvaluations(context);

    return Padding(
      padding: const EdgeInsets.only(left: 24.0, right: 24),
      child: evaluations.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 12.0),
                child: Text('Aucune donnée pour l\'instant'),
              ),
            )
          : Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTaskVariety(context, evaluations),
                    const SizedBox(height: 12),
                    _buildTrainingPlanRespect(context, evaluations),
                    const SizedBox(height: 12),
                    _buildAutonomy(evaluations),
                    const SizedBox(height: 12),
                    _buildEfficiency(evaluations),
                    const SizedBox(height: 12),
                    _buildSupervisionStyle(evaluations),
                    const SizedBox(height: 12),
                    _buildEaseOfCommunication(evaluations),
                    const SizedBox(height: 12),
                    _buildAbsenceAcceptance(evaluations),
                    const SizedBox(height: 12),
                    Text(
                      'Évaluation de l\'accueil de stagiaires avec',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall!
                          .copyWith(fontWeight: FontWeight.bold),
                    ),
                    _buildAcceptanceTsa(evaluations),
                    _buildAcceptanceLanguageDeficiency(evaluations),
                    _buildAcceptanceMentalDeficiency(evaluations),
                    _buildAcceptancePhysicalDeficiency(evaluations),
                    _buildAcceptanceMentalHealtyIssue(evaluations),
                    _buildAcceptanceBehaviorIssue(evaluations),
                    _buildComments(context, evaluations),
                    const SizedBox(height: 12),
                  ],
                )
              ],
            ),
    );
  }

  Widget _buildAcceptanceTsa(
      List<PostIntershipEnterpriseEvaluation> evaluations) {
    return _RatingBar(
      title: 'Un trouble du spectre de l\'autisme (TSA)',
      rating: _meanOf(evaluations, (e) => e.acceptanceTsa),
    );
  }

  Widget _buildAcceptanceLanguageDeficiency(
      List<PostIntershipEnterpriseEvaluation> evaluations) {
    return _RatingBar(
      title: 'Un trouble du langage',
      rating: _meanOf(evaluations, (e) => e.acceptanceLanguageDisorder),
    );
  }

  Widget _buildAcceptanceMentalDeficiency(
      List<PostIntershipEnterpriseEvaluation> evaluations) {
    return _RatingBar(
      title: 'Une déficience intellectuelle',
      rating: _meanOf(evaluations, (e) => e.acceptanceIntellectualDisability),
    );
  }

  Widget _buildAcceptancePhysicalDeficiency(
      List<PostIntershipEnterpriseEvaluation> evaluations) {
    return _RatingBar(
      title: 'Une déficience physique',
      rating: _meanOf(evaluations, (e) => e.acceptancePhysicalDisability),
    );
  }

  Widget _buildAcceptanceMentalHealtyIssue(
      List<PostIntershipEnterpriseEvaluation> evaluations) {
    return _RatingBar(
      title: 'Un trouble de santé mentale',
      rating: _meanOf(evaluations, (e) => e.acceptanceMentalHealthDisorder),
    );
  }

  Widget _buildAcceptanceBehaviorIssue(
      List<PostIntershipEnterpriseEvaluation> evaluations) {
    return _RatingBar(
      title: 'Des difficultés comportementales',
      rating: _meanOf(evaluations, (e) => e.acceptanceBehaviorDifficulties),
    );
  }

  Widget _buildComments(
      context, List<PostIntershipEnterpriseEvaluation> evaluations) {
    final comments = evaluations
        .map((e) => e.supervisionComments)
        .where((e) => e != '')
        .toList();
    return comments.isEmpty
        ? Container()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Autres commentaires sur l\'encadrement',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              ItemizedText(comments),
            ],
          );
  }

  Widget _buildTaskVariety(BuildContext context, evaluations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tâches données à l\'élève',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        _printCountedList<PostIntershipEnterpriseEvaluation>(evaluations,
            (e) => e.taskVariety == 0 ? 'Peu variées' : 'Très variées'),
      ],
    );
  }

  Widget _buildTrainingPlanRespect(BuildContext context, evaluations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tâches et compétences prévues dans le plan ont été faites par l\'élève',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        _printCountedList<PostIntershipEnterpriseEvaluation>(evaluations,
            (e) => e.trainingPlanRespect == 0 ? 'En partie' : 'En totalité'),
      ],
    );
  }

  Widget _buildAutonomy(evaluations) {
    return _TitledFixSlider(
        title: 'Niveau d\'autonomie souhaité',
        value: _meanOf(evaluations, (e) => e.autonomyExpected));
  }

  Widget _buildEfficiency(evaluations) {
    return _TitledFixSlider(
        title: 'Rendement de l\'élève attendu',
        value: _meanOf(evaluations, (e) => e.efficiencyExpected));
  }

  Widget _buildSupervisionStyle(evaluations) {
    return _TitledFixSlider(
        title: 'Type d\'encadrement',
        value: _meanOf(evaluations, (e) => e.supervisionStyle));
  }

  Widget _buildEaseOfCommunication(evaluations) {
    return _TitledFixSlider(
        title: 'Communication avec l\'entreprise',
        value: _meanOf(evaluations, (e) => e.easeOfCommunication));
  }

  Widget _buildAbsenceAcceptance(evaluations) {
    return _TitledFixSlider(
        title:
            'Tolérance du milieu à l\'égard des retards et absences de l\'élève',
        value: _meanOf(evaluations, (e) => e.absenceAcceptance));
  }
}

class _TitledFixSlider extends StatelessWidget {
  const _TitledFixSlider({
    required this.title,
    required this.value,
  });

  final String title;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleSmall),
        LowHighSliderFormField(
          initialValue: value,
          decimal: 1,
          fixed: true,
        ),
      ],
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
    return rating < 0 || rating > 5
        ? Container()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              RatingBar(
                initialRating: rating,
                onRatingUpdate: (value) {},
                allowHalfRating: true,
                ignoreGestures: true,
                ratingWidget: RatingWidget(
                  full: Icon(
                    Icons.star,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  half: Icon(
                    Icons.star_half,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  empty: Icon(
                    Icons.star_border,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          );
  }
}
