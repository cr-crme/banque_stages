import 'dart:typed_data';

import 'package:common/models/internships/internship.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;

class GenerateDocuments {
  static Future<Uint8List> generateInternshipContractPdf(format,
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

  static Future<Uint8List> generateVisaPdf(format,
      {required Internship internship}) async {
    final document = pw.Document();

    document.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Center(child: pw.Text('VISA')),
      ),
    );

    return document.save();
  }

  static Future<Uint8List> generateSkillEvaluationPdf(format,
      {required Internship internship, required int evaluationIndex}) async {
    final document = pw.Document();

    document.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Center(
            child: pw.Text(
                'Évaluation des compétences du ${DateFormat('yMd', 'fr_CA').format(internship.skillEvaluations[evaluationIndex].date)}')),
      ),
    );

    return document.save();
  }

  static Future<Uint8List> generateAttitudeEvaluationPdf(format,
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
}
