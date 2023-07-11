import 'package:flutter/material.dart';

import 'package:crcrme_banque_stages/common/models/job.dart';

class PhotoExpansionPanel extends ExpansionPanel {
  PhotoExpansionPanel({
    required super.isExpanded,
    required Job job,
    required void Function(Job job) addImage,
  }) : super(
          headerBuilder: (context, isExpanded) => const ListTile(
            title: Text('Photos du poste de travail'),
          ),
          canTapOnHeader: true,
          body: _PhotoBody(job, addImage),
        );
}

class _PhotoBody extends StatefulWidget {
  const _PhotoBody(this.job, this.addImage);

  final Job job;
  final void Function(Job job) addImage;

  @override
  State<_PhotoBody> createState() => _PhotoBodyState();
}

class _PhotoBodyState extends State<_PhotoBody> {
  late final _scrollController = ScrollController()
    ..addListener(() => setState(() {}));

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }

  void _scrollPhotos(int direction) {
    const photoWidth = 150.0;
    _scrollController.animateTo(
        _scrollController.offset + (direction * photoWidth),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    final canLeftScroll =
        _scrollController.hasClients && _scrollController.offset > 0;

    // The || is a hack because the maxScrollExtend is zero when first opening the card
    final canRightScroll = _scrollController.hasClients &&
        (_scrollController.offset <
                _scrollController.position.maxScrollExtent ||
            (widget.job.photosUrl.length > 2 && _scrollController.offset == 0));

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          Row(
            children: [
              if (widget.job.photosUrl.isNotEmpty &&
                  _scrollController.hasClients)
                InkWell(
                    onTap: canLeftScroll ? () => _scrollPhotos(-1) : null,
                    borderRadius: BorderRadius.circular(25),
                    child: Icon(
                      Icons.arrow_left,
                      color: canLeftScroll
                          ? Theme.of(context).primaryColor
                          : Colors.grey,
                      size: 40,
                    )),
              Flexible(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  controller: _scrollController,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ...widget.job.photosUrl.isEmpty
                          ? [const Text('Aucune image disponible')]
                          : widget.job.photosUrl.map(
                              // TODO: Make images clickables and deletables
                              (url) => Card(
                                child: Image.network(url, height: 250),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
              if (widget.job.photosUrl.isNotEmpty &&
                  _scrollController.hasClients)
                InkWell(
                    onTap: canRightScroll ? () => _scrollPhotos(1) : null,
                    borderRadius: BorderRadius.circular(25),
                    child: Icon(
                      Icons.arrow_right,
                      color: canRightScroll
                          ? Theme.of(context).primaryColor
                          : Colors.grey,
                      size: 40,
                    )),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: IconButton(
              onPressed: () => widget.addImage(widget.job),
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
