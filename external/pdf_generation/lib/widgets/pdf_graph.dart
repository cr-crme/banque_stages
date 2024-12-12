import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfGraph extends pw.StatelessWidget {
  PdfGraph({
    this.legend,
    required this.labels,
    required this.data,
    this.barWidth = 10.0,
    this.maxHeight = double.infinity,
    this.colors = const [
      PdfColors.blue,
      PdfColors.green,
      PdfColors.purple,
      PdfColors.amber,
      PdfColors.orange,
    ],
  });

  final List<String>? legend;
  final List<String> labels;
  final List<List<double>> data;
  final double barWidth;
  final double maxHeight;
  final List<PdfColor> colors;

  @override
  pw.Widget build(pw.Context context) {
    final int categoryCount = labels.length;
    final int dataCount = legend?.length ?? data.length;

    if (data.length != dataCount) {
      throw Exception('Legend and data must have the same length');
    }
    for (final row in data) {
      if (row.length != categoryCount) {
        throw Exception('Values must have the same length as labels');
      }
    }
    if (colors.length < dataCount) {
      throw Exception('Not enough colors');
    }

    final titleHeight = legend == null ? 0.0 : 30.0;
    return pw.SizedBox(
        height: maxHeight + titleHeight,
        child: pw.Chart(
          title: legend == null
              ? null
              : pw.ChartLegend(
                  direction: pw.Axis.horizontal,
                  textStyle: const pw.TextStyle(fontSize: 8),
                  position: const pw.Alignment(-.7, 1),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.white,
                    border: pw.Border.all(
                      color: PdfColors.black,
                      width: .5,
                    ),
                  ),
                ),
          grid: pw.CartesianGrid(
            xAxis: pw.FixedAxis.fromStrings(
              labels,
              marginStart: 30,
              marginEnd: 30,
              ticks: true,
              textStyle: const pw.TextStyle(fontSize: 8),
            ),
            yAxis: pw.FixedAxis([0, 1, 2, 3, 4], divisions: true),
          ),
          datasets: [
            ...data.asMap().keys.map((i) => pw.BarDataSet(
                  color: colors[i],
                  width: barWidth,
                  offset:
                      (i - dataCount ~/ 2 + (dataCount % 2 == 0 ? 0.5 : 0.0)) *
                          barWidth,
                  legend: legend?[i],
                  data: List<pw.PointChartValue>.generate(
                    data[i].length,
                    (j) => pw.PointChartValue(j.toDouble(), data[i][j]),
                  ),
                ))
          ],
        ));
  }
}
