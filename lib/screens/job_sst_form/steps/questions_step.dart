import 'package:crcrme_banque_stages/common/models/job.dart';
import 'package:crcrme_banque_stages/common/widgets/form_fields/checkbox_with_other.dart';
import 'package:crcrme_banque_stages/common/widgets/form_fields/radio_with_child_subquestion.dart';
import 'package:crcrme_banque_stages/common/widgets/form_fields/text_with_form.dart';
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
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: RadioWithChildSubquestion(
                        title: '${index + 1}. ${question.title}',
                        elements: question.choices.toList(),
                        elementsThatShowChild: [question.choices.first],
                        childSubquestion: question.subquestion == null
                            ? null
                            : Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: TextWithForm(
                                  title: question.subquestion!,
                                  initialValue: widget.job.sstEvaluation
                                          .questions['${question.id}+t'] ??
                                      '',
                                  onSaved: (text) =>
                                      answer['${question.id}+t'] = text,
                                ),
                              ),
                      ),
                    );

                  case Type.checkbox:
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: CheckboxWithOther(
                        title: '${index + 1}. ${question.title}',
                        elements: question.choices.toList(),
                        hasNotApplicableOption: true,
                        initialValues: (widget.job.sstEvaluation
                                .questions[question.id] as List?)
                            ?.map((e) => e as String)
                            .toList(),
                        onOptionWasSelected: (values) =>
                            answer[question.id] = values,
                        childSubquestion: question.subquestion == null
                            ? null
                            : Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: TextWithForm(
                                  title: question.subquestion!,
                                  initialValue: widget.job.sstEvaluation
                                          .questions['${question.id}+t'] ??
                                      '',
                                  onSaved: (text) =>
                                      answer['${question.id}+t'] = text,
                                ),
                              ),
                      ),
                    );

                  case Type.text:
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 36.0),
                      child: TextWithForm(
                        title: '${index + 1}. ${question.title}',
                        initialValue:
                            widget.job.sstEvaluation.questions[question.id] ??
                                '',
                        onSaved: (text) => answer[question.id] = text,
                      ),
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
