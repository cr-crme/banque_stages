import 'dart:typed_data';

import 'package:pdf/widgets.dart' as pw;

class GenerateDocuments {
  static Future<Uint8List> generateIntershipContractPdf(format) async {
    final document = pw.Document();

    document.addPage(
      pw.Page(
        build: (pw.Context context) =>
            pw.Center(child: pw.Text('Contrat de stage')),
      ),
    );

    return document.save();
  }

  static Future<Uint8List> generateInternshipCardPdf(format) async {
    final document = pw.Document();

    document.addPage(
      pw.Page(
        build: (pw.Context context) =>
            pw.Center(child: pw.Text('Carte étudiante')),
      ),
    );

    return document.save();
  }

  static Future<Uint8List> generateCnesstPdf(format) async {
    final document = pw.Document();

    document.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Center(child: pw.Text('CNESST')),
      ),
    );

    return document.save();
  }

  static Future<Uint8List> generateStudentIdentificationPdf(format) async {
    final document = pw.Document();

    document.addPage(
      pw.Page(
        build: (pw.Context context) =>
            pw.Center(child: pw.Text('Identification du stagiaire')),
      ),
    );

    return document.save();
  }

  static Future<Uint8List> generatePhotoAutorisationPdf(format) async {
    final document = pw.Document();

    document.addPage(
      pw.Page(
        build: (pw.Context context) =>
            pw.Center(child: pw.Text('Autorisation de prise de photos')),
      ),
    );

    return document.save();
  }

  static Future<Uint8List> generateTaxeCreditFormPdf(format) async {
    final document = pw.Document();

    document.addPage(
      pw.Page(
        build: (pw.Context context) =>
            pw.Center(child: pw.Text('Crédit d\'impôts')),
      ),
    );

    return document.save();
  }

  static Future<Uint8List> generateInsurancePdf(format) async {
    final document = pw.Document();

    document.addPage(
      pw.Page(
        build: (pw.Context context) =>
            pw.Center(child: pw.Text('Contrat d\'assurances')),
      ),
    );

    return document.save();
  }
}
