import 'package:crcrme_banque_stages/screens/student/JsonToPdf/utilities/utilitaire.dart';
import 'package:pdf/widgets.dart'
    show
        TextAlign,
        TextDirection,
        TextOverflow,
        Widget,
        Text,
        TextStyle,
        Align,
        Container,
        BorderSide,
        BoxDecoration,
        Border;
import '../json_pdf.dart' show JSONWidget, JSONTextStyle;

class JSONText extends JSONWidget {
  final Map<String, dynamic> _text;
  JSONText(this._text) : super(_text);

  @override
  Widget getWidget() => Align(
        alignment: Utilitaire.getAlignment(_text['alignment'] ?? 'left'),
        child: getChild(),
      );

  String getText() => Utilitaire.getString(_text['content']);
  double? getTextScaleFactor() => Utilitaire.getNumber(_text['scaleFactor']);
  int? getMaxLines() => Utilitaire.getNumber(_text['maxLines'])?.toInt();
  bool? getSoftWrap() => Utilitaire.getABool(_text['softWrap']);
  bool? getTightBounds() => Utilitaire.getABool(_text['tightBounds']);
  TextStyle? getTextStyle() =>
      JSONTextStyle(_text['style'] ?? <String, dynamic>{}).getTextStyle();

  /// This way of underlining text shouldnt be continued. It is a temporary solution, since the underline from the pdf package is not working.
  /// The solution is to to create a container with a border at the bottom and put the text inside it.
  /// Normally it should be like this in the JSON:
  /// "style": {
  ///     "decoration": "underline"
  /// }
  bool getUnderline() => Utilitaire.getABool(_text['underline']) ?? false;

  Widget? getChild() {
    if (getUnderline()) {
      return Container(
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(width: 1.0),
          ),
        ),
        child: Text(
          getText(),
          style: getTextStyle(),
          textAlign: getTextAlign(),
          textDirection: getTextDirection(),
          overflow: getTextOverflow(),
          softWrap: getSoftWrap(),
          tightBounds: getTightBounds() ?? false,
          textScaleFactor: getTextScaleFactor() ?? 1.0,
        ),
      );
    } else {
      return Text(
        getText(),
        style: getTextStyle(),
        textAlign: getTextAlign(),
        textDirection: getTextDirection(),
        overflow: getTextOverflow(),
        softWrap: getSoftWrap(),
        tightBounds: getTightBounds() ?? false,
        textScaleFactor: getTextScaleFactor() ?? 1.0,
      );
    }
  }

  TextAlign? getTextAlign() {
    final textAlign = _text['alignment'];
    if (textAlign is String) {
      switch (textAlign) {
        case 'center':
          return TextAlign.center;
        case 'left':
          return TextAlign.left;
        case 'right':
          return TextAlign.right;
        case 'justify':
          return TextAlign.justify;
        default:
          return TextAlign.left;
      }
    } else {
      return null;
    }
  }

  TextDirection? getTextDirection() {
    final textDirection = _text['direction'];
    if (textDirection is! String) {
      return null;
    }
    switch (textDirection) {
      case 'rtl':
        return TextDirection.rtl;
      case 'ltr':
        return TextDirection.ltr;
      default:
        return null;
    }
  }

  TextOverflow? getTextOverflow() {
    final textOverflow = _text['textOverflow'];
    if (textOverflow is String) {
      switch (textOverflow) {
        case 'clip':
          return TextOverflow.clip;
        case 'ellipsis':
          return TextOverflow.visible;
        case 'fade':
          return TextOverflow.span;
        default:
          return null;
      }
    } else {
      return null;
    }
  }
}
