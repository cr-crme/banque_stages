import 'package:flutter/material.dart';

import 'package:crcrme_banque_stages/common/models/job.dart';
import 'package:image_picker/image_picker.dart';

class PhotoExpansionPanel extends ExpansionPanel {
  PhotoExpansionPanel({
    required super.isExpanded,
    required Job job,
    required void Function(Job job, ImageSource source) addImage,
    required void Function(Job job, int index) removeImage,
  }) : super(
          headerBuilder: (context, isExpanded) => const ListTile(
            title: Text('Photos du poste de travail'),
          ),
          canTapOnHeader: true,
          body: _PhotoBody(job, addImage, removeImage),
        );
}

class _PhotoBody extends StatefulWidget {
  const _PhotoBody(this.job, this.addImage, this.removeImage);

  final Job job;
  final void Function(Job job, ImageSource source) addImage;
  final void Function(Job job, int index) removeImage;

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

  void _showPhoto(int index) {
    showDialog(
        context: context,
        builder: (context) => Dialog(
                child: Stack(
              alignment: Alignment.center,
              children: [
                Image.network(widget.job.photosUrl[index]),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 50,
                    width: double.infinity,
                    decoration:
                        BoxDecoration(color: Colors.white.withAlpha(200)),
                    child: InkWell(
                      onTap: () {
                        widget.removeImage(widget.job, index);
                        setState(() {});
                        Navigator.of(context).pop();
                      },
                      borderRadius: BorderRadius.circular(25),
                      child: const Icon(
                        Icons.delete,
                        color: Colors.red,
                      ),
                    ),
                  ),
                )
              ],
            )));
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
            mainAxisAlignment: MainAxisAlignment.center,
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
                          : widget.job.photosUrl.asMap().keys.map(
                                (i) => InkWell(
                                  onTap: () => _showPhoto(i),
                                  child: Card(
                                    child: Image.network(
                                        widget.job.photosUrl[i],
                                        height: 250),
                                  ),
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
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () =>
                      widget.addImage(widget.job, ImageSource.gallery),
                  icon: Icon(
                    Icons.image,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                IconButton(
                  onPressed: () =>
                      widget.addImage(widget.job, ImageSource.camera),
                  icon: Icon(
                    Icons.camera_alt,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
