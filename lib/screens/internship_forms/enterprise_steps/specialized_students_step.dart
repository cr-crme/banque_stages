import 'package:crcrme_banque_stages/common/widgets/form_fields/checkbox_with_other.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

enum _Disabilities {
  autismSpectrumDisorder,
  languageDisorder,
  intellectualDisability,
  physicalDisability,
  mentalHealthDisorder,
  behavioralDifficulties;

  @override
  String toString() {
    switch (this) {
      case _Disabilities.autismSpectrumDisorder:
        return 'Un trouble du spectre de l\'autisme (TSA)';
      case _Disabilities.languageDisorder:
        return 'Un trouble du langage';
      case _Disabilities.intellectualDisability:
        return 'Une déficience intellectuelle';
      case _Disabilities.physicalDisability:
        return 'Une déficience physique';
      case _Disabilities.mentalHealthDisorder:
        return 'Un trouble de santé mentale';
      case _Disabilities.behavioralDifficulties:
        return 'Des difficultés comportementales';
    }
  }
}

class SpecializedStudentsStep extends StatefulWidget {
  const SpecializedStudentsStep({super.key});

  @override
  State<SpecializedStudentsStep> createState() =>
      SpecializedStudentsStepState();
}

class SpecializedStudentsStepState extends State<SpecializedStudentsStep> {
  final _formKey = GlobalKey<FormState>();
  final _hasDisabilitiesKey =
      GlobalKey<CheckboxWithOtherState<_Disabilities>>();

  bool _hasStudentHadDisabilities = false;
  List<_Disabilities> _disabilities = [];

  double _acceptanceTsa = -1;
  double get acceptanceTsa =>
      _disabilities.contains(_Disabilities.autismSpectrumDisorder)
          ? _acceptanceTsa
          : -1;

  double _acceptanceLanguageDisorder = -1;
  double get acceptanceLanguageDisorder =>
      _disabilities.contains(_Disabilities.languageDisorder)
          ? _acceptanceLanguageDisorder
          : -1;

  double _acceptanceIntellectualDisability = -1;
  double get acceptanceIntellectualDisability =>
      _disabilities.contains(_Disabilities.intellectualDisability)
          ? _acceptanceIntellectualDisability
          : -1;

  double _acceptancePhysicalDisability = -1;
  double get acceptancePhysicalDisability =>
      _disabilities.contains(_Disabilities.physicalDisability)
          ? _acceptancePhysicalDisability
          : -1;

  double _acceptanceMentalHealthDisorder = -1;
  double get acceptanceMentalHealthDisorder =>
      _disabilities.contains(_Disabilities.mentalHealthDisorder)
          ? _acceptanceMentalHealthDisorder
          : -1;

