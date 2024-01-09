import 'package:pdf/widgets.dart'
    show Font, TextStyle, FontStyle, FontWeight, TextDecoration;

class JSONTextStyle {
  final Map<String, dynamic> _textstyle;
  JSONTextStyle(this._textstyle);

  TextStyle? getTextStyle() {
    final fontSize = getfontsize() ?? 12;
    final fontBold = getFontBold();
    final fontItalic = getfontItalic();
    final fontWeight = getfontWeight() ?? FontWeight.normal;
    final fontStyle = getfontstyle() ?? FontStyle.normal;
    final decoration = getDecoration() ?? TextDecoration.none;

    return TextStyle(
      fontSize: fontSize,
      fontBold: fontBold,
      fontItalic: fontItalic,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      decoration: decoration,
    );
  }

  double? getfontsize() {
    final fontSize = _textstyle['fontSize'];
    if (fontSize is int || fontSize is double) {
      return fontSize.toDouble();
    } else {
      return null;
    }
  }

  Font? getFontBold() {
    final fontBold = _textstyle['fontbold'];

    if (fontBold != null) {
      switch (fontBold) {
        case 'courier':
          return Font.courier();
        case 'courierBold':
          return Font.courierBold();
        case 'courierBoldOblique':
          return Font.courierBoldOblique();
        case 'helvetica':
          return Font.helvetica();
        case 'helveticaBold':
          return Font.helveticaBold();
        case 'helveticaBoldOblique':
          return Font.helveticaBoldOblique();
        case 'times':
          return Font.times();
        case 'timesBold':
          return Font.timesBold();
        case 'timesBoldItalic':
          return Font.timesBoldItalic();
        case 'symbol':
          return Font.symbol();
        default:
          return Font.zapfDingbats();
      }
    }
    return null;
  }

  Font? getfontItalic() {
    final fontItalic = _textstyle['fontItalic'];

    if (fontItalic != null) {
      switch (fontItalic) {
        case 'courier':
          return Font.courier();
        case 'courierBoldOblique':
          return Font.courierBoldOblique();
        case 'courierOblique':
          return Font.courierOblique();
        case 'helvetica':
          return Font.helvetica();
        case 'helveticaBoldOblique':
          return Font.helveticaBoldOblique();
        case 'helveticaOblique':
          return Font.helveticaOblique();
        case 'times':
          return Font.times();
        case 'timesBoldItalic':
          return Font.timesBoldItalic();
        case 'timesItalic':
          return Font.timesItalic();
        case 'symbol':
          return Font.symbol();
        default:
          return Font.zapfDingbats();
      }
    }
    return null;
  }

  FontWeight? getfontWeight() {
    final fontWeight = _textstyle['fontWeight'];

    if (fontWeight != null) {
      switch (fontWeight) {
        case 'normal':
          return FontWeight.normal;
        default:
          return FontWeight.bold;
      }
    }
    return null;
  }

  FontStyle? getfontstyle() {
    final fontStyle = _textstyle['fontStyle'];

    if (fontStyle != null) {
      switch (fontStyle) {
        case 'normal':
          return FontStyle.normal;
        default:
          return FontStyle.italic;
      }
    }
    return null;
  }

  TextDecoration? getDecoration() {
    final decoration = _textstyle['decoration'];

    if (decoration != null) {
      switch (decoration) {
        case 'lineThrough':
          return TextDecoration.lineThrough;
        case 'none':
          return TextDecoration.none;
        case 'overline':
          return TextDecoration.overline;
        case 'underline':
          return TextDecoration.underline;
        default:
          return TextDecoration.none;
      }
    }
    return TextDecoration.none;
  }
}
