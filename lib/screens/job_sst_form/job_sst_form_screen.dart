import 'package:crcrme_banque_stages/common/models/enterprise.dart';
import 'package:crcrme_banque_stages/common/models/job.dart';
import 'package:crcrme_banque_stages/common/providers/enterprises_provider.dart';
import 'package:crcrme_banque_stages/common/widgets/dialogs/confirm_pop_dialog.dart';
import 'package:crcrme_banque_stages/common/widgets/form_fields/checkbox_with_other.dart';
import 'package:crcrme_banque_stages/common/widgets/form_fields/radio_with_follow_up.dart';
import 'package:crcrme_banque_stages/common/widgets/form_fields/text_with_form.dart';
import 'package:crcrme_banque_stages/common/widgets/itemized_text.dart';
import 'package:crcrme_banque_stages/common/widgets/sub_title.dart';
import 'package:crcrme_banque_stages/misc/form_service.dart';
import 'package:crcrme_banque_stages/misc/question_file_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    final answer = await ConfirmExitDialog.show(context,
        content: const Text('Toutes les modifications seront perdues.'));
    if (!mounted || !answer) return;

    if (!answer || !mounted) return;
    Navigator.of(context).pop();
  }

  void _showHelp({required bool force}) async {
    bool shouldShowHelp = force;
    if (!shouldShowHelp) {
      final prefs = await SharedPreferences.getInstance();
      final wasShown = prefs.getBool('SstRiskFormHelpWasShown');
      if (wasShown == null || !wasShown) shouldShowHelp = true;
    }

    if (!shouldShowHelp) return;

    final scrollController = ScrollController();
    // ignore: use_build_context_synchronously
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'REPÈRES',
          textAlign: TextAlign.center,
        ),
        content: RawScrollbar(
            controller: scrollController,
            thumbVisibility: true,
            thickness: 7,
            minThumbLength: 75,
            thumbColor: Theme.of(context).primaryColor,
            radius: const Radius.circular(20),
            child: SingleChildScrollView(
              controller: scrollController,
              child: Container(
                margin: const EdgeInsets.only(right: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Objectifs du questionnaire',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    ItemizedText(
                      const [
                        'S\'informer sur les risques auxquels est exposé l\'élève à ce '
                            'poste de travail.',
                        'Susciter un dialogue avec l\'entreprise sur les mesures '
                            'de prévention.\n'
                            'Les différentes sous-questions visent spécifiquement à '
                            'favoriser les échanges.'
                      ],
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Avec qui le remplir\u00a0?',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Text(
                      'La personne qui est en charge de former l\'élève sur le plancher\u00a0:',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    ItemizedText(
                      const [
                        'C\'est elle qui connait le mieux le poste de travail de l\'élève',
                        'Il sera plus facile d\'aborder avec elle qu\'avec l\'employeur '
                            'les questions relatives aux dangers et aux accidents',
                      ],
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Quand',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    ItemizedText(
                      const [
                        'La première semaine de stage',
                        'Pendant (ou après) une visite du poste de travail de l\'élève',
                      ],
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Durée',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Text(
                      '15 minutes',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Cibles',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    ItemizedText(
                      const [
                        'Nouvelle entreprise : remplissage initial',
                        'Milieu de stage récurrent : validation et mise à jour des '
                            'réponses des années précédentes',
                      ],
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            )),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, 'OK'),
              child: const Text('OK')),
        ],
      ),
    );

    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('SstRiskFormHelpWasShown', true);
  }

  @override
  Widget build(BuildContext context) {
    _showHelp(force: false);

    final enterprise =
        EnterprisesProvider.of(context).fromId(widget.enterpriseId);

    return Scaffold(
      appBar: AppBar(
          title: const Text('Repérer les risques SST'),
          leading: IconButton(
              onPressed: _cancel, icon: const Icon(Icons.arrow_back)),
          actions: [
            InkWell(
              onTap: () => _showHelp(force: true),
              borderRadius: BorderRadius.circular(25),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Icon(Icons.info),
              ),
            )
          ]),
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
    // Sort the question by "id"
    final questionIds = [...widget.job.specialization.questions];
    questionIds.sort((a, b) => int.parse(a) - int.parse(b));
    final questions =
        questionIds.map((e) => QuestionFileService.fromId(e)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SubTitle('Questions', left: 0),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: questions.length,
          itemBuilder: (context, index) {
            final question = questions[index];

            // Fill the initial answer
            answer[question.id] =
                widget.job.sstEvaluation.questions[question.id];
            answer['${question.id}+t'] =
                widget.job.sstEvaluation.questions['${question.id}+t'];

            switch (question.type) {
              case Type.radio:
                return Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: RadioWithFollowUp(
                    title: '${index + 1}. ${question.question}',
                    initialValue:
                        widget.job.sstEvaluation.questions[question.id],
                    elements: question.choices!.toList(),
                    elementsThatShowChild: [question.choices!.first],
                    onChanged: (value) {
                      answer[question.id] = value.toString();
                      _followUpController['${question.id}+t']!.text = '';
                      if (question.choices!.first != value) {
                        answer['${question.id}+t'] = null;
                      }
                    },
                    followUpChild: question.followUpQuestion == null
                        ? null
                        : _buildFollowUpQuestion(question, context),
                  ),
                );

              case Type.checkbox:
                return Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: CheckboxWithOther(
                    title: '${index + 1}. ${question.question}',
                    elements: question.choices!.toList(),
                    hasNotApplicableOption: true,
                    initialValues: (widget
                            .job.sstEvaluation.questions[question.id] as List?)
                        ?.map((e) => e as String)
                        .toList(),
                    onOptionWasSelected: (values) {
                      answer[question.id] = values;
                      if (!question.choices!.any((q) => values.contains(q))) {
                        answer['${question.id}+t'] = null;
                        _followUpController['${question.id}+t']!.text = '';
                      }
                    },
                    followUpChild: question.followUpQuestion == null
                        ? null
                        : _buildFollowUpQuestion(question, context),
                  ),
                );

              case Type.text:
                return Padding(
                  padding: const EdgeInsets.only(bottom: 36.0),
                  child: TextWithForm(
                    title: '${index + 1}. ${question.question}',
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
        title: question.followUpQuestion!,
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
          maxLines: null,
          enabled: false,
        ),
        TextField(
          decoration: const InputDecoration(
              labelText: 'Métier semi-spécialisé', border: InputBorder.none),
          controller:
              TextEditingController(text: widget.job.specialization.name),
          maxLines: null,
          enabled: false,
        ),
      ],
    );
  }
}
