part of 'package:crcrme_banque_stages/screens/internship_forms/generate_documents.dart';

Future<Uint8List> _generateInternshipContractPdf(format,
    {required Internship internship, required int versionIndex}) async {
  final document = pw.Document();

  document.addPage(
    pw.Page(
      build: (pw.Context context) => pw.Center(
          child: pw.Text('Contrat de stage pour le stage de '
              '${DateFormat('yMd', 'fr_CA').format(internship.creationDateFrom(versionIndex))}')),
    ),
  );

  return document.save();
}
