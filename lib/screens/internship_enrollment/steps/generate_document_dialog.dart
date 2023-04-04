import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class GenerateDocumentsAlert extends StatefulWidget {
  const GenerateDocumentsAlert({super.key});

  @override
  State<GenerateDocumentsAlert> createState() => _GenerateDocumentsAlertState();
}

class _PdfRadioTile {
  _PdfRadioTile({
    required this.title,
    required this.isChecked,
    this.canChangeCheck = true,
    required this.pdfGenerationCallback,
  });

  String title;
  bool isChecked;
  bool canChangeCheck;
  Future<Uint8List> Function(PdfPageFormat) pdfGenerationCallback;
}

class _GenerateDocumentsAlertState extends State<GenerateDocumentsAlert> {
  late final List<_PdfRadioTile> _pdfsRadio = [
    _PdfRadioTile(
      title: 'Contrat de stage',
      isChecked: true,
      canChangeCheck: false,
      pdfGenerationCallback: _generateIntershipContractPdf,
    ),
    _PdfRadioTile(
      title: 'Demande de carte de stage au Club paritaire de l\'automobile',
      isChecked: false,
      pdfGenerationCallback: _generateInternshipCardPdf,
    ),
    _PdfRadioTile(
      title: 'Fiche CNESST',
      isChecked: false,
      pdfGenerationCallback: _generateCnesstPdf,
    ),
    _PdfRadioTile(
      title: 'Fiche d\'identification du stagiaire',
      isChecked: false,
      pdfGenerationCallback: _generateStudentIdentificationPdf,
    ),
    _PdfRadioTile(
      title: 'Formulaire d\'autorisation de prise de photos',
      isChecked: false,
      pdfGenerationCallback: _generatePhotoAutorisationPdf,
    ),
    _PdfRadioTile(
      title: 'Formulaire pour le crédit d\'impôts',
      isChecked: false,
      pdfGenerationCallback: _generateTaxeCreditFormPdf,
    ),
    _PdfRadioTile(
      title: 'Prevue de couverture d\'assurances',
      isChecked: false,
      pdfGenerationCallback: _generateInsurancePdf,
    ),
  ];

  Future<Uint8List> _generateIntershipContractPdf(format) async {
    final document = pw.Document();

    document.addPage(
      pw.Page(
        build: (pw.Context context) =>
            pw.Center(child: pw.Text('Contrat de stage')),
      ),
    );

    return document.save();
  }

  Future<Uint8List> _generateInternshipCardPdf(format) async {
    final document = pw.Document();

    document.addPage(
      pw.Page(
        build: (pw.Context context) =>
            pw.Center(child: pw.Text('Carte étudiante')),
      ),
    );

    return document.save();
  }

  Future<Uint8List> _generateCnesstPdf(format) async {
    final document = pw.Document();

    document.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Center(child: pw.Text('CNESST')),
      ),
    );

    return document.save();
  }

  Future<Uint8List> _generateStudentIdentificationPdf(format) async {
    final document = pw.Document();

    document.addPage(
      pw.Page(
        build: (pw.Context context) =>
            pw.Center(child: pw.Text('Identification du stagiaire')),
      ),
    );

    return document.save();
  }

  Future<Uint8List> _generatePhotoAutorisationPdf(format) async {
    final document = pw.Document();

    document.addPage(
      pw.Page(
        build: (pw.Context context) =>
            pw.Center(child: pw.Text('Autorisation de prise de photos')),
      ),
    );

    return document.save();
  }

  Future<Uint8List> _generateTaxeCreditFormPdf(format) async {
    final document = pw.Document();

    document.addPage(
      pw.Page(
        build: (pw.Context context) =>
            pw.Center(child: pw.Text('Crédit d\'impôts')),
      ),
    );

    return document.save();
  }

  Future<Uint8List> _generateInsurancePdf(format) async {
    final document = pw.Document();

    document.addPage(
      pw.Page(
        build: (pw.Context context) =>
            pw.Center(child: pw.Text('Contrat d\'assurances')),
      ),
    );

    return document.save();
  }

  void _generateAllPdfs() async {
    for (final currentPdf in _pdfsRadio) {
      if (!currentPdf.isChecked) continue;

      await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => AlertDialog(
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 3 / 4,
                child: PdfPreview(
                  allowPrinting: true,
                  allowSharing: true,
                  canChangeOrientation: false,
                  canChangePageFormat: false,
                  canDebug: false,
                  build: currentPdf.pdfGenerationCallback,
                ),
              ),
              TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Prochain'))
            ],
          ),
        ),
      );
    }
    if (!mounted) return;

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Documents à générer'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
                'L\'élève a bien été inscrit comme stagiaire. Sélectionner '
                'les documents à générer pour ce stage'),
            ..._pdfsRadio
                .map(
                  (e) => CheckboxListTile(
                    value: e.isChecked,
                    enabled: e.canChangeCheck,
                    onChanged: e.canChangeCheck
                        ? (value) => setState(() => e.isChecked = value!)
                        : null,
                    title: Text(e.title),
                  ),
                )
                .toList(),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: _generateAllPdfs, child: const Text('Confirmer'))
      ],
    );
  }
}
