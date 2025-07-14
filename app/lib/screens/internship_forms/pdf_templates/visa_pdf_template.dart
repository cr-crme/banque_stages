part of 'package:crcrme_banque_stages/screens/internship_forms/generate_documents.dart';

Future<Uint8List> _generateVisaPdf(BuildContext context, PdfPageFormat format,
    {required String internshipId}) async {
  final document = pw.Document();

  document.addPage(
    pw.Page(
      build: (pw.Context context) => pw.Center(child: pw.Text('VISA')),
    ),
  );

  return document.save();
}
