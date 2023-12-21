import 'package:crcrme_banque_stages/screens/student/JsonToPdf/json_pdf.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:test/test.dart';

void main() {
  group('JSONBorder', () {
    test('getBorder returns null when _border is not a Map', () {
      final jsonBorder = JSONBorder(42);
      expect(jsonBorder.getBorder(), isNull);
    });

    test('getBorder returns a Border when _border is a Map', () {
      final jsonBorder = JSONBorder({
        'left': {'color': '#000000', 'width': 1.0, 'style': 'solid'},
        'right': {'color': '#000000', 'width': 1.0, 'style': 'solid'},
        'top': {'color': '#000000', 'width': 1.0, 'style': 'solid'},
        'bottom': {'color': '#000000', 'width': 1.0, 'style': 'solid'},
      });
      expect(jsonBorder.getBorder(), isA<Border>());
    });

    test('getBorder returns a Border with the correct properties', () {
      final jsonBorder = JSONBorder({
        'left': {'color': '#000000', 'width': 1.0, 'style': 'solid'},
        'right': {'color': '#000000', 'width': 0.0, 'style': 'solid'},
        'top': {'color': '#000000', 'width': 1.0, 'style': 'solid'},
        'bottom': {'color': '#000000', 'width': 1.0, 'style': 'solid'},
      });
      final border = jsonBorder.getBorder();
      expect(border?.left.color, equals(PdfColor.fromHex('#000000')));
      expect(border?.left.width, equals(1.0));
      expect(border?.left.style, equals(BorderStyle.solid));
      expect(border?.right.color, equals(PdfColor.fromHex('#000000')));
      expect(border?.right.width, equals(0.0));
      expect(border?.right.style, equals(BorderStyle.solid));
      expect(border?.top.color, equals(PdfColor.fromHex('#000000')));
      expect(border?.top.width, equals(1.0));
      expect(border?.top.style, equals(BorderStyle.solid));
      expect(border?.bottom.color, equals(PdfColor.fromHex('#000000')));
      expect(border?.bottom.width, equals(1.0));
      expect(border?.bottom.style, equals(BorderStyle.solid));
    });

    test('getTableBorder returns null when _border is not a Map or a num', () {
      final jsonBorder = JSONBorder('invalid');
      expect(jsonBorder.getTableBorder(), isNull);
    });

    test('getTableBorder returns a TableBorder when _border is a num', () {
      final jsonBorder = JSONBorder(1);
      expect(jsonBorder.getTableBorder(), isA<TableBorder>());
    });

    test('getTableBorder returns a TableBorder with the correct properties',
        () {
      final jsonBorder = JSONBorder({
        'left': {'color': '#000000', 'width': 1.0, 'style': 'solid'},
        'right': {'color': '#000000', 'width': 0.0, 'style': 'solid'},
        'top': {'color': '#000000', 'width': 1.0, 'style': 'solid'},
        'bottom': {'color': '#000000', 'width': 1.0, 'style': 'solid'},
        'horizontalInside': {
          'color': '#000000',
          'width': 2.0,
          'style': 'dashed'
        },
        'verticalInside': {'color': '#000000', 'width': 2.0, 'style': 'dashed'},
      });
      final tableBorder = jsonBorder.getTableBorder();
      expect(tableBorder?.left.color, equals(PdfColor.fromHex('#000000')));
      expect(tableBorder?.left.width, equals(1.0));
      expect(tableBorder?.left.style, equals(BorderStyle.solid));
      expect(tableBorder?.right.color, equals(PdfColor.fromHex('#000000')));
      expect(tableBorder?.right.width, equals(0.0));
      expect(tableBorder?.right.style, equals(BorderStyle.solid));
      expect(tableBorder?.top.color, equals(PdfColor.fromHex('#000000')));
      expect(tableBorder?.top.width, equals(1.0));
      expect(tableBorder?.top.style, equals(BorderStyle.solid));
      expect(tableBorder?.bottom.color, equals(PdfColor.fromHex('#000000')));
      expect(tableBorder?.bottom.width, equals(1.0));
      expect(tableBorder?.bottom.style, equals(BorderStyle.solid));
      expect(tableBorder?.horizontalInside.color,
          equals(PdfColor.fromHex('#000000')));
      expect(tableBorder?.horizontalInside.width, equals(2.0));
      expect(tableBorder?.horizontalInside.style, equals(BorderStyle.dashed));
      expect(tableBorder?.verticalInside.color,
          equals(PdfColor.fromHex('#000000')));
      expect(tableBorder?.verticalInside.width, equals(2.0));
      expect(tableBorder?.verticalInside.style, equals(BorderStyle.dashed));
    });

    test('_getBorderSide returns BorderSide.none when borderSide is empty', () {
      final jsonBorder = JSONBorder({});
      final borderSide = jsonBorder.getBorderSide({});
      expect(borderSide, equals(BorderSide.none));
    });

    test('_getBorderSide returns a BorderSide with the correct properties', () {
      final jsonBorder = JSONBorder({});
      final borderSide = jsonBorder.getBorderSide({
        'color': '#ff0000',
        'width': 2.0,
        'style': 'dashed',
      });
      expect(borderSide.color, equals(PdfColor.fromHex('#ff0000')));
      expect(borderSide.width, equals(2.0));
      expect(borderSide.style, equals(BorderStyle.dashed));
    });

    test('_getBorderSide returns a default color when color is invalid', () {
      final jsonBorder = JSONBorder({});
      final borderSide = jsonBorder.getBorderSide({
        'color': 'invalid',
        'width': 1.0,
        'style': 'solid',
      });
      expect(borderSide.color, equals(PdfColor.fromHex('#000000')));
    });

    test('_getBorderSide returns a default width when width is invalid', () {
      final jsonBorder = JSONBorder({});
      final borderSide = jsonBorder.getBorderSide({
        'color': '#000000',
        'width': 'invalid',
        'style': 'solid',
      });
      expect(borderSide.width, equals(1.0));
    });

    test('_getBorderSide returns a default style when style is invalid', () {
      final jsonBorder = JSONBorder({});
      final borderSide = jsonBorder.getBorderSide({
        'color': '#000000',
        'width': 1.0,
        'style': 'invalid',
      });
      expect(borderSide.style, equals(BorderStyle.solid));
    });

    test('getBorderStyle returns BorderStyle.solid when style is "solid"', () {
      final jsonBorder = JSONBorder({});
      final borderStyle = jsonBorder.getBorderStyle('solid');
      expect(borderStyle, equals(BorderStyle.solid));
    });

    test('getBorderStyle returns BorderStyle.none when style is "none"', () {
      final jsonBorder = JSONBorder({});
      final borderStyle = jsonBorder.getBorderStyle('none');
      expect(borderStyle, equals(BorderStyle.none));
    });

    test('getBorderStyle returns BorderStyle.solid when style is invalid', () {
      final jsonBorder = JSONBorder({});
      final borderStyle = jsonBorder.getBorderStyle('invalid');
      expect(borderStyle, equals(BorderStyle.solid));
    });
  });

  group('JSONCheckbox', () {
    test('getWidget returns a Checkbox with the correct name and value', () {
      final jsonCheckbox = JSONCheckbox({'name': 'my_checkbox', 'value': true});
      final checkbox = jsonCheckbox.getWidget();
      expect(checkbox.name, equals('my_checkbox'));
      expect(checkbox.value, isTrue);
    });

    test('getWidget throws an exception when name is empty', () {
      final jsonCheckbox = JSONCheckbox({'name': '', 'value': false});
      expect(() => jsonCheckbox.getWidget(), throwsException);
    });
  });

  group('JSONContainer', () {
    test('getWidget returns a Container with the correct properties', () {
      final jsonContainer = JSONContainer({
        'child': {'type': 'text', 'content': 'Hello, world!'},
        'decoration': {
          'color': '#ff0000',
          'border': {
            'left': {'color': '#000000', 'width': 1.0, 'style': 'solid'},
            'right': {'color': '#000000', 'width': 0.0, 'style': 'solid'},
            'top': {'color': '#000000', 'width': 1.0, 'style': 'solid'},
            'bottom': {'color': '#000000', 'width': 1.0, 'style': 'solid'},
          },
        },
        'padding': [8.0, 16.0, 8.0, 16.0],
        'margin': [16.0, 32.0, 16.0, 32.0],
        'width': 200.0,
        'height': 100.0,
      });
      Widget container = jsonContainer.getWidget();
      expect(container, isA<Container>());
      container = container as Container;
      EdgeInsets? padding = container.padding;
      EdgeInsets? margin = container.margin;
      expect(container.decoration, isA<BoxDecoration>());
      expect(container.decoration?.color, equals(PdfColor.fromHex('#ff0000')));
      expect(container.decoration?.border?.left.color,
          equals(PdfColor.fromHex('#000000')));
      expect(container.decoration?.border?.left.width, equals(1.0));
      expect(
          container.decoration?.border?.left.style, equals(BorderStyle.solid));
      expect(padding?.left, equals(8.0));
      expect(padding?.right, equals(8.0));
      expect(padding?.top, equals(16.0));
      expect(padding?.bottom, equals(16.0));
      expect(margin?.left, equals(16.0));
      expect(margin?.right, equals(16.0));
      expect(margin?.top, equals(32.0));
      expect(margin?.bottom, equals(32.0));
      expect(container.child, isA<Align>());
      Align align = container.child as Align;
      expect((align.child as Text).text.toPlainText(), equals('Hello, world!'));
    });

    test(
        'getWidget returns a Container with default properties when widget is empty',
        () {
      final jsonContainer = JSONContainer({});
      Widget container = jsonContainer.getWidget();
      expect(container, isA<Container>());
      container = container as Container;
      expect(container.decoration, isNull);
      expect(container.padding, equals(EdgeInsets.zero));
      expect(container.margin, equals(EdgeInsets.zero));
      expect(container.child, isNull);
    });

    test('getPadding returns an EdgeInsets with the correct properties', () {
      final jsonContainer = JSONContainer({
        'padding': [8.0, 16.0, 8.0, 16.0]
      });
      final padding = jsonContainer.getPadding();
      expect(padding.left, equals(8.0));
      expect(padding.right, equals(8.0));
      expect(padding.top, equals(16.0));
      expect(padding.bottom, equals(16.0));
    });

    test('getMargin returns an EdgeInsets with the correct properties', () {
      final jsonContainer = JSONContainer({
        'margin': [16.0, 32.0, 16.0, 32.0]
      });
      final margin = jsonContainer.getMargin();
      expect(margin.left, equals(16.0));
      expect(margin.right, equals(16.0));
      expect(margin.top, equals(32.0));
      expect(margin.bottom, equals(32.0));
    });

    test('getWidth returns a double with the correct value', () {
      final jsonContainer = JSONContainer({'width': 200.0});
      final width = jsonContainer.getWidth();
      expect(width, equals(200.0));
    });

    test('getHeight returns a double with the correct value', () {
      final jsonContainer = JSONContainer({'height': 100.0});
      final height = jsonContainer.getHeight();
      expect(height, equals(100.0));
    });

    test('getDecoration returns a JSONDecoration with the correct properties',
        () {
      final jsonContainer = JSONContainer({
        'decoration': {
          'color': '#ff0000',
          'border': {
            'left': {'color': '#000000', 'width': 1.0, 'style': 'solid'},
            'right': {'color': '#000000', 'width': 0.0, 'style': 'solid'},
            'top': {'color': '#000000', 'width': 1.0, 'style': 'solid'},
            'bottom': {'color': '#000000', 'width': 1.0, 'style': 'solid'},
          },
        },
      });
      final decoration = jsonContainer.getDecoration();
      expect(decoration, isA<JSONDecoration>());
    });

    test('getChild returns a Text widget when child is a Map with type "text"',
        () {
      final jsonContainer = JSONContainer({
        'child': {'type': 'text', 'content': 'Hello, world!'}
      });
      final child = jsonContainer.getChild() as Align;
      expect((child.child as Text).text.toPlainText(), equals('Hello, world!'));
    });

    test('getChild returns null when child is not a Map', () {
      final jsonContainer = JSONContainer({'child': 'invalid'});
      final child = jsonContainer.getChild();
      expect(child, isNull);
    });

    test('_getChild returns null when child is a Map with an invalid type', () {
      final jsonContainer = JSONContainer({
        'child': {'type': 'invalid', 'content': 'Hello, world!'}
      });
      expect(() => jsonContainer.getChild(), throwsException);
    });
  });

  group('JSONRow', () {
    late JSONRow jsonRow;

    setUp(() {
      jsonRow = JSONRow({
        'mainAxisAlignment': 'center',
        'crossAxisAlignment': 'stretch',
        'verticalDirection': 'up',
        'children': [
          {'type': 'text', 'content': 'Hello'},
          {'type': 'text', 'content': 'World'},
        ],
      });
    });

    test('getWidget returns Row widget with correct properties', () {
      final widget = jsonRow.getWidget() as Row;
      expect(widget, isA<Row>());
      expect(widget.mainAxisAlignment, equals(MainAxisAlignment.center));
      expect(widget.crossAxisAlignment, equals(CrossAxisAlignment.stretch));
      expect(widget.verticalDirection, equals(VerticalDirection.up));
      expect(widget.children.length, equals(2));
      expect(widget.children[0], isA<Align>());
      Align align = widget.children[0] as Align;
      expect((align.child as Text).text.toPlainText(), equals('Hello'));
      expect(widget.children[1], isA<Align>());
      Align align2 = widget.children[1] as Align;
      expect((align2.child as Text).text.toPlainText(), equals('World'));
    });

    test('getWidget returns Row widget with default properties', () {
      final widget = JSONRow({}).getWidget() as Row;
      expect(widget, isA<Row>());
      expect(widget.mainAxisAlignment, equals(MainAxisAlignment.start));
      expect(widget.crossAxisAlignment, equals(CrossAxisAlignment.start));
      expect(widget.verticalDirection, equals(VerticalDirection.down));
      expect(widget.children.length, equals(0));
    });
  });

  group('JSONColumn', () {
    late JSONColumn jsonColumn;

    setUp(() {
      jsonColumn = JSONColumn({
        'mainAxisAlignment': 'center',
        'crossAxisAlignment': 'stretch',
        'verticalDirection': 'up',
        'children': [
          {'type': 'text', 'content': 'Hello'},
          {'type': 'text', 'content': 'World'},
        ],
      });
    });

    test('getWidget returns Row widget with correct properties', () {
      final widget = jsonColumn.getWidget() as Column;
      expect(widget, isA<Column>());
      expect(widget.mainAxisAlignment, equals(MainAxisAlignment.center));
      expect(widget.crossAxisAlignment, equals(CrossAxisAlignment.stretch));
      expect(widget.verticalDirection, equals(VerticalDirection.up));
      expect(widget.children.length, equals(2));
      expect(widget.children[0], isA<Align>());
      Align align = widget.children[0] as Align;
      expect((align.child as Text).text.toPlainText(), equals('Hello'));
      expect(widget.children[1], isA<Align>());
      Align align2 = widget.children[1] as Align;
      expect((align2.child as Text).text.toPlainText(), equals('World'));
    });

    test('getWidget returns Row widget with default properties', () {
      final widget = JSONColumn({}).getWidget() as Column;
      expect(widget, isA<Column>());
      expect(widget.mainAxisAlignment, equals(MainAxisAlignment.start));
      expect(widget.crossAxisAlignment, equals(CrossAxisAlignment.start));
      expect(widget.verticalDirection, equals(VerticalDirection.down));
      expect(widget.children.length, equals(0));
    });
  });
}
