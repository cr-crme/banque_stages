import 'package:pdf/pdf.dart' show PdfColor;
import '../utilities/utilitaire.dart';
import 'package:pdf/widgets.dart'
    show Border, BorderStyle, BorderSide, BorderRadius, TableBorder, Radius;

// A class that represents a border in JSON format.
class JSONBorder {
  final dynamic _border;

  /// Creates a new [JSONBorder] instance with the given [_border] data.
  JSONBorder(this._border);

  /// Returns a [Border] object based on the [_border] data.
  ///
  /// If the [_border] data is not a valid map, returns null.
  Border? getBorder() {
    if (_border is Map<String, dynamic>) {
      return Border(
        left: getBorderSide(_border['left'] ?? {}),
        right: getBorderSide(_border['right'] ?? {}),
        top: getBorderSide(_border['top'] ?? {}),
        bottom: getBorderSide(_border['bottom'] ?? {}),
      );
    } else {
      return null;
    }
  }

  /// Returns a [TableBorder] object based on the [_border] data.
  ///
  /// If the [_border] data is not a valid map, returns null.
  TableBorder? getTableBorder() {
    if (_border is num) {
      return TableBorder.all(width: _border.toDouble());
    }
    if (_border is Map<String, dynamic>) {
      return TableBorder(
        left: getBorderSide(_border['left'] ?? {}),
        right: getBorderSide(_border['right'] ?? {}),
        top: getBorderSide(_border['top'] ?? {}),
        bottom: getBorderSide(_border['bottom'] ?? {}),
        horizontalInside: getBorderSide(_border['horizontalInside'] ?? {}),
        verticalInside: getBorderSide(_border['verticalInside'] ?? {}),
      );
    } else {
      return null;
    }
  }

  /// Returns a [BorderSide] object based on the [borderSide] data.
  ///
  /// If the [borderSide] data is empty, returns [BorderSide.none].
  BorderSide getBorderSide(Map<String, dynamic> borderSide) {
    if (borderSide.isEmpty) return BorderSide.none;
    return BorderSide(
      color: JSONColor(borderSide['color']).getColor() ??
          PdfColor.fromHex("#000000"),
      width: Utilitaire.getNumber(borderSide['width']) ?? 1.0,
      style: getBorderStyle(borderSide['style'] ?? 'solid'),
    );
  }

  /// Returns a [BorderStyle] enum value based on the [style] string.
  ///
  /// If the [style] string is not a valid border style, returns [BorderStyle.solid].
  BorderStyle getBorderStyle(String style) {
    switch (style) {
      case 'solid':
        return BorderStyle.solid;
      case 'dashed':
        return BorderStyle.dashed;
      case 'dotted':
        return BorderStyle.dotted;
      case 'none':
        return BorderStyle.none;
      default:
        return BorderStyle.solid;
    }
  }
}

/// A class that represents a border radius in JSON format.
class JSONBorderRadius {
  dynamic borderRadius;

  /// Creates a new [JSONBorderRadius] instance with the given [borderRadius] data.
  JSONBorderRadius(this.borderRadius);

  /// Returns a [BorderRadius] object based on the [borderRadius] data.
  ///
  /// If the [borderRadius] data is not a valid format, returns null.
  BorderRadius? getBorderRadius() {
    if (borderRadius is int || borderRadius is double) {
      return BorderRadius.circular(borderRadius.toDouble());
    } else if (borderRadius is List<dynamic> && borderRadius.length == 2) {
      List<dynamic> liste = Utilitaire.convertIntListToDouble(borderRadius);
      return BorderRadius.vertical(
          top: Radius.circular(liste[0]), bottom: Radius.circular(liste[1]));
    } else if (borderRadius is List<dynamic> && borderRadius.length == 4) {
      List<dynamic> liste = Utilitaire.convertIntListToDouble(borderRadius);
      return BorderRadius.only(
          topLeft: Radius.circular(liste[0]),
          topRight: Radius.circular(liste[1]),
          bottomLeft: Radius.circular(liste[2]),
          bottomRight: Radius.circular(liste[3]));
    } else {
      return null;
    }
  }
}

/// A class that represents a table border in JSON format.
class JSONTableBorder {
  final dynamic _border;

  /// Creates a new [JSONTableBorder] instance with the given [_border] data.
  JSONTableBorder(this._border);

  /// Returns a [TableBorder] object based on the [_border] data.
  ///
  /// If the [_border] data is not a valid map, returns a default [TableBorder.all()].
  TableBorder getBorder() {
    final border = _border['border'];
    if (border is Map<String, dynamic>) {
      return TableBorder(
        left: getBorderSide(border['left'] ?? {}),
        right: getBorderSide(border['right'] ?? {}),
        top: getBorderSide(border['top'] ?? {}),
        bottom: getBorderSide(border['bottom'] ?? {}),
        horizontalInside: getBorderSide(border['horizontalInside'] ?? {}),
        verticalInside: getBorderSide(border['verticalInside'] ?? {}),
      );
    } else {
      return TableBorder.all();
    }
  }

  /// Returns a [BorderSide] object based on the [borderSide] data.
  ///
  /// If the [borderSide] data is empty, returns [BorderSide.none].
  BorderSide getBorderSide(Map<String, dynamic> borderSide) {
    if (borderSide.isEmpty) return BorderSide.none;
    return BorderSide(
      color: JSONColor(borderSide['color']).getColor() ??
          PdfColor.fromHex("#000000"),
      width: Utilitaire.getNumber(borderSide['width']) ?? 1.0,
      style: getBorderStyle(borderSide['style'] ?? 'solid'),
    );
  }

  /// Returns a [BorderStyle] enum value based on the [style] string.
  ///
  /// If the [style] string is not a valid border style, returns [BorderStyle.solid].
  BorderStyle getBorderStyle(String style) {
    switch (style) {
      case 'solid':
        return BorderStyle.solid;
      case 'none':
        return BorderStyle.none;
      default:
        return BorderStyle.solid;
    }
  }
}
