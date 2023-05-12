import 'package:flutter/material.dart';

import '/common/models/job.dart';

class CommentsExpansionPanel extends ExpansionPanel {
  CommentsExpansionPanel({
    required super.isExpanded,
    required Job job,
    required void Function(Job job) addComment,
  }) : super(
          canTapOnHeader: true,
          body: _SstBody(job, addComment),
          headerBuilder: (context, isExpanded) => const ListTile(
            title: Text(
              'Autres commentaires',
            ),
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
          children: [
            const SizedBox(height: 8),
            ...job.comments.isEmpty
                ? [
                    const Text('Il n\'y a présentement aucun commentaire.'),
                    const SizedBox(height: 16)
                  ]
                : job.comments
                    .map((comment) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(comment),
                        ))
                    .toList(),
            Center(
              child: TextButton(
                onPressed: () => addComment(job),
                child: const Text('Ajouter un commentaire'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
