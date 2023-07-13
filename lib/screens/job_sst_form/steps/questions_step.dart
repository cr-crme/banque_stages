import 'package:collection/collection.dart';
import 'package:crcrme_banque_stages/common/models/job.dart';
import 'package:crcrme_banque_stages/common/widgets/form_fields/question_with_checkbox_list.dart';
import 'package:crcrme_banque_stages/common/widgets/form_fields/question_with_radio_bool.dart';
import 'package:crcrme_banque_stages/common/widgets/form_fields/question_with_text.dart';
import 'package:crcrme_banque_stages/misc/question_file_service.dart';
import 'package:flutter/material.dart';

class QuestionsStep extends StatefulWidget {
  const QuestionsStep({
    super.key,
    required this.job,
  });

  final Job job;

  @override
  State<QuestionsStep> createState() => QuestionsStepState();
}

class QuestionsStepState extends State<QuestionsStep> {
  final formKey = GlobalKey<FormState>();

  bool isProfessor = true;

  Map<String, dynamic> answer = {};

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.job.specialization.questions.length,
              itemBuilder: (context, index) {
                String id =
                    widget.job.specialization.questions.elementAt(index);
                final question = QuestionFileService.fromId(id);

                if (id == '21' || id == '22' || id == '23') return null;

                switch (question.type) {
                  case Type.radio:
                    return QuestionWithRadioBool(
                      initialChoice:
                          widget.job.sstEvaluation.questions[question.id],
                      initialText: widget.job.sstEvaluation
                              .questions['${question.id}+t'] ??
                          '',
                      choiceQuestion:
                          '${index + 1}. ${question.getQuestion(isProfessor)}',
                      textTrue: question.choices.firstOrNull,
                      textFalse: question.choices.lastOrNull,
                      textQuestion: question.getTextQuestion(isProfessor),
                      onSavedChoice: (choice) => answer[question.id] = choice,
                      onSavedText: (text) => answer['${question.id}+t'] = text,
                    );

                  case Type.checkbox:
                    return QuestionWithCheckboxList(
                      initialChoices: Set.from(
                          widget.job.sstEvaluation.questions[question.id] ??
                              []),
                      initialText: widget.job.sstEvaluation
                              .questions['${question.id}+t'] ??
                          '',
                      choicesQuestion:
                          '${index + 1}. ${question.getQuestion(isProfessor)}',
                      choices: question.choices,
                      textQuestion: question.getTextQuestion(isProfessor),
                      onSavedChoices: (choices) =>
                          answer[question.id] = choices?.toList(),
                      onSavedText: (text) => answer['${question.id}+t'] = text,
                    );

                  case Type.text:
                    return QuestionWithText(
                      initialValue:
                          widget.job.sstEvaluation.questions[question.id] ?? '',
                      question:
                          '${index + 1}. ${question.getQuestion(isProfessor)}',
                      onSaved: (text) => answer[question.id] = text,
                    );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
