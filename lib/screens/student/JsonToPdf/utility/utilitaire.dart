import 'package:pdf/pdf.dart' show PdfColor;
import 'package:pdf/widgets.dart' show EdgeInsets, Alignment;

class Utilitaire {
  static List<double> convertIntListToDouble(List<dynamic> liste) {
    List<double> ret = [];
    for (var i = 0; i < liste.length; i++) {
      if (liste[i] is int) {
        ret.add(liste[i].toDouble());
      } else if (liste[i] is double) {
        ret.add(liste[i]);
      }
    }
    return ret;
  }

  static EdgeInsets getEdge(final edge) {
    if (edge is int || edge is double) {
      return EdgeInsets.all(edge.toDouble());
    } else if (edge is List<dynamic> && edge.length == 2) {
      List<dynamic> liste = Utilitaire.convertIntListToDouble(edge);
      return EdgeInsets.symmetric(vertical: liste[0], horizontal: liste[1]);
    } else if (edge is List<dynamic> && edge.length == 4) {
      List<dynamic> liste = Utilitaire.convertIntListToDouble(edge);
      return EdgeInsets.fromLTRB(liste[0], liste[1], liste[2], liste[3]);
    } else {
      return const EdgeInsets.all(0);
    }
  }

  static Alignment getAlignment(dynamic element) {
    if (element is String) {
      switch (element) {
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
        case 'left':
          return Alignment.centerLeft;
        case 'centerRight':
          return Alignment.centerRight;
        case 'right':
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
    } else if (element is List<dynamic> && element.length == 2) {
      element = convertIntListToDouble(element);
      return Alignment(element[0], element[1]);
    } else {
      return Alignment.center;
    }
  }

  static bool? getABool(dynamic property) => property is bool ? property : null;
  static String getString(dynamic property) =>
      property is String ? property : '';
  static double? getNumber(dynamic property) =>
      property is num ? property.toDouble() : null;
}

class JSONColor {
  final dynamic _color;

  JSONColor(this._color);

  bool isHex(String value) {
    final pattern =
        RegExp(r'^#?([0-9a-fA-F]{3}|[0-9a-fA-F]{6})([0-9a-fA-F]{2})?$');
    return pattern.hasMatch(value);
  }

  bool isInRange(List<dynamic> values) {
    if (values.length != 4 && values.length != 3) return false;
    for (final value in values) {
      if (value is! num || value < 0 || value > 255) {
        return false;
      }
    }
    return true;
  }

  PdfColor _getRgbColors(List<dynamic> values) {
    if (values.length != 4 && values.length != 3) {
      throw Exception('Invalid color');
    }
    final result = <double>[];
    for (final value in values) {
      result.add(value.toDouble());
    }
    double red = result[0];
    double green = result[1];
    double blue = result[2];
    if (values.length == 3) {
      return PdfColor(red, green, blue);
    }
    double opacity = result[3];
    return PdfColor(red, green, blue, opacity);
  }

  PdfColor? getColor() {
    switch (_color.runtimeType) {
      case String:
        return isHex(_color) ? PdfColor.fromHex(_color) : null;
      case List<dynamic>:
        return isInRange(_color) ? _getRgbColors(_color) : null;
      default:
        return null;
    }
  }
}
