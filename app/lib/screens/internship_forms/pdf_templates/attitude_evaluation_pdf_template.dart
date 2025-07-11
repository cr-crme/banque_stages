part of 'package:crcrme_banque_stages/screens/internship_forms/generate_documents.dart';

Future<Uint8List> _generateAttitudeEvaluationPdf(format,
    {required Internship internship, required int evaluationIndex}) async {
  final document = pw.Document();

  document.addPage(
    pw.Page(
      build: (pw.Context context) => pw.Center(
          child: pw.Text(
              'Évaluation des attitudes et comportements du ${DateFormat('yMd', 'fr_CA').format(internship.attitudeEvaluations[evaluationIndex].date)}')),
    ),
  );

  return document.save();
}
