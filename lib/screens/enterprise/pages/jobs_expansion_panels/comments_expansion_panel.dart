import 'package:flutter/material.dart';

import '/common/models/job.dart';

class CommentsExpansionPanel extends ExpansionPanel {
  CommentsExpansionPanel({
    required super.isExpanded,
    required Job job,
    required void Function(Job job) addComment,
  }) : super(
          canTapOnHeader: true,
          body: _SstBody(job: job),
          headerBuilder: (context, isExpanded) => ListTile(
            title: const Text(
              'Autres commentaires',
            ),
            trailing: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey[900]!,
                    blurRadius: 8.0,
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: () => addComment(job),
                icon: const Icon(Icons.add_comment),
                color: Colors.blueGrey,
              ),
            ),
          ),
        );
}

class _SstBody extends StatelessWidget {
  const _SstBody({required this.job});

  final Job job;

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
          children: job.comments.isEmpty
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
        ),
      ),
    );
  }
}
