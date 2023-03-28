import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class GenerateDocumentsAlert extends StatefulWidget {
  const GenerateDocumentsAlert({super.key});

  @override
  State<GenerateDocumentsAlert> createState() => _GenerateDocumentsAlertState();
}

class _GenerateDocumentsAlertState extends State<GenerateDocumentsAlert> {
  final _intershipContract = true;
  bool _intershipCard = false;
  bool _cnesstForm = false;
  bool _studentIdentificationForm = false;
  bool _photosForm = false;
  bool _taxeCreditForm = false;
  bool _insuranceProof = false;

  void _generatePdfs() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Center(
          child: pw.Text('Hello World!'),
        ),
      ),
    );

    showDialog(
        context: context,
        builder: (context) => PdfPreview(
              maxPageWidth: 200,
              build: (format) => pdf.save(),
            ));
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
            CheckboxListTile(
                value: _intershipContract,
                enabled: false,
                onChanged: null,
                title: const Text('Contrat de stage')),
            CheckboxListTile(
                value: _intershipCard,
                onChanged: (value) => setState(() => _intershipCard = value!),
                title: const Text(
                    'Demande de carte de stage au Club paritaire de l’automobile')),
            CheckboxListTile(
                value: _cnesstForm,
                onChanged: (value) => setState(() => _cnesstForm = value!),
                title: const Text('Fiche CNESST')),
            CheckboxListTile(
                value: _studentIdentificationForm,
                onChanged: (value) =>
                    setState(() => _studentIdentificationForm = value!),
                title: const Text('Fiche d\'identification du stagiaire')),
            CheckboxListTile(
                value: _photosForm,
                onChanged: (value) => setState(() => _photosForm = value!),
                title: const Text(
                    'Formulaire d\'autorisation de prise de photos')),
            CheckboxListTile(
                value: _taxeCreditForm,
                onChanged: (value) => setState(() => _taxeCreditForm = value!),
                title: const Text('Formulaire pour le crédit d\'impôts')),
            CheckboxListTile(
                value: _insuranceProof,
                onChanged: (value) => setState(() => _insuranceProof = value!),
                title: const Text('Prevue de couverture d\'assurances')),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: _generatePdfs, child: const Text('Confirmer'))
      ],
    );
  }
}
