import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '/common/models/job.dart';

class SupervisionStep extends StatefulWidget {
  const SupervisionStep({
    Key? key,
    required this.job,
  }) : super(key: key);

  final Job job;

  @override
  State<SupervisionStep> createState() => SupervisionStepState();
}

class SupervisionStepState extends State<SupervisionStep> {
  final _formKey = GlobalKey<FormState>();

  double? _welcomingTSA;
  double? _welcomingCommunication;
  double? _welcomingMentalDeficiency;
  double? _welcomingMentalHealthIssue;

  bool validate() {
    return _formKey.currentState!.validate();
  }

  void save() {
    _formKey.currentState!.save();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            _RatingBar(
              question: "* L'élève placé en stage était-il TSA ?",
              onSaved: (newValue) => _welcomingTSA = newValue,
            ),
            const SizedBox(height: 8),
            _RatingBar(
              question:
                  "* L'élève placé en stage était-il dans une de classe communication ?",
              onSaved: (newValue) => _welcomingCommunication = newValue,
            ),
            const SizedBox(height: 8),
            _RatingBar(
              question:
                  "* L'élève placé en stage avait-il une déficience intellectuelle ?",
              onSaved: (newValue) => _welcomingMentalDeficiency = newValue,
            ),
            const SizedBox(height: 8),
            _RatingBar(
              question:
                  "* L'élève placé en stage avait-il un trouble de santé mentale ?",
              onSaved: (newValue) => _welcomingMentalHealthIssue = newValue,
            ),
          ],
        ),
      ),
    );
  }
}

class _RatingBar extends FormField<double> {
  const _RatingBar({
    Key? key,
    required this.question,
    required void Function(double? rating) onSaved,
  }) : super(
          key: key,
          onSaved: onSaved,
          builder: _builder,
        );

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
              groupValue: state.value != null,
              onChanged: (_) => state.didChange(0),
            ),
            const Text("Oui"),
            const SizedBox(width: 32),
            Radio(
              value: false,
              groupValue: state.value != null,
              onChanged: (_) => state.didChange(null),
            ),
            const Text("Non"),
          ],
        ),
        Visibility(
          visible: state.value != null,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: RatingBar(
              initialRating: state.value ?? 0,
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
