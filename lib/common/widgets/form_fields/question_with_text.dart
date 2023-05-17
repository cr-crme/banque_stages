import 'package:flutter/material.dart';

class QuestionWithText extends StatelessWidget {
  const QuestionWithText({
    this.visible = true,
    required this.question,
    this.initialValue = '',
    this.onSaved,
    this.validator,
    super.key,
  });

  final bool visible;

  final String question;
  final String initialValue;
  final void Function(String? text)? onSaved;
  final String? Function(String? text)? validator;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: visible && question.isNotEmpty,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            TextFormField(
              initialValue: initialValue,
              onSaved: onSaved,
              validator: validator,
              minLines: 2,
              maxLines: 10,
            ),
          ],
        ),
      ),
    );
  }
}
