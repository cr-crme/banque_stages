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
              "Autres commentaires",
            ),
            trailing: IconButton(
                onPressed: () => addComment(job),
                icon: const Icon(Icons.add_comment_outlined)),
          ),
        );
}

class _SstBody extends StatelessWidget {
  const _SstBody({Key? key, required this.job}) : super(key: key);

  final Job job;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: Size.infinite.width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          children: job.comments.isEmpty
              ? [
                  const Text("Il n'y a présentement aucun commentaire"),
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
