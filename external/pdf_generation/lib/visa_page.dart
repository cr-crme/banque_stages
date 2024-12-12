import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf_generation/widgets/half_page.dart';
import 'package:pdf_generation/widgets/pdf_graph.dart';
import 'package:printing/printing.dart';
import 'package:resizable_widget/resizable_widget.dart';

class VisaPage extends StatelessWidget {
  const VisaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ResizableWidget(
      separatorColor: Colors.black,
      separatorSize: 4,
      children: [
        _buildPdfController(),
        PdfPreview(
          build: (format) => _buildPage(format),
          initialPageFormat: PdfPageFormat.letter,
          useActions: false,
        ),
      ],
    );
  }
}

Widget _buildPdfController() {
  return Container(
    color: Colors.blueGrey,
  );
}

Future<Uint8List> _buildPage(PdfPageFormat format) async {
  final doc = pw.Document(title: 'MyPage', author: 'My Name');

  doc.addPage(
    pw.Page(
        pageTheme: await _myPageTheme(format),
        build: (pw.Context context) => HalfPage(
              left: _dummyLeftPage(context),
              right: _dummyRightPage(context),
            )),
  );

  doc.addPage(
    pw.Page(
        pageTheme: await _myPageTheme(format),
        build: (pw.Context context) => HalfPage(
              left: _dummyLeftPage(context),
              right: _dummyRightPage(context),
            )),
  );

  return doc.save();
}

Future<pw.PageTheme> _myPageTheme(PdfPageFormat format) async {
  final image = pw.MemoryImage(
      (await rootBundle.load('assets/background.png')).buffer.asUint8List());

  return pw.PageTheme(
    pageFormat: format.landscape,
    theme: pw.ThemeData.withFont(
      base: await PdfGoogleFonts.openSansRegular(),
      bold: await PdfGoogleFonts.openSansBold(),
      icons: await PdfGoogleFonts.materialIcons(),
    ),
    buildBackground: (pw.Context context) {
      return pw.FullPage(
        ignoreMargins: true,
        child: pw.Image(image, fit: pw.BoxFit.contain),
      );
    },
  );
}

pw.Widget _dummyLeftPage(pw.Context context) {
  return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 40),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.only(bottom: 20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Profil d\'employabilité',
                    style: pw.Theme.of(context).defaultTextStyle.copyWith(
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromHex("#FFFFFF"),
                        fontSize: 20)),
                pw.SizedBox(height: 40),
                pw.Text(
                    'Compétences spécifiques liées au métier semi-spécialisé',
                    style: pw.Theme.of(context).defaultTextStyle.copyWith(
                        fontWeight: pw.FontWeight.bold, fontSize: 10)),
                pw.SizedBox(height: 10),
                _EnumerationBlock(title: 'Préposé à la finition', elements: [
                  'Préparer le travail de ponçage.',
                  'Corriger des défauts mineurs sur les surfaces à poncer.',
                  'Poncer à la main des composantes ayant une surface régulière ou irrégulière.',
                  'Poncer, avec un outil portatif, des composantes ayant une surface régulière ou irrégulière.',
                  'Poncer des composantes ayant une surface régulière avec une machine-outil.',
                  'Vérifier la qualité du ponçage.',
                  'Faire la mise en teinte.',
                  'Entretenir l\'aire de travail et l\'équipement.',
                ]),
                pw.SizedBox(height: 12),
                _EnumerationBlock(title: 'Certificats', elements: [
                  'Préposé à la finition',
                ]),
              ],
            ),
          ),
        ],
      ));
}

pw.Widget _dummyRightPage(pw.Context context) {
  return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 40),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            padding: const pw.EdgeInsets.only(bottom: 20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Align(
                    alignment: pw.Alignment.centerRight,
                    child: pw.Text('Évaluation',
                        style: pw.Theme.of(context).defaultTextStyle.copyWith(
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColor.fromHex("#FFFFFF"),
                            fontSize: 20))),
                pw.SizedBox(height: 40),
                pw.Text(
                    'Compétences spécifiques liées au métier semi-spécialisé',
                    style: pw.Theme.of(context).defaultTextStyle.copyWith(
                        fontWeight: pw.FontWeight.bold, fontSize: 10)),
                pw.SizedBox(height: 10),
                PdfGraph(
                  labels: const [
                    'Ponctualité',
                    'Assiduité',
                    'Respect de\nla production\nattendue',
                    'Adaptation au\nchangement',
                    'Qualité du\ntravail'
                  ],
                  legend: const ['Février 2020', 'Avril 2020', 'Juin 2020'],
                  data: const [
                    [3.0, 3.0, 4.0, 3.0, 3.0],
                    [3.0, 3.0, 3.0, 4.0, 3.0],
                    [4.0, 4.0, 4.0, 3.0, 4.0],
                  ],
                  maxHeight: 100,
                ),
                pw.SizedBox(height: 20),
                PdfGraph(
                  labels: const [
                    'Respect des\ncollègues',
                    'Respect de\nl\'autorité',
                    'Communication\nefficace',
                    'Maitrise de soi'
                  ],
                  data: const [
                    [3.0, 4.0, 3.0, 3.0],
                    [3.0, 4.0, 3.0, 2.0],
                    [4.0, 4.0, 3.0, 3.0],
                  ],
                  maxHeight: 100,
                ),
              ],
            ),
          ),
        ],
      ));
}

class _EnumerationBlock extends pw.StatelessWidget {
  _EnumerationBlock({
    required this.title,
    required this.elements,
  });

  final String title;
  final List<String> elements;

  @override
  pw.Widget build(pw.Context context) {
    return pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: <pw.Widget>[
          pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: <pw.Widget>[
                pw.Container(
                  width: 6,
                  height: 6,
                  margin: const pw.EdgeInsets.only(top: 5.5, left: 2, right: 5),
                  decoration: const pw.BoxDecoration(
                    color: PdfColor.fromInt(0),
                    shape: pw.BoxShape.circle,
                  ),
                ),
                pw.Text(title,
                    style: pw.Theme.of(context).defaultTextStyle.copyWith(
                        fontWeight: pw.FontWeight.bold, fontSize: 10)),
              ]),
          pw.Container(
            decoration: const pw.BoxDecoration(
                border: pw.Border(
                    left: pw.BorderSide(
                        color: PdfColor(0.7, 0.7, 0.7), width: 2))),
            padding: const pw.EdgeInsets.only(left: 10, top: 5, bottom: 5),
            margin: const pw.EdgeInsets.only(left: 5),
            child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: elements
                    .map((String element) => pw.Text('\u2022 $element',
                        style: pw.Theme.of(context)
                            .defaultTextStyle
                            .copyWith(fontSize: 8)))
                    .toList()),
          ),
        ]);
  }
}

Future<Uint8List> createLandscapePdf(PdfPageFormat format) async {
  // Load the SVG file as a string
  final svgRawData = await rootBundle.loadString('assets/background.svg');

  // Create a new PDF document
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.letter,
      orientation: pw.PageOrientation.landscape,
      build: (context) {
        return pw.FullPage(
          ignoreMargins: true,
          child: pw.SvgImage(
            svg: svgRawData,
            fit: pw.BoxFit.contain,
          ),
        );
      },
    ),
  );

  // Save the PDF file

  return pdf.save();
}
