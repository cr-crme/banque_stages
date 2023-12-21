import 'dart:typed_data';
import 'dart:io';
import 'package:test/test.dart';

import 'json_widget.dart';
import '../utilities/utilitaire.dart' show Utilitaire;
import 'package:pdf/widgets.dart' show Image, Alignment, Widget, MemoryImage;

class JSONMemoryImage {
  String path;
  JSONMemoryImage(this.path);

  bool isValidExtentionextentions() {
    String extension = path.split('.').last;
    List<String> extensionsImage = [
      'jpeg',
      'jpg',
      'png',
      'gif',
      'bmp',
      'webp',
      'svg',
      'tiff',
      'jfif'
    ];
    if (!extensionsImage.contains(extension.toLowerCase())) {
      return false;
    }
    return true;
  }

  bool doesImageExist() {
    if (FileSystemEntity.typeSync(path) == FileSystemEntityType.notFound) {
      return false;
    }
    return true;
  }

  MemoryImage getMemoryImage() {
    if (!isValidExtentionextentions()) throwsException;
    if (!doesImageExist()) throwsException;
    File file = File(path);
    Uint8List uint8list = file.readAsBytesSync();
    return MemoryImage(uint8list);
  }
}

class JSONImage extends JSONWidget {
  final Map<String, dynamic> _image;
  JSONImage(this._image) : super(_image);

  @override
  Widget getWidget() => Image(
        JSONMemoryImage('/lib/image/OIP.jfif').getMemoryImage(),
        alignment: _getAlignment(),
        width: _getwidth(),
        dpi: _getdpi(),
        height: getheight(),
      );

  Alignment _getAlignment() {
    Object alignment = _image['alignment'];
    if (alignment is String) {
      switch (alignment) {
        case 'center':
          return Alignment.center;
        case 'topCenter':
          return Alignment.topCenter;
        case 'topLeft':
          return Alignment.topLeft;
        case 'topRight':
          return Alignment.topRight;
        case 'centerLeft':
          return Alignment.centerLeft;
        case 'centerRight':
          return Alignment.centerRight;
        case 'bottomCenter':
          return Alignment.bottomCenter;
        case 'bottomLeft':
          return Alignment.bottomLeft;
        case 'bottomRight':
          return Alignment.bottomRight;
        default:
          return Alignment.center;
      }
    } else if (alignment is List<dynamic> && alignment.length == 2) {
      alignment = Utilitaire.convertIntListToDouble(alignment);
      return Alignment(alignment[0], alignment[1]);
    } else {
      return Alignment.center;
    }
  }

  double? _getwidth() {
    final width = _image['width'];
    if (width is int || width is double) {
      return width.toDouble();
    } else {
      return null;
    }
  }

  double? getheight() {
    final height = _image['height'];
    if (height is int || height is double) {
      return height.toDouble();
    } else {
      return null;
    }
  }

  double? _getdpi() {
    final width = _image['dpi'];
    if (width is int || width is double) {
      return width.toDouble();
    } else {
      return null;
    }
  }
}
