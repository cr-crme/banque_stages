import 'package:crcrme_banque_stages/screens/student/JsonToPdf/package/json_widget.dart';
import 'package:crcrme_banque_stages/screens/student/JsonToPdf/utilities/utilitaire.dart';
import 'package:pdf/widgets.dart'
    show
        Widget,
        Row,
        Column,
        MainAxisAlignment,
        CrossAxisAlignment,
        VerticalDirection,
        Flexible,
        Expanded;

/// The `JSONFlexBox` mixin provides helper methods for parsing flexbox properties from a JSON object.
mixin JSONFlexBox {
  /// Returns the `MainAxisAlignment` enum value corresponding to the specified string.
  ///
  /// If the string is not recognized, `MainAxisAlignment.start` is returned.
  MainAxisAlignment getMainAxisAlignment(dynamic element) {
    switch (element) {
      case 'start':
        return MainAxisAlignment.start;
      case 'end':
        return MainAxisAlignment.end;
      case 'center':
        return MainAxisAlignment.center;
      case 'spaceBetween':
        return MainAxisAlignment.spaceBetween;
      case 'space-between':
        return MainAxisAlignment.spaceBetween;
      case 'spaceAround':
        return MainAxisAlignment.spaceAround;
      case 'space-around':
        return MainAxisAlignment.spaceAround;
      case 'spaceEvenly':
        return MainAxisAlignment.spaceEvenly;
      case 'space-evenly':
        return MainAxisAlignment.spaceEvenly;
      default:
        return MainAxisAlignment.start;
    }
  }

  /// Returns the `CrossAxisAlignment` enum value corresponding to the specified string.
  ///
  /// If the string is not recognized, `CrossAxisAlignment.start` is returned.
  CrossAxisAlignment getCrossAxisAlignment(dynamic element) {
    switch (element) {
      case 'start':
        return CrossAxisAlignment.start;
      case 'end':
        return CrossAxisAlignment.end;
      case 'center':
        return CrossAxisAlignment.center;
      case 'stretch':
        return CrossAxisAlignment.stretch;
      default:
        return CrossAxisAlignment.start;
    }
  }

  /// Returns the `VerticalDirection` enum value corresponding to the specified string.
  ///
  /// If the string is not recognized, `VerticalDirection.down` is returned.
  VerticalDirection getVerticalDirection(dynamic element) {
    switch (element) {
      case 'up':
        return VerticalDirection.up;
      case 'down':
        return VerticalDirection.down;
      default:
        return VerticalDirection.down;
    }
  }

  /// Returns a list of `Widget` objects created from the specified list of JSON objects.
  ///
  /// If the input is not a list, an empty list is returned.
  List<Widget> getChildren(dynamic children) {
    List<Widget> widget = [];
    if (children is! List<dynamic>) {
      return widget;
    }
    for (var child in children) {
      widget.add(JSONFlexible(child).getWidget());
    }
    return widget;
  }
}

/// The `JSONRow` class is a subclass of `JSONWidget` that represents a row widget in a PDF document.
/// It takes a JSON object as input and returns a `Row` widget with the specified properties.
class JSONRow extends JSONWidget with JSONFlexBox {
  final Map<String, dynamic> _row;

  /// Creates a new instance of `JSONRow` with the specified JSON object.
  JSONRow(this._row) : super(_row);

  /// Returns a `Row` widget with the specified properties.
  @override
  Widget getWidget() {
    return Row(
      mainAxisAlignment: getMainAxisAlignment(_row['mainAxisAlignment']),
      crossAxisAlignment: getCrossAxisAlignment(_row['crossAxisAlignment']),
      verticalDirection: getVerticalDirection(_row['verticalDirection']),
      children: getChildren(_row['children']),
    );
  }
}

/// The `JSONColumn` class is a subclass of `JSONWidget` that represents a column widget in a PDF document.
/// It takes a JSON object as input and returns a `Column` widget with the specified properties.
class JSONColumn extends JSONWidget with JSONFlexBox {
  final Map<String, dynamic> _column;

  /// Creates a new instance of `JSONColumn` with the specified JSON object.
  JSONColumn(this._column) : super(_column);

  /// Returns a `Column` widget with the specified properties.
  @override
  Widget getWidget() {
    return Column(
      mainAxisAlignment:
          getMainAxisAlignment(_column['mainAxisAlignment'] ?? 'start'),
      crossAxisAlignment:
          getCrossAxisAlignment(_column['crossAxisAlignment'] ?? 'start'),
      verticalDirection:
          getVerticalDirection(_column['verticalDirection'] ?? 'down'),
      children: getChildren(_column['children'] ?? []),
    );
  }
}

/// The `JSONFlexible` class is a subclass of `JSONWidget` that represents a flexible widget in a PDF document.
/// It takes a JSON object as input and returns a `Flexible` or `Expanded` widget with the specified properties.
class JSONFlexible extends JSONWidget {
  final Map<String, dynamic> _flexible;

  /// Creates a new instance of `JSONFlexible` with the specified JSON object.
  JSONFlexible(this._flexible) : super(_flexible);

  /// Returns a `Flexible` or `Expanded` widget with the specified properties.
  @override
  Widget getWidget() {
    if (_flexible['flex'] is num) {
      return Flexible(
        flex: Utilitaire.getNumber(_flexible['flex'])?.toInt() ?? 1,
        child: JSONWidget.createWidget(_flexible),
      );
    }
    if (_flexible['flex'] == 'expanded') {
      return Expanded(
        child: JSONWidget.createWidget(_flexible),
      );
    }
    return JSONWidget.createWidget(_flexible);
  }
}
