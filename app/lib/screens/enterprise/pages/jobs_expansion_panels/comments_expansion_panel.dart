import 'package:common/models/enterprises/job.dart';
import 'package:common_flutter/providers/teachers_provider.dart';
import 'package:crcrme_banque_stages/common/widgets/itemized_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';

final _logger = Logger('CommentsExpansionPanel');

class CommentsExpansionPanel extends ExpansionPanel {
  CommentsExpansionPanel({
    required super.isExpanded,
    required Job job,
    required void Function(Job job) addComment,
  }) : super(
          canTapOnHeader: true,
          body: _SstBody(job, addComment),
          headerBuilder: (context, isExpanded) => const ListTile(
            title: Text('Commentaires'),
          ),
        );
}

class _SstBody extends StatelessWidget {
  const _SstBody(
    this.job,
    this.addComment,
  );

  final Job job;
  final void Function(Job job) addComment;

  @override
  Widget build(BuildContext context) {
    _logger.finer(
        'Building CommentsExpansionPanel for job: ${job.specialization.name}');

    final teachers = TeachersProvider.of(context);

    return SizedBox(
      width: Size.infinite.width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          crossAxisAlignment: job.comments.isEmpty
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            job.comments.isEmpty
                ? const Text('Il n\'y a présentement aucun commentaire.')
                : ItemizedText(
                    job.comments
                        .map(
                          (e) =>
                              '${teachers.fromId(e.teacherId).fullName} (${DateFormat.yMMMEd('fr_CA').format(e.date)}) - '
                              '${e.comment}',
                        )
                        .toList(),
                    interline: 8),
            Center(
              child: IconButton(
                onPressed: () => addComment(job),
                icon: Icon(Icons.add_comment,
                    color: Theme.of(context).primaryColor, size: 36),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
