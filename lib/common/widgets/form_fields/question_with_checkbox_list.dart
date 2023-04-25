import 'package:flutter/material.dart';

import 'list_tile_checkbox.dart';
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
  late final Map<String, bool> choices =
      Map.fromIterable(widget.choices, value: (_) => false);

  bool _choiceOther = false;
  String _textOther = '';

  void _updateChoice(
      FormFieldState<Set<String>> state, String choice, bool? value) {
    setState(() => choices[choice] = value!);
    if (value == true) {
      state.didChange(state.value!.union({choice}));
    } else {
      state.didChange(state.value!.difference({choice}));
    }
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
              onSaved: (value) {
                if (widget.onSavedChoices == null) return;
                if (_choiceOther && _textOther.isNotEmpty) {
                  widget.onSavedChoices!(value!.intersection({_textOther}));
                } else {
                  widget.onSavedChoices!(value);
                }
              },
              initialValue: widget.initialChoices ?? {},
              builder: (state) => Column(
                children: [
                  ...widget.choices.map(
                    (choice) => ListTileCheckbox(
                      titleLabel: choice,
                      value: state.value!.contains(choice),
                      onChanged: (value) => _updateChoice(state, choice, value),
                    ),
                  ),
                  InkWell(
                    onTap: () => setState(() => _choiceOther = true),
                    child: ListTile(
                      leading: Checkbox(
                        value: _choiceOther,
                        onChanged: (value) =>
                            setState(() => _choiceOther = value!),
                      ),
                      title: TextField(
                        decoration: const InputDecoration(
                          labelText: 'Autre :',
                        ),
                        enabled: _choiceOther,
                        onChanged: (text) => setState(() => _textOther = text),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            QuestionWithText(
              visible: choices.values.any((c) => c == true) ||
                  (_choiceOther && _textOther.isNotEmpty),
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
