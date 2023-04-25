import 'package:flutter/material.dart';

import 'list_tile_radio.dart';
import 'question_with_text.dart';

class QuestionWithRadioBool extends StatefulWidget {
  const QuestionWithRadioBool({
    this.visible = true,
    this.textTrue,
    this.textFalse,
    required this.choiceQuestion,
    this.initialChoice,
    this.onSavedChoice,
    this.textQuestion,
    this.initialText,
    this.onSavedText,
    super.key,
  });

  final bool visible;
  final String? textTrue;
  final String? textFalse;

  final String choiceQuestion;
  final bool? initialChoice;
  final void Function(bool? choice)? onSavedChoice;

  final String? textQuestion;
  final String? initialText;
  final void Function(String? text)? onSavedText;

  @override
  State<QuestionWithRadioBool> createState() => _QuestionWithRadioBoolState();
}

class _QuestionWithRadioBoolState extends State<QuestionWithRadioBool> {
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
              widget.choiceQuestion,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            FormField<bool?>(
              onSaved: (value) {
                if (widget.onSavedChoice != null) widget.onSavedChoice!(value);
                if (widget.onSavedText != null && value != true) {
                  widget.onSavedText!('');
                }
              },
              initialValue: widget.initialChoice,
              builder: (state) => Column(
                children: [
                  ListTileRadio<bool?>(
                    titleLabel: widget.textTrue ?? 'Oui',
                    value: true,
                    groupValue: state.value,
                    onChanged: state.didChange,
                  ),
                  ListTileRadio<bool?>(
                    titleLabel: widget.textFalse ?? 'Non',
                    value: false,
                    groupValue: state.value,
                    onChanged: state.didChange,
                  ),
                  ListTileRadio<bool?>(
                    titleLabel: 'Non applicable',
                    value: null,
                    groupValue: state.value,
                    onChanged: state.didChange,
                  ),
                  QuestionWithText(
                    visible: state.value == true && widget.textQuestion != null,
                    question: widget.textQuestion ?? '',
                    onSaved: widget.onSavedText,
                    initialValue: widget.initialText ?? '',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
