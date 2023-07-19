import 'package:flutter/material.dart';

import 'question_with_text.dart';

class QuestionWithCheckboxList extends StatefulWidget {
  const QuestionWithCheckboxList({
    this.visible = true,
    required this.choicesQuestion,
    required this.choices,
    this.initialChoices,
    this.onSavedChoices,
    this.textQuestion,
    this.initialText,
    this.onSavedText,
    super.key,
  });

  final bool visible;

  final String choicesQuestion;
  final Set<String> choices;
  final Set<String>? initialChoices;
  final void Function(Set<String>? choices)? onSavedChoices;

  final String? textQuestion;
  final String? initialText;
  final void Function(String? text)? onSavedText;

  @override
  State<QuestionWithCheckboxList> createState() =>
      _QuestionWithCheckboxListState();
}

class _QuestionWithCheckboxListState extends State<QuestionWithCheckboxList> {
  late final _fillColor =
      MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
    if (states.contains(MaterialState.disabled)) {
      return Theme.of(context).primaryColor.withOpacity(.32);
    }
    return Theme.of(context).primaryColor;
  });

  @override
  void initState() {
    super.initState();

    _initializeChoices();
  }

  void _initializeChoices() {
    for (final choice in widget.initialChoices ?? {}) {
      if (choice == _doesNotApplyLabel) {
        _isDoesNotApplyChecked = true;
      } else if (!widget.choices.contains(choice)) {
        _isOtherChecked = true;
        _otherController.text = choice;
      } else {
        _choices[choice] = true;
      }
    }
  }

  late final Map<String, bool> _choices =
      Map.fromIterable(widget.choices, value: (_) => false);

  final String _doesNotApplyLabel = 'Ne s\'applique pas';
  bool _isDoesNotApplyChecked = false;

  bool _isOtherChecked = false;
  final _otherController = TextEditingController();

  void _updateChoice(
      FormFieldState<Set<String>> state, String choice, bool? value) {
    // If user checked 'Does not apply' remove everything
    if (choice == _doesNotApplyLabel) {
      _isDoesNotApplyChecked = value!;
      if (value) {
        for (final key in _choices.keys) {
          _choices[key] = false;
        }
        _isOtherChecked = false;
        _otherController.text = '';
      }
    }
    _choices[choice] = value!;

    _setValue(state);
    setState(() {});
  }

  void _setValue(FormFieldState<Set<String>> state) {
    // Rebuild the state.value
    state.value!.clear();
    state.value!.addAll(_choices.keys.where((key) => _choices[key]!));
    if (_isOtherChecked && _otherController.text != '') {
      state.value!.add(_otherController.text);
    }
  }

  bool _canClick(String choice) {
    // If the choice is 'doesNotApply', then always allow to click
    if (choice == _doesNotApplyLabel) return true;

    // Otherwise, only allow if 'doesNotApply' is false
    return !_isDoesNotApplyChecked;
  }

  void _activateOther(bool? value, FormFieldState<Set<String>> state) {
    if (!value!) {
      _otherController.text = '';
    }
    _isOtherChecked = value;

    _setValue(state);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: widget.visible,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.choicesQuestion,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            FormField<Set<String>>(
              onSaved: (value) => widget.onSavedChoices!(value),
              initialValue: widget.initialChoices ?? {},
              builder: (state) => Column(
                children: [
                  ...widget.choices.map(
                    (choice) {
                      final canClick = _canClick(choice);
                      return InkWell(
                        onTap: canClick
                            ? () =>
                                _updateChoice(state, choice, !_choices[choice]!)
                            : null,
                        child: Row(
                          children: [
                            Checkbox(
                              value: state.value!.contains(choice),
                              onChanged: canClick
                                  ? (value) =>
                                      _updateChoice(state, choice, value)
                                  : null,
                              fillColor: _fillColor,
                            ),
                            Text(choice),
                          ],
                        ),
                      );
                    },
                  ),
                  InkWell(
                    onTap: _isDoesNotApplyChecked
                        ? null
                        : () => _activateOther(!_isOtherChecked, state),
                    child: ListTile(
                      leading: Checkbox(
                        visualDensity: VisualDensity.compact,
                        value: _isOtherChecked,
                        onChanged: _isDoesNotApplyChecked
                            ? null
                            : (value) => _activateOther(value, state),
                        fillColor: _fillColor,
                      ),
                      title: Theme(
                        data: Theme.of(context)
                            .copyWith(disabledColor: Colors.grey),
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'Autre\u00a0:',
                          ),
                          enabled: _isOtherChecked,
                          controller: _otherController,
                          onChanged: (value) => _setValue(state),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            QuestionWithText(
              visible: _choices.values.any((c) => c == true) ||
                  (_isOtherChecked && _otherController.text.isNotEmpty),
              question: widget.textQuestion ?? '',
              onSaved: widget.onSavedText,
              initialValue: widget.initialText ?? '',
            ),
          ],
        ),
      ),
    );
  }
}
