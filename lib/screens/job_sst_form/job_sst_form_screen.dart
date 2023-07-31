import 'package:crcrme_banque_stages/common/models/enterprise.dart';
import 'package:crcrme_banque_stages/common/models/job.dart';
import 'package:crcrme_banque_stages/common/providers/enterprises_provider.dart';
import 'package:crcrme_banque_stages/common/widgets/dialogs/confirm_pop_dialog.dart';
import 'package:crcrme_banque_stages/common/widgets/form_fields/checkbox_with_other.dart';
import 'package:crcrme_banque_stages/common/widgets/form_fields/radio_with_child_subquestion.dart';
import 'package:crcrme_banque_stages/common/widgets/form_fields/text_with_form.dart';
import 'package:crcrme_banque_stages/common/widgets/sub_title.dart';
import 'package:crcrme_banque_stages/misc/form_service.dart';
import 'package:crcrme_banque_stages/misc/question_file_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class JobSstFormScreen extends StatefulWidget {
  const JobSstFormScreen({
    super.key,
    required this.enterpriseId,
    required this.jobId,
  });

  final String enterpriseId;
  final String jobId;

  @override
  State<JobSstFormScreen> createState() => _JobSstFormScreenState();
}

class _JobSstFormScreenState extends State<JobSstFormScreen> {
  final _questionsKey = GlobalKey<_QuestionsStepState>();

  void _submit() {
    if (!FormService.validateForm(_questionsKey.currentState!.formKey)) {
      setState(() {});
      return;
    }

    _questionsKey.currentState!.formKey.currentState!.save();

    final enterprises = context.read<EnterprisesProvider>();
    enterprises[widget.enterpriseId]
        .jobs[widget.jobId]
        .sstEvaluation
        .update(questions: _questionsKey.currentState!.answer);

    enterprises.replaceJob(widget.enterpriseId,
        enterprises[widget.enterpriseId].jobs[widget.jobId]);

    Navigator.pop(context);
  }

  void _cancel() async {
    final answer = await ConfirmPopDialog.show(context);
    if (!answer || !mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final enterprise =
        EnterprisesProvider.of(context).fromId(widget.enterpriseId);

    return Scaffold(
      appBar: AppBar(
          title: const Text('La SST en stage'),
          leading: IconButton(
              onPressed: _cancel, icon: const Icon(Icons.arrow_back))),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              QuestionsStep(
                key: _questionsKey,
                enterprise: enterprise,
                job: enterprise.jobs[widget.jobId],
              ),
              _controlBuilder(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _controlBuilder() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton(onPressed: _cancel, child: const Text('Annuler')),
          const SizedBox(
            width: 20,
          ),
          TextButton(
            onPressed: _submit,
            child: const Text('Confirmer'),
          )
        ],
      ),
    );
  }
}

class QuestionsStep extends StatefulWidget {
  const QuestionsStep({
    super.key,
    required this.enterprise,
    required this.job,
  });

  final Enterprise enterprise;
  final Job job;

  @override
  State<QuestionsStep> createState() => _QuestionsStepState();
}

class _QuestionsStepState extends State<QuestionsStep> {
  final Map<String, TextEditingController> _followUpController = {};

  final formKey = GlobalKey<FormState>();

  bool isProfessor = true;

  Map<String, dynamic> answer = {};

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          _buildHeader(),
          _buildQuestions(),
        ],
      ),
    );
  }

  Widget _buildQuestions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SubTitle('Questions', left: 0),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.job.specialization.questions.length,
          itemBuilder: (context, index) {
            String id = widget.job.specialization.questions.elementAt(index);
            final question = QuestionFileService.fromId(id);

            // Fill the initial answer
            answer[question.id] =
                widget.job.sstEvaluation.questions[question.id];
            answer['${question.id}+t'] =
                widget.job.sstEvaluation.questions['${question.id}+t'];

            switch (question.type) {
              case Type.radio:
                return Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: RadioWithChildSubquestion(
                    title: '${index + 1}. ${question.title}',
                    initialValue:
                        widget.job.sstEvaluation.questions[question.id],
                    elements: question.choices.toList(),
                    elementsThatShowChild: [question.choices.first],
                    onChanged: (value) {
                      answer[question.id] = value.toString();
                      _followUpController['${question.id}+t']!.text = '';
                      if (question.choices.first != value) {
                        answer['${question.id}+t'] = null;
                      }
                    },
                    childSubquestion: question.subquestion == null
                        ? null
                        : _buildFollowUpQuestion(question, context),
                  ),
                );

              case Type.checkbox:
                return Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: CheckboxWithOther(
                    title: '${index + 1}. ${question.title}',
                    elements: question.choices.toList(),
                    hasNotApplicableOption: true,
                    initialValues: (widget
                            .job.sstEvaluation.questions[question.id] as List?)
                        ?.map((e) => e as String)
                        .toList(),
                    onOptionWasSelected: (values) {
                      answer[question.id] = values;
                      if (!question.choices.any((q) => values.contains(q))) {
                        answer['${question.id}+t'] = null;
                        _followUpController['${question.id}+t']!.text = '';
                      }
                    },
                    childSubquestion: question.subquestion == null
                        ? null
                        : _buildFollowUpQuestion(question, context),
                  ),
                );

              case Type.text:
                return Padding(
                  padding: const EdgeInsets.only(bottom: 36.0),
                  child: TextWithForm(
                    title: '${index + 1}. ${question.title}',
                    initialValue:
                        widget.job.sstEvaluation.questions[question.id] ?? '',
                    onChanged: (text) => answer[question.id] = text,
                  ),
                );
            }
          },
        ),
      ],
    );
  }

  Padding _buildFollowUpQuestion(Question question, BuildContext context) {
    _followUpController['${question.id}+t'] = TextEditingController(
        text: widget.job.sstEvaluation.questions['${question.id}+t'] ?? '');
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextWithForm(
        controller: _followUpController['${question.id}+t'],
        title: question.subquestion!,
        titleStyle: Theme.of(context).textTheme.bodyMedium,
        onChanged: (text) => answer['${question.id}+t'] = text,
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SubTitle('Informations générales', top: 0, left: 0),
        TextField(
          decoration: const InputDecoration(
              labelText: 'Nom de l\'entreprise', border: InputBorder.none),
          controller: TextEditingController(text: widget.enterprise.name),
          enabled: false,
        ),
        TextField(
          decoration: const InputDecoration(
              labelText: 'Métier semi-spécialisé', border: InputBorder.none),
          controller:
              TextEditingController(text: widget.job.specialization.name),
          enabled: false,
        ),
      ],
    );
  }
}
