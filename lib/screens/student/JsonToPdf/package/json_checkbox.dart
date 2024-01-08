import 'package:pdf/widgets.dart' show Checkbox;
import '../json_pdf.dart' show JSONWidget;

class JSONCheckbox extends JSONWidget {
  final Map<String, dynamic> _checkbox;
  JSONCheckbox(this._checkbox) : super(_checkbox);

  @override
  Checkbox getWidget() {
    String name = _checkbox['name'] ?? '';
    bool value = _checkbox['value'] ?? false;
    if (name == '') {
      throw Exception('Checkbox name is empty');
    }
    return Checkbox(
      name: name,
      value: value,
    );
  }
}
