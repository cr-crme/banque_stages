import 'package:pdf/pdf.dart' show PdfPoint, PdfColor;
import 'json_border.dart';
import 'package:pdf/widgets.dart'
    show
        BoxDecoration,
        BoxShape,
        BoxShadow;

import '../utilities/utilitaire.dart';


/// The `JSONDecoration` class is a helper class that represents the decoration of a container widget in a PDF document.
/// It takes a JSON object as input and returns a `BoxDecoration` object with the specified properties.
class JSONDecoration {
  /// A JSON object that contains the properties of the decoration.
  final Map<String, dynamic> _decoration;

  /// Creates a new instance of `JSONDecoration` with the specified JSON object.
  JSONDecoration(this._decoration);

  /// Returns a `BoxDecoration` object with the specified properties.
  BoxDecoration? getBoxDecoration() {
    if (_decoration.isEmpty) return null;

    return BoxDecoration(
      color: JSONColor(_decoration['color']).getColor(),
      border: JSONBorder(_decoration['border']).getTableBorder(),
      borderRadius: JSONBorderRadius(_decoration['borderRadius']).getBorderRadius(),
      boxShadow: _getBoxShadow(),
      shape: _getShape(),
    );
  }

  /// Returns a list of `BoxShadow` objects with the specified properties.
  List<BoxShadow>? _getBoxShadow() {
    final boxShadow = _decoration['boxShadow'];
    if (boxShadow is List<dynamic>) {
      List<BoxShadow> ret = [];
      for (var i = 0; i < boxShadow.length; i++) {
        ret.add(_getBoxShadowElement(boxShadow[i]));
      }
      return ret;
    } else {
      return null;
    }
  }

  /// Returns a `BoxShadow` object with the specified properties.
  BoxShadow _getBoxShadowElement(Map<String, dynamic> element) {
    return BoxShadow(
      color: JSONColor(element['color']).getColor() ?? PdfColor.fromHex("#000000"),
      offset: _getOffset(element['offset'] ?? [0, 0]),
      blurRadius: element['blurRadius'] ?? 0.0,
      spreadRadius: element['spreadRadius'] ?? 0.0,
    );
  }

  /// Returns a `PdfPoint` object with the specified offset.
  PdfPoint _getOffset(List<dynamic> offset) {
    if (offset.length == 2) {
      return PdfPoint(offset[0].toDouble(), offset[1].toDouble());
    } else {
      return PdfPoint.zero;
    }
  }

  /// Returns a `BoxShape` object with the specified shape.
  BoxShape _getShape() {
    final shape = _decoration['shape'];
    switch (shape) {
      case 'circle':
        return BoxShape.circle;
      case 'rectangle':
        return BoxShape.rectangle;
      default:
        return BoxShape.rectangle;
    }
  }
}