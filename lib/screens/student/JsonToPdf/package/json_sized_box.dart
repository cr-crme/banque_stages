import 'package:crcrme_banque_stages/screens/student/JsonToPdf/utilities/utilitaire.dart';
import 'package:pdf/widgets.dart' show SizedBox;
import '../json_pdf.dart' show JSONWidget;

class JSONSizedBox extends JSONWidget {
  final Map<String, dynamic> _sizedBox;
  JSONSizedBox(this._sizedBox) : super(_sizedBox);

  @override
  SizedBox getWidget() {
    final width = Utilitaire.getNumber(_sizedBox['width']) ?? 0;
    final height = Utilitaire.getNumber(_sizedBox['height']) ?? 0;

    return SizedBox(
      width: width,
      height: height,
    );
  }
}
