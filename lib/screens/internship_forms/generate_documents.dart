import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;

import '/common/models/internship.dart';

class GenerateDocuments {
  static Future<Uint8List> generateIntershipContractPdf(format,
      {required Internship internship, required int versionIndex}) async {
    final document = pw.Document();

    document.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Center(
            child: pw.Text('Contrat de stage pour le stage de '
                '${DateFormat('yMd', 'fr_CA').format(internship.versionDateFrom(versionIndex))}')),
      ),
    );

    return document.save();
  }

  static Future<Uint8List> generateInternshipAutomotiveCardPdf(format,
      {required Internship internship}) async {
    final document = pw.Document();

    document.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Center(
            child: pw.Text(
                'Carte de stage pour le Club paritaire de l\'automobile')),
      ),
    );

    return document.save();
  }

  static Future<Uint8List> generateCnesstPdf(format,
      {required Internship internship}) async {
    final document = pw.Document();

    document.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Center(child: pw.Text('CNESST')),
      ),
    );

    return document.save();
  }

  static Future<Uint8List> generateStudentIdentificationPdf(format,
      {required Internship internship}) async {
    final document = pw.Document();

    document.addPage(
      pw.Page(
        build: (pw.Context context) =>
            pw.Center(child: pw.Text('Identification du stagiaire')),
      ),
    );

    return document.save();
  }

  static Future<Uint8List> generatePhotoAutorisationPdf(format,
      {required Internship internship}) async {
    final document = pw.Document();

    document.addPage(
      pw.Page(
        build: (pw.Context context) =>
            pw.Center(child: pw.Text('Autorisation de prise de photos')),
      ),
    );

    return document.save();
  }

  static Future<Uint8List> generateTaxeCreditFormPdf(format,
      {required Internship internship}) async {
    final document = pw.Document();

    document.addPage(
      pw.Page(
        build: (pw.Context context) =>
            pw.Center(child: pw.Text('Crédit d\'impôts')),
      ),
    );

    return document.save();
  }

  static Future<Uint8List> generateInsurancePdf(format,
      {required Internship internship}) async {
    final document = pw.Document();

    document.addPage(
      pw.Page(
        build: (pw.Context context) =>
            pw.Center(child: pw.Text('Contrat d\'assurances')),
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
                'Évaluation de l\'attitude du ${DateFormat('yMd', 'fr_CA').format(internship.attitudeEvaluations[evaluationIndex].date)}')),
      ),
    );

    return document.save();
  }
}
