import 'package:common/models/enterprises/job.dart';
import 'package:crcrme_banque_stages/common/widgets/itemized_text.dart';
import 'package:flutter/material.dart';

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
                : ItemizedText(job.comments, interline: 8),
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
