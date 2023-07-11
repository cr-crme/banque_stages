import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class SpecializedStudentsStep extends StatefulWidget {
  const SpecializedStudentsStep({super.key});

  @override
  State<SpecializedStudentsStep> createState() =>
      SpecializedStudentsStepState();
}

class SpecializedStudentsStepState extends State<SpecializedStudentsStep> {
  final _formKey = GlobalKey<FormState>();

  bool _hasSpecializedStudent = false;

  double _acceptanceTSA = -1;
  double get acceptanceTsa => !_hasSpecializedStudent ? -1 : _acceptanceTSA;

  double _acceptanceLanguageDeficiency = -1;
  double get acceptanceLanguageDeficiency =>
      !_hasSpecializedStudent ? -1 : _acceptanceLanguageDeficiency;

  double _acceptanceMentalDeficiency = -1;
  double get acceptanceMentalDeficiency =>
      !_hasSpecializedStudent ? -1 : _acceptanceMentalDeficiency;

  double _acceptancePhysicalDeficiency = -1;
  double get acceptancePhysicalDeficiency =>
      !_hasSpecializedStudent ? -1 : _acceptancePhysicalDeficiency;

  double _acceptanceMentalHealthIssue = -1;
  double get acceptanceMentalHealthIssue =>
      !_hasSpecializedStudent ? -1 : _acceptanceMentalHealthIssue;

  double _acceptanceBehaviorIssue = -1;
  double get acceptanceBehaviorIssue =>
      !_hasSpecializedStudent ? -1 : _acceptanceBehaviorIssue;

  Future<String?> validate() async {
    if (!_formKey.currentState!.validate()) {
      return 'Remplir tous les champs avec un *.';
    }
    _formKey.currentState!.save();
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _RadioWithRatingBar(
              question:
                  '* Est-ce que le ou la stagiaire avait des besoins particuliers?',
              onRadioChanged: (value) =>
                  setState(() => _hasSpecializedStudent = value!),
            ),
            if (_hasSpecializedStudent)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  _RadioWithRatingBar(
                    question: '*Un trouble du spectre de l\'autisme (TSA) ?',
                    initialValue: _acceptanceTSA,
                    validator: (value) =>
                        value == 0 ? 'Sélectionner une valeur' : null,
                    onRatingChanged: (newValue) => _acceptanceTSA = newValue!,
                  ),
                  const SizedBox(height: 8),
                  _RadioWithRatingBar(
                    question: '* Un trouble du langage?',
                    initialValue: _acceptanceLanguageDeficiency,
                    validator: (value) =>
                        value == 0 ? 'Sélectionner une valeur' : null,
                    onRatingChanged: (newValue) =>
                        _acceptanceLanguageDeficiency = newValue!,
                  ),
                  const SizedBox(height: 8),
                  _RadioWithRatingBar(
                    question: '* Une déficience intellectuelle ?',
                    initialValue: _acceptanceMentalDeficiency,
                    validator: (value) =>
                        value == 0 ? 'Sélectionner une valeur' : null,
                    onRatingChanged: (newValue) =>
                        _acceptanceMentalDeficiency = newValue!,
                  ),
                  const SizedBox(height: 8),
                  _RadioWithRatingBar(
                    question: '* Une déficience physique ?',
                    initialValue: _acceptancePhysicalDeficiency,
                    validator: (value) =>
                        value == 0 ? 'Sélectionner une valeur' : null,
                    onRatingChanged: (newValue) =>
                        _acceptancePhysicalDeficiency = newValue!,
                  ),
                  const SizedBox(height: 8),
                  _RadioWithRatingBar(
                    question: '* Un trouble de santé mentale ?',
                    initialValue: _acceptanceMentalHealthIssue,
                    validator: (value) =>
                        value == 0 ? 'Sélectionner une valeur' : null,
                    onRatingChanged: (newValue) =>
                        _acceptanceMentalHealthIssue = newValue!,
                  ),
                  const SizedBox(height: 8),
                  _RadioWithRatingBar(
                    question: '* Des difficultés comportementales ?',
                    initialValue: _acceptanceBehaviorIssue,
                    validator: (value) =>
                        value == 0 ? 'Sélectionner une valeur' : null,
                    onRatingChanged: (newValue) =>
                        _acceptanceBehaviorIssue = newValue!,
                  ),
                  const SizedBox(height: 8),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _RadioWithRatingBar extends FormField<double> {
  const _RadioWithRatingBar({
    required this.question,
    super.initialValue = -1,
    super.validator,
    this.onRadioChanged,
    void Function(double? rating)? onRatingChanged,
  }) : super(onSaved: onRatingChanged, builder: _builder);

  final String question;
  final void Function(bool? value)? onRadioChanged;

  static Widget _builder(FormFieldState<double> state) {
    final onRadioChanged = (state.widget as _RadioWithRatingBar).onRadioChanged;
    final onRatingChanged = state.widget.onSaved;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          (state.widget as _RadioWithRatingBar).question,
          style: Theme.of(state.context).textTheme.bodyLarge,
        ),
        Row(
          children: [
            SizedBox(
              width: 150,
              child: RadioListTile(
                title: const Text('Oui'),
                dense: true,
                visualDensity: VisualDensity.compact,
                value: true,
                groupValue: state.value! >= 0,
                onChanged: (_) {
                  state.didChange(0);
                  if (onRadioChanged != null) onRadioChanged(true);
                },
              ),
            ),
            SizedBox(
              width: 150,
              child: RadioListTile(
                title: const Text('Non'),
                dense: true,
                visualDensity: VisualDensity.compact,
                value: false,
                groupValue: state.value! >= 0,
                onChanged: (_) {
                  state.didChange(-1);
                  if (onRadioChanged != null) onRadioChanged(false);
                },
              ),
            ),
          ],
        ),
        if (onRatingChanged != null)
          Visibility(
            visible: state.value! >= 0.0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Évaluer sa prise en charge de l\'entreprise'),
                  RatingBar(
                    initialRating: state.value!,
                    ratingWidget: RatingWidget(
                      full: Icon(
                        Icons.star,
                        color: Theme.of(state.context).colorScheme.secondary,
                      ),
                      half: Icon(
                        Icons.star_half,
                        color: Theme.of(state.context).colorScheme.secondary,
                      ),
                      empty: Icon(
                        Icons.star_border,
                        color: Theme.of(state.context).colorScheme.secondary,
                      ),
                    ),
                    onRatingUpdate: (double value) {
                      state.didChange(value);
                      onRatingChanged(value);
                    },
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
