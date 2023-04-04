import 'package:flutter/material.dart';

import '/common/models/job.dart';

class PhotoExpansionPanel extends ExpansionPanel {
  PhotoExpansionPanel({
    required super.isExpanded,
    required Job job,
    required void Function(Job job) addImage,
  }) : super(
          canTapOnHeader: true,
          body: _PhotoBody(job: job),
          headerBuilder: (context, isExpanded) => ListTile(
            title: const Text("Photos du poste de travail"),
            trailing: isExpanded
                ? IconButton(
                    onPressed: () => addImage(job),
                    icon: const Icon(Icons.add_photo_alternate_outlined))
                : null,
          ),
        );
}

class _PhotoBody extends StatelessWidget {
  const _PhotoBody({required this.job});

  final Job job;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: job.photosUrl.isEmpty
              ? [const Text("Aucune image disponible")]
              : job.photosUrl
                  .map(
                    // TODO: Make images clickables and deletables
                    (url) => Card(
                      child: Image.network(url, height: 250),
                    ),
                  )
                  .toList(),
        ),
      ),
    );
  }
}
