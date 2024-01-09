import 'package:pdf/pdf.dart';

import './json_border.dart' show JSONBorder;
import 'package:pdf/widgets.dart'
    show
        BorderSide,
        BoxBorder,
        BoxDecoration,
        Column,
        Container,
        TableBorder,
        TextField,
        Widget,
        SizedBox,
        Row;
import '../utilities/utilitaire.dart';
import '../json_pdf.dart' show JSONWidget, JSONFlexible;

/// The `JSONInputField` class is a subclass of `JSONWidget` that represents an input field widget in a PDF document.
/// It takes a JSON object as input and returns a `TextField` widget with the specified properties.
class JSONInputField extends JSONWidget {
  final Map<String, dynamic> _inputField;

  /// Creates a new instance of `JSONInputField` with the specified JSON object.
  JSONInputField(this._inputField) : super(_inputField);

  /// Returns a `TextField` widget with the specified properties.
  TableBorder defaultBorder = const TableBorder(
    bottom: BorderSide(width: 2, color: PdfColor.fromInt(0xff000000)),
  );
  double? get width => Utilitaire.getNumber(_inputField['width']);
  double get height => Utilitaire.getNumber(_inputField['height']) ?? 13;
  String get name => Utilitaire.getString(_inputField['name']);
  bool get multiline => Utilitaire.getABool(_inputField['multiline']) ?? false;
  int get numberOfLines =>
      Utilitaire.getNumber(_inputField['numberOfLines'])?.toInt() ?? 1;
  List<Widget> get children {
    if (!multiline || numberOfLines <= 1) {
      return [
        Container(
            height: height,
            width: width,
            decoration: BoxDecoration(border: defaultBorder))
      ];
    }
    var list = <Widget>[];
    for (var i = 0; i < numberOfLines; i++) {
      list.add(Container(
        width: width,
        height: height,
        decoration: const BoxDecoration(
          border: TableBorder(
            bottom: BorderSide(width: 1, color: PdfColor.fromInt(0xff000000)),
          ),
        ),
      ));
    }
    return list;
  }

  BoxBorder get border =>
      JSONBorder(_inputField['border']).getTableBorder() ?? defaultBorder;
  Column get column => Column(children: children);
  String? get defaultValue => Utilitaire.getString(_inputField['defaultValue']);

  @override
  Widget getWidget() {
    // Get properties from the input JSON object
    TableBorder defaultBorder = const TableBorder(
      bottom: BorderSide(width: 2, color: PdfColor.fromInt(0xff000000)),
    );
    double? width = Utilitaire.getNumber(_inputField['width']);
    double height = Utilitaire.getNumber(_inputField['height']) ?? 13;
    String name = Utilitaire.getString(_inputField['name']);
    bool multiline = Utilitaire.getABool(_inputField['multiline']) ?? false;
    int numberOfLines =
        Utilitaire.getNumber(_inputField['numberOfLines'])?.toInt() ?? 1;

    // Create child widgets for the input field
    List<Widget> children = [];
    if (!multiline || numberOfLines <= 1) {
      children.add(Container(
          height: height,
          width: width,
          decoration: BoxDecoration(border: defaultBorder)));
    } else {
      for (var i = 0; i < numberOfLines; i++) {
        children.add(Container(
          width: width,
          height: height,
          decoration: const BoxDecoration(
            border: TableBorder(
              bottom: BorderSide(width: 1, color: PdfColor.fromInt(0xff000000)),
            ),
          ),
        ));
      }
    }

    // Create and return the `TextField` widget
    return TextField(
      name: name,
      width: width ?? double.infinity,
      height: height,
      child: Column(children: children),
      fieldFlags: multiline && numberOfLines > 1
          ? {PdfFieldFlags.multiline}
          : {}, // Set field flags for multiline input fields
      value: defaultValue,
    );
  }
}

class JSONFieldRow extends JSONWidget {
  final Map<String, dynamic> row;
  JSONFieldRow(this.row) : super(row);

  @override
  Widget getWidget() {
    Row ret = Row(
      children: [label, space, textField],
    );
    return ret;
  }

  Widget get label {
    if (row['label'] is String) {
      return JSONFlexible(createTextJson(row['label'])).getWidget();
    }
    row['label']['type'] = 'text';
    return JSONFlexible(row['label']).getWidget();
  }

  Widget get textField {
    if (row['textField'] == null) {
      throw Exception('textField is null');
    }
    row['textField']['type'] = 'inputField';
    return JSONFlexible(row['textField']).getWidget();
  }

  Widget get space => SizedBox(width: Utilitaire.getNumber(row['space'] ?? 0));
  Map<String, dynamic> createTextJson(String content) {
    return {
      'type': 'text',
      'content': content,
      'style': {'fontSize': 13}
    };
  }
}
