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

  double welcomingTSA = -1;
  double welcomingCommunication = -1;
  double welcomingMentalDeficiency = -1;
  double welcomingMentalHealthIssue = -1;

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
            _RatingBar(
              question:
                  '* Est-ce que le ou la stagiaire avait un trouble du spectre de l\'autisme (TSA) ?',
              initialValue: welcomingTSA,
              validator: (value) =>
                  value == 0 ? 'Sélectionner une valeur' : null,
              onSaved: (newValue) => welcomingTSA = newValue!,
            ),
            const SizedBox(height: 8),
            _RatingBar(
              question:
                  '* Est-ce que le ou la stagiaire avait un trouble du langage?',
              initialValue: welcomingCommunication,
              validator: (value) =>
                  value == 0 ? 'Sélectionner une valeur' : null,
              onSaved: (newValue) => welcomingCommunication = newValue!,
            ),
            const SizedBox(height: 8),
            _RatingBar(
              question:
                  '* Est-ce que le ou la stagiaire avait une déficience intellectuelle ?',
              initialValue: welcomingMentalDeficiency,
              validator: (value) =>
                  value == 0 ? 'Sélectionner une valeur' : null,
              onSaved: (newValue) => welcomingMentalDeficiency = newValue!,
            ),
            const SizedBox(height: 8),
            _RatingBar(
              question:
                  '* Est-ce que le ou la stagiaire avait un trouble de santé mentale ?',
              initialValue: welcomingMentalHealthIssue,
              validator: (value) =>
                  value == 0 ? 'Sélectionner une valeur' : null,
              onSaved: (newValue) => welcomingMentalHealthIssue = newValue!,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _RatingBar extends FormField<double> {
  const _RatingBar({
    required this.question,
    required super.initialValue,
    required super.validator,
    required void Function(double? rating) onSaved,
  }) : super(onSaved: onSaved, builder: _builder);

  final String question;

  static Widget _builder(FormFieldState<double> state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          (state.widget as _RatingBar).question,
          style: Theme.of(state.context).textTheme.bodyLarge,
        ),
        Row(
          children: [
            Radio(
              value: true,
              groupValue: state.value! >= 0,
              onChanged: (_) => state.didChange(0),
            ),
            const Text('Oui'),
            const SizedBox(width: 32),
            Radio(
              value: false,
              groupValue: state.value! >= 0,
              onChanged: (_) => state.didChange(-1),
            ),
            const Text('Non'),
          ],
        ),
        Visibility(
          visible: state.value! >= 0.0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: RatingBar(
              initialRating: state.value! < 0 ? 0.0 : state.value!,
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
              onRatingUpdate: (double value) => state.didChange(value),
            ),
          ),
        ),
      ],
    );
  }
}
