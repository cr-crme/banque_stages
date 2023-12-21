import 'package:crcrme_banque_stages/screens/student/JsonToPdf/package/json_widget.dart';
import 'package:crcrme_banque_stages/screens/student/JsonToPdf/utilities/utilitaire.dart';
import 'package:pdf/widgets.dart';

class JSONSpace extends JSONWidget {
  final Map<String, dynamic> _space;
  JSONSpace(this._space) : super(_space);

  @override
  Widget getWidget() {
    final width = _space['width'];
    final height = _space['height'];
    return SizedBox(
      width: width,
      height: height,
    );
  }
}

class JSONVerticalSpace extends JSONWidget {
  final Map<String, dynamic> _verticalSpace;
  JSONVerticalSpace(this._verticalSpace) : super(_verticalSpace);

  @override
  Widget getWidget() {
    final height = Utilitaire.getNumber(_verticalSpace['height']) ?? 0;
    return SizedBox(
      width: 0,
      height: height,
    );
  }
}

class JSONHorizontalSpace extends JSONWidget {
  final Map<String, dynamic> _horizontalSpace;
  JSONHorizontalSpace(this._horizontalSpace) : super(_horizontalSpace);

  @override
  Widget getWidget() {
    final width = Utilitaire.getNumber(_horizontalSpace['width']) ?? 0;
    return SizedBox(
      width: width,
      height: 0,
    );
  }
}

class JSONSpacer extends JSONWidget {
  final Map<String, dynamic> _spacer;
  JSONSpacer(this._spacer) : super(_spacer);

  @override
  Widget getWidget() {
    final flex = _spacer['flex'] ?? 1;
    return Spacer(
      flex: flex,
    );
  }
}
