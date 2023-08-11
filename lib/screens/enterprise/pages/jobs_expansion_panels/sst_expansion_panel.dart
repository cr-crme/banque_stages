import 'package:crcrme_banque_stages/common/models/enterprise.dart';
import 'package:crcrme_banque_stages/common/models/job.dart';
import 'package:crcrme_banque_stages/common/widgets/itemized_text.dart';
import 'package:crcrme_banque_stages/misc/question_file_service.dart';
import 'package:crcrme_banque_stages/router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class SstExpansionPanel extends ExpansionPanel {
  SstExpansionPanel({
    required super.isExpanded,
    required Enterprise enterprise,
    required Job job,
    required void Function(Job job) addSstEvent,
  }) : super(
          canTapOnHeader: true,
          body: _SstBody(enterprise, job, addSstEvent),
          headerBuilder: (context, isExpanded) => const ListTile(
            title: Text('Repérage des risques SST'),
          ),
        );
}

class _SstBody extends StatelessWidget {
  const _SstBody(
    this.enterprise,
    this.job,
    this.addSstEvent,
  );

  final Enterprise enterprise;
  final Job job;
  final void Function(Job job) addSstEvent;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Size.infinite.width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(job.sstEvaluation.isFilled
                ? 'Le questionnaire «\u00a0Repérer les risques SST\u00a0» a '
                    'été rempli pour ce poste de travail.\n'
                    'Dernière modification le '
                    '${DateFormat.yMMMEd('fr_CA').format(job.sstEvaluation.date)}'
                : 'Le questionnaire «\u00a0Repérer les risques SST\u00a0» n\'a '
                    'jamais été rempli pour ce poste de travail.'),
            const SizedBox(height: 12),
            _buildAnswers(context),
            Center(
              child: TextButton(
                onPressed: () => GoRouter.of(context).pushNamed(
                  Screens.jobSstForm,
                  params: Screens.params(enterprise, jobId: job),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Text(
                    job.sstEvaluation.isFilled
                        ? 'Afficher le détail\ndes risques et\nmoyens de prévention'
                        : 'Remplir le\nquestionnaire SST',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswers(BuildContext context) {
    final questionIds = [...job.specialization.questions.map((e) => e)];
    final questions =
        questionIds.map((e) => QuestionFileService.fromId(e)).toList();
    questions.sort((a, b) => int.parse(a.idSummary) - int.parse(b.idSummary));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: questions.map((q) {
        final answer = job.sstEvaluation.questions['Q${q.id}'];
        final answerT = job.sstEvaluation.questions['Q${q.id}+t'];
        if ((q.questionSummary == null && q.followUpQuestionSummary == null) ||
            (answer == null && answerT == null)) {
          return Container();
        }

        late Widget question;
        late Widget answerWidget;
        if (q.followUpQuestionSummary == null) {
          question = Text(
            q.questionSummary!,
            style: Theme.of(context).textTheme.titleSmall,
          );

          switch (q.type) {
            case Type.radio:
              answerWidget = Text(
                answer,
                style: Theme.of(context).textTheme.bodyMedium,
              );
              break;
            case Type.checkbox:
              if ((answer as List).isEmpty ||
                  answer[0] == '__NOT_APPLICABLE_INTERNAL__') {
                return Container();
              }
              answerWidget =
                  ItemizedText(answer.map((e) => e as String).toList());
              break;
            case Type.text:
              answerWidget = Text(answer);
              break;
          }
        } else {
          if (q.type == Type.checkbox || q.type == Type.text) {
            throw 'Showing follow up question for Checkbox or Text '
                'is not implemented yet';
          }

          if (answer == q.choices!.last) {
            // No follow up question was needed
            return Container();
          }

          question = question = Text(
            q.followUpQuestionSummary!,
            style: Theme.of(context).textTheme.titleSmall,
          );
          answerWidget = Text(
            answerT ?? 'Aucune réponse fournie',
            style: Theme.of(context).textTheme.bodyMedium,
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            question,
            answerWidget,
            const SizedBox(height: 12),
          ],
        );
      }).toList(),
    );
  }
}
