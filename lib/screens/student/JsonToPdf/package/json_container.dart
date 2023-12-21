import 'package:pdf/widgets.dart' show EdgeInsets, Widget, Container, Alignment;
import '../json_pdf.dart' show JSONWidget, JSONDecoration;

import '../utilities/utilitaire.dart';

/// The `JSONContainer` class is a subclass of `JSONWidget` that represents a container widget in a PDF document.
/// It takes a JSON object as input and returns a `Container` widget with the specified properties.
class JSONContainer extends JSONWidget {
  /// A JSON object that contains the properties of the container widget.
  Map<String, dynamic> widget;

  /// Creates a new instance of `JSONContainer` with the specified JSON object.
  JSONContainer(this.widget) : super(widget);

  /// Returns a `Container` widget with the specified properties.
  @override
  Widget getWidget() {
    final child = getChild();
    final alignment = getAlignment();
    final decoration = getDecoration()?.getBoxDecoration();
    final padding = getPadding();
    final margin = getMargin();
    final width = getWidth();
    final height = getHeight();
    return Container(
      alignment: alignment,
      decoration: decoration,
      child: child,
      padding: padding,
      margin: margin,
      width: width,
      height: height,
    );
  }

  /// Returns the alignment of the container as an `Alignment` object.
  Alignment getAlignment() => Utilitaire.getAlignment(widget['alignment']);

  /// Returns the padding of the container as an `EdgeInsets` object.
  EdgeInsets getPadding() => Utilitaire.getEdge(widget['padding']);

  /// Returns the margin of the container as an `EdgeInsets` object.
  EdgeInsets getMargin() => Utilitaire.getEdge(widget['margin']);

  /// Returns the width of the container as a `double`.
  double? getWidth() => Utilitaire.getNumber(widget['width']);

  /// Returns the height of the container as a `double`.
  double? getHeight() => Utilitaire.getNumber(widget['height']);

  /// Returns the decoration of the container as a `JSONDecoration` object.
  JSONDecoration? getDecoration() => JSONDecoration(widget['decoration'] ?? {});

  /// Returns the child widget of the container as a `Widget` object.
  Widget? getChild() {
    final child = widget['child'];
    if (child is Map<String, dynamic>) {
      //return JSONWidget.getWidget(child);
      return JSONWidget.createWidget(child);
    } else {
      return null;
    }
  }
}
