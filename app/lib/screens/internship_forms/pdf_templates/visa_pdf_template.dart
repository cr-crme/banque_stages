part of 'package:crcrme_banque_stages/screens/internship_forms/pdf_templates/generate_documents.dart';

Future<Uint8List> _generateVisaPdf(BuildContext context, PdfPageFormat format,
    {required String internshipId}) async {
  _logger.info('Generating visa PDF for internship: $internshipId');

  final document = pw.Document();

  document.addPage(
    pw.Page(
      build: (pw.Context context) => pw.Center(child: pw.Text('VISA')),
    ),
  );

  return document.save();
}
