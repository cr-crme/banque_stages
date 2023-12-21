import 'dart:convert';
import 'package:crcrme_banque_stages/screens/student/JsonToPdf/package/json_widget.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:crcrme_banque_stages/common/models/internship.dart';

class GenerateDocuments {
  Future<pw.Document> generatePdfFromJson(String jsonString) async {
    var jsonData = json.decode(jsonString);
    pw.Document pdf = pw.Document();

    for (var page in jsonData['pages']) {
      pdf.addPage(
        pw.MultiPage(
          build: (pw.Context context) => [
            for (var element in page['elements'])
              JSONWidget.createWidget(element),
          ],
          footer: (pw.Context context) {
            final format = DateFormat('yyyy-MM-dd');
            final date = format.format(DateTime.now());
            return pw.Container(
              alignment: pw.Alignment.centerRight,
              margin: const pw.EdgeInsets.all(10),
              child: pw.Text(
                'Page ${context.pageNumber} de ${context.pagesCount} - $date',
              ),
            );
          },
        ),
      );
    }
    return pdf;
  }

  static Future<Uint8List> generateInternshipContractPdf(format,
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
      {required Internship internship,
      required Future<String> Function(String) preprocessJsonCallback,
      required BuildContext context}) async {
    String jsonString = await rootBundle
        .loadString('assets/documents/internship_automotive_card.json');
    String processedJsonString = await preprocessJsonCallback(jsonString);
    final document =
        await GenerateDocuments().generatePdfFromJson(processedJsonString);

    return document.save();
  }

  static Future<Uint8List> generateCnesstPdf(format,
      {required Internship internship,
      required Future<String> Function(String) preprocessJsonCallback,
      required BuildContext context}) async {
    String jsonString =
        await rootBundle.loadString('assets/documents/cnesst.json');
    String processedJsonString = await preprocessJsonCallback(jsonString);
    final document =
        await GenerateDocuments().generatePdfFromJson(processedJsonString);

    return document.save();
  }

  static Future<Uint8List> generateStudentIdentificationPdf(format,
      {required Internship internship,
      required Future<String> Function(String) preprocessJsonCallback,
      required BuildContext context}) async {
    String jsonString = await rootBundle
        .loadString('assets/documents/student_identification.json');
    String processedJsonString = await preprocessJsonCallback(jsonString);
    final document =
        await GenerateDocuments().generatePdfFromJson(processedJsonString);

    return document.save();
  }

  static Future<Uint8List> generatePhotoAutorisationPdf(format,
      {required Internship internship,
      required Future<String> Function(String) preprocessJsonCallback,
      required BuildContext context}) async {
    String jsonString =
        await rootBundle.loadString('assets/documents/photo_autorisation.json');
    String processedJsonString = await preprocessJsonCallback(jsonString);
    final document =
        await GenerateDocuments().generatePdfFromJson(processedJsonString);

    return document.save();
  }

  static Future<Uint8List> generateTaxeCreditFormPdf(format,
      {required Internship internship,
      required Future<String> Function(String) preprocessJsonCallback,
      required BuildContext context}) async {
    String jsonString =
        await rootBundle.loadString('assets/documents/taxe_credit_form.json');
    String processedJsonString = await preprocessJsonCallback(jsonString);
    final document =
        await GenerateDocuments().generatePdfFromJson(processedJsonString);

    return document.save();
  }

  static Future<Uint8List> generateInsurancePdf(format,
      {required Internship internship,
      required Future<String> Function(String) preprocessJsonCallback,
      required BuildContext context}) async {
    String jsonString =
        await rootBundle.loadString('assets/documents/insurance.json');
    String processedJsonString = await preprocessJsonCallback(jsonString);
    final document =
        await GenerateDocuments().generatePdfFromJson(processedJsonString);

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

  static Future<Uint8List> generateInternshipDescriptionPdf(format,
      {required Internship internship,
      required Future<String> Function(String) preprocessJsonCallback,
      required BuildContext context}) async {
    String jsonString = await rootBundle
        .loadString('assets/documents/internship_description.json');
    String processedJsonString = await preprocessJsonCallback(jsonString);
    final document =
        await GenerateDocuments().generatePdfFromJson(processedJsonString);

    return document.save();
  }
}