  double _acceptanceBehaviorDifficulties = -1;
  double get acceptanceBehaviorDifficulties =>
      _disabilities.contains(_Disabilities.behavioralDifficulties)
          ? _acceptanceBehaviorDifficulties
          : -1;

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
            _YesOrNoRadioTile(
              title: '* Est-ce que le ou la stagiaire avait des besoins '
                  'particuliers\u00a0?',
              value: _hasStudentHadDisabilities,
              onChanged: (value) =>
                  setState(() => _hasStudentHadDisabilities = value),
            ),
            if (_hasStudentHadDisabilities)
              CheckboxWithOther(
                key: _hasDisabilitiesKey,
                title: '* Est-ce que le ou la stagiaire avait\u00a0:',
                titleStyle: Theme.of(context).textTheme.titleSmall,
                elements: _Disabilities.values,
                showOtherOption: false,
                onOptionWasSelected: (value) => setState(() =>
                    _disabilities = _hasDisabilitiesKey.currentState!.selected),
              ),
            if (_disabilities.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4.0, bottom: 8.0),
                child: Text(
                    '* Évaluer la prise en charge de l\'élève par '
                    'l\'entreprise par rapport à\u00a0:',
                    style: Theme.of(context).textTheme.titleSmall),
              ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_disabilities
                    .contains(_Disabilities.autismSpectrumDisorder))
                  _RatingBarForm(
                    key: const Key('acceptanceTSA'),
                    title: 'Son trouble du spectre de l\'autisme (TSA)\u00a0?',
                    initialValue: _acceptanceTsa,
                    validator: (value) =>
                        value! <= 0 ? 'Sélectionner une valeur' : null,
                    onRatingChanged: (newValue) => _acceptanceTsa = newValue!,
                  ),
                if (_disabilities.contains(_Disabilities.languageDisorder))
                  _RatingBarForm(
                    key: const Key('acceptanceLanguageDisorder'),
                    title: 'Son trouble du langage\u00a0?',
                    initialValue: _acceptanceLanguageDisorder,
                    validator: (value) =>
                        value! <= 0 ? 'Sélectionner une valeur' : null,
                    onRatingChanged: (newValue) =>
                        _acceptanceLanguageDisorder = newValue!,
                  ),
                if (_disabilities
                    .contains(_Disabilities.intellectualDisability))
                  _RatingBarForm(
                    key: const Key('acceptanceIntellectualDisability'),
                    title: 'Sa déficience intellectuelle\u00a0?',
                    initialValue: _acceptanceIntellectualDisability,
                    validator: (value) =>
                        value! <= 0 ? 'Sélectionner une valeur' : null,
                    onRatingChanged: (newValue) =>
                        _acceptanceIntellectualDisability = newValue!,
                  ),
                if (_disabilities.contains(_Disabilities.physicalDisability))
                  _RatingBarForm(
                    key: const Key('acceptancePhysicalDisability'),
                    title: 'Sa déficience physique\u00a0?',
                    initialValue: _acceptancePhysicalDisability,
                    validator: (value) =>
                        value! <= 0 ? 'Sélectionner une valeur' : null,
                    onRatingChanged: (newValue) =>
                        _acceptancePhysicalDisability = newValue!,
                  ),
                if (_disabilities.contains(_Disabilities.mentalHealthDisorder))
                  _RatingBarForm(
                    key: const Key('acceptanceMentalHealthDisorder'),
                    title: 'Son trouble de santé mentale\u00a0?',
                    initialValue: _acceptanceMentalHealthDisorder,
                    validator: (value) =>
                        value! <= 0 ? 'Sélectionner une valeur' : null,
                    onRatingChanged: (newValue) =>
                        _acceptanceMentalHealthDisorder = newValue!,
                  ),
                if (_disabilities
                    .contains(_Disabilities.behavioralDifficulties))
                  _RatingBarForm(
                    key: const Key('_acceptanceBehaviorDifficulties'),
                    title: 'Ses difficultés comportementales\u00a0?',
                    initialValue: _acceptanceBehaviorDifficulties,
                    validator: (value) =>
                        value! <= 0 ? 'Sélectionner une valeur' : null,
                    onRatingChanged: (newValue) =>
                        _acceptanceBehaviorDifficulties = newValue!,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _YesOrNoRadioTile extends StatelessWidget {
  const _YesOrNoRadioTile(
      {required this.title, required this.value, required this.onChanged});

  final String title;
  final bool value;
  final Function(bool) onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        Row(
          children: [
            SizedBox(
              width: 150,
              child: RadioListTile(
                  title: Text(
                    'Oui',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  value: true,
                  groupValue: value,
                  onChanged: (_) => onChanged(true)),
            ),
            SizedBox(
              width: 150,
              child: RadioListTile(
                  title: Text(
                    'Non',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  value: false,
                  groupValue: value,
                  onChanged: (_) => onChanged(false)),
            ),
          ],
        ),
      ],
    );
  }
}

class _RatingBarForm extends FormField<double> {
  const _RatingBarForm({
    super.key,
    required this.title,
    super.initialValue = -1,
    super.validator,
    required void Function(double? rating) onRatingChanged,
  }) : super(onSaved: onRatingChanged, builder: _builder);

  final String title;

  static Widget _builder(FormFieldState<double> state) {
    final title = (state.widget as _RatingBarForm).title;
    final onRatingChanged = state.widget.onSaved!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title),
          Padding(
            padding: const EdgeInsets.only(left: 12.0, top: 4.0),
            child: RatingBar(
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
          ),
        ],
      ),
    );
  }
}
