import 'package:flutter/material.dart';

import 'package:crcrme_banque_stages/common/models/job.dart';

class PhotoExpansionPanel extends ExpansionPanel {
  PhotoExpansionPanel({
    required super.isExpanded,
    required Job job,
    required void Function(Job job) addImage,
  }) : super(
          canTapOnHeader: true,
          body: _PhotoBody(job, addImage),
          headerBuilder: (context, isExpanded) => const ListTile(
            title: Text('Photos du poste de travail'),
          ),
        );
}

class _PhotoBody extends StatelessWidget {
  const _PhotoBody(
    this.job,
    this.addImage,
  );

  final Job job;
  final void Function(Job job) addImage;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ...job.photosUrl.isEmpty
                    ? [const Text('Aucune image disponible')]
                    : job.photosUrl.map(
                        // TODO: Make images clickables and deletables
                        (url) => Card(
                          child: Image.network(url, height: 250),
                        ),
                      ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: IconButton(
              onPressed: () => addImage(job),
              icon: Icon(
                Icons.camera_alt,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
