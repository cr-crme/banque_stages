import 'package:crcrme_banque_stages/screens/student/JsonToPdf/package/json_decoration.dart';
import 'package:pdf/widgets.dart'
    show
        TableHelper,
        Widget,
        EdgeInsets,
        Alignment,
        TableBorder,
        TableColumnWidth,
        FixedColumnWidth,
        BoxDecoration;
import '../utilities/utilitaire.dart';
import 'json_widget.dart';
import 'json_border.dart';

class JSONTable extends JSONWidget {
  final Map<String, dynamic> _table;
  JSONTable(this._table) : super(_table);

  @override
  Widget getWidget() {
    final data = getData();

    final cellPadding = getCellPadding();
    final cellHeight = getCellHeight();
    final cellAlignment = getCellAlignment();
    final headerPadding = this.headerPadding();
    final headerHeight = this.headerHeight();
    final headerAlignment = this.headerAlignment();
    final border = getBorder();
    final columnWidths = getColumnWidths();
    final headers = this.headers;
    final headerDecoration = this.headerDecoration();

    return TableHelper.fromTextArray(
      data: data,
      columnWidths: columnWidths,
      headers: headers,
      cellPadding: cellPadding,
      cellHeight: cellHeight ?? 0,
      cellAlignment: cellAlignment,
      headerPadding: headerPadding,
      headerHeight: headerHeight,
      headerAlignment: headerAlignment,
      border: border,
      headerDecoration: headerDecoration,
    );
  }

  EdgeInsets getCellPadding() => Utilitaire.getEdge(_table['cellPadding']);
  double? getCellHeight() => Utilitaire.getNumber(_table['cellHeight']);
  Alignment getCellAlignment() =>
      Utilitaire.getAlignment(_table['cellAlignment']);
  int getHeadCount() => Utilitaire.getNumber(_table['headCount'])?.toInt() ?? 1;
  EdgeInsets headerPadding() => Utilitaire.getEdge(_table['headerPadding']);
  double? headerHeight() => Utilitaire.getNumber(_table['headerHeight']);
  Alignment headerAlignment() =>
      Utilitaire.getAlignment(_table['headerAlignment']);
  TableBorder getBorder() =>
      JSONBorder(_table['border']).getTableBorder() ?? const TableBorder();

  List<List<dynamic>> getData() {
    final data = _table['data'];
    if (data is List<dynamic>) {
      return data.map((e) => e as List<dynamic>).toList();
    } else {
      return [];
    }
  }

  Map<int, TableColumnWidth>? getColumnWidths() {
    final columnWidths = _table['columnWidths'];
    if (columnWidths is num) {
      final ret = <int, TableColumnWidth>{};
      for (var i = 0; i < getData()[0].length; i++) {
        ret.addAll({i: FixedColumnWidth(columnWidths.toDouble())});
      }
      return ret;
    }
    if (!columnWidths is List<dynamic>) {
      return null;
    }
    final liste = List<dynamic>.from(columnWidths);
    if (liste.every((e) => e is num)) {
      return columnWidths
          .map((e) =>
              FixedColumnWidth(Utilitaire.getNumber(e)?.toDouble() ?? 0.0))
          .toList();
    }
    return null;
  }

  List<String> get headers {
    final headers = _table['headers'];
    if (headers is List<dynamic>) {
      return headers.map((e) => e as String).toList();
    } else {
      return [];
    }
  }

  BoxDecoration? headerDecoration() {
    final headerDecoration = _table['headerDecoration'];
    if (headerDecoration is Map<String, dynamic>) {
      return JSONDecoration(headerDecoration).getBoxDecoration();
    } else {
      return null;
    }
  }
}
