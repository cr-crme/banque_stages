part of 'package:crcrme_banque_stages/screens/internship_forms/generate_documents.dart';

final _textStyle = pw.TextStyle(font: pw.Font.times());
final _textStyleBold = pw.TextStyle(font: pw.Font.timesBold());

Future<Uint8List> _generateInternshipContractPdf(format,
    {required Internship internship, required int versionIndex}) async {
  final document = pw.Document();

  document.addPage(_coverPage());

  return document.save();
}

pw.Page _coverPage() {
  final schoolBoardName = 'CENTRE DE SERVICES SCOLAIRES DES AFFLUENTS';
  final dash = '-';

  return pw.Page(
      pageFormat: PdfPageFormat.letter,
      build: (context) => pw.Stack(children: [
            pw.Align(
                alignment: pw.Alignment.topLeft,
                child: pw.Container(
                    width: 150,
                    height: 80,
                    decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.black)),
                    child: pw.Center(child: pw.Text('LOGO')))),
            pw.Center(
                child: pw.Column(mainAxisSize: pw.MainAxisSize.min, children: [
              pw.Text('FORMATION PRÉPARATOIRE AU TRAVAIL',
                  style: _textStyle.copyWith(fontSize: 18)),
              pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 40.0),
                  child: pw.Container(
                    width: double.infinity,
                    decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.black),
                        color: PdfColors.grey300),
                    child: pw.Padding(
                        padding: const pw.EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 8.0),
                        child: pw.Column(children: [
                          pw.Text('CONTRAT DE STAGE',
                              style: _textStyleBold.copyWith(fontSize: 20)),
                          pw.SizedBox(height: 20),
                          pw.Text(
                            'ENTENTE ENTRE LES PARTIES',
                            style: _textStyle.copyWith(fontSize: 16),
                          ),
                          pw.Text(
                              '$schoolBoardName $dash ELEVE $dash ENTREPRISE $dash SUPERVISEUR DE STAGE $dash ECOLE',
                              style: _textStyle.copyWith(fontSize: 16),
                              textAlign: pw.TextAlign.center),
                        ])),
                  )),
            ])),
          ]));
}

    // pw.Page(
    //   build: (pw.Context context) => pw.Center(
    //       child: pw.Text('Contrat de stage pour le stage de '
    //           '${DateFormat('yMd', 'fr_CA').format(internship.creationDateFrom(versionIndex))}')),
    // ),