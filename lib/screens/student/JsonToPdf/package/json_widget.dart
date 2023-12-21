import 'package:crcrme_banque_stages/screens/student/JsonToPdf/package/json_image.dart';
import '../json_pdf.dart'
    show
        JSONContainer,
        JSONText,
        JSONSizedBox,
        JSONCheckbox,
        JSONRow,
        JSONColumn,
        JSONInputField,
        JSONFieldRow,
        JSONTable;
import 'package:pdf/widgets.dart' show Widget;

abstract class JSONWidget {
  // ignore: unused_field
  final Map<String, dynamic> _widget;
  JSONWidget(this._widget);
  Widget getWidget();
  static Widget createWidget(dynamic element) {
    if (element is! Map<String, dynamic>) {
      throw Exception('Element is not a Map<String, dynamic>');
    }
    final type = element['type'];
    if (type == null) {
      throw Exception('Widget type is null');
    }
    switch (type) {
      case 'container':
        return JSONContainer(element).getWidget();
      case 'text':
        return JSONText(element).getWidget();
      case 'sizedBox':
        return JSONSizedBox(element).getWidget();
      case 'row':
        return JSONRow(element).getWidget();
      case 'column':
        return JSONColumn(element).getWidget();
      case 'checkbox':
        return JSONCheckbox(element).getWidget();
      case 'image':
        return JSONImage(element).getWidget();
      case 'inputField':
        return JSONInputField(element).getWidget();
      case 'table':
        return JSONTable(element).getWidget();
      case 'inputRow':
        return JSONFieldRow(element).getWidget();
      default:
        throw Exception('Unknown widget type: $type');
    }
  }
}
