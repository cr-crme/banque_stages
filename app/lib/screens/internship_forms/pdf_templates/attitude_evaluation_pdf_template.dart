part of 'package:crcrme_banque_stages/screens/internship_forms/pdf_templates/generate_documents.dart';

Future<Uint8List> _generateAttitudeEvaluationPdf(
    BuildContext context, PdfPageFormat format,
    {required String internshipId, required int evaluationIndex}) async {
  _logger.info(
      'Generating attitude evaluation PDF for internship: $internshipId, '
      'evaluation index: $evaluationIndex');

  final document = pw.Document();

  final internship =
      InternshipsProvider.of(context, listen: false).fromId(internshipId);

  document.addPage(
    pw.Page(
      build: (pw.Context context) => pw.Center(
          child: pw.Text('Évaluation des attitudes et comportements du '
              '${DateFormat('yMd', 'fr_CA').format(internship.attitudeEvaluations[evaluationIndex].date)}')),
    ),
  );

  return document.save();
}
