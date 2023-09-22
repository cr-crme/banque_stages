import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:crcrme_banque_stages/common/models/internship.dart';

class GenerateDocuments {
  Future<pw.Document> generatePdfFromJson(String jsonString) async {
    var jsonData = json.decode(jsonString);
    pw.Document pdf = pw.Document();

    for (var page in jsonData['pages']) {
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            List<pw.Widget> widgets = [];

            for (var element in page['elements']) {
              if (element['type'] == 'Container') {
                widgets.add(_createContainer(element));
              } else if (element['type'] == 'SizedBox') {
                widgets.add(pw.SizedBox(height: element['height'].toDouble()));
              } else if (element['type'] == 'Text') {
                widgets.add(_createText(element));
              }
            }
            return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: widgets);
          },
        ),
      );
    }
    return pdf;
  }

  pw.Container _createContainer(element) {
    List<pw.Widget> children = [];
    for (var child in element['children']) {
      if (child['type'] == 'Text') {
        children.add(_createText(child));
      }
    }
    return pw.Container(
      alignment: _getAlignment(element['alignment']),
      padding: pw.EdgeInsets.fromLTRB(
          element['padding'][0].toDouble(),
          element['padding'][1].toDouble(),
          element['padding'][2].toDouble(),
          element['padding'][3].toDouble()),
      decoration: _getDecoration(element['decoration']),
      child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start, children: children),
    );
  }

  pw.Text _createText(Map<String, dynamic> element) {
    return pw.Text(element['text'], style: _getTextStyle(element['style']));
  }

  pw.TextStyle _getTextStyle(Map<String, dynamic>? style) {
    if (style == null) return const pw.TextStyle();
    return pw.TextStyle(
      fontWeight: style['fontWeight'] == 'bold'
          ? pw.FontWeight.bold
          : pw.FontWeight.normal,
    );
  }

  pw.Alignment _getAlignment(alignment) {
    switch (alignment) {
      case 'topLeft':
        return pw.Alignment.topLeft;
      default:
        return pw.Alignment.topLeft;
    }
  }

  pw.BoxDecoration _getDecoration(decoration) {
    switch (decoration) {
      case 'border':
        return pw.BoxDecoration(border: pw.Border.all());
      case 'bottomBorder':
        return const pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide()));
      default:
        return const pw.BoxDecoration();
    }
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
    String jsonString =
        await rootBundle.loadString('assets/documents/cnesst.json');

    final document = await GenerateDocuments().generatePdfFromJson(jsonString);
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
                'Évaluation des attitudes et comportements du ${DateFormat('yMd', 'fr_CA').format(internship.attitudeEvaluations[evaluationIndex].date)}')),
      ),
    );

    return document.save();
  }
}
