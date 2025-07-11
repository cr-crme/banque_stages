import 'dart:typed_data';

import 'package:common/models/internships/internship.dart';
import 'package:crcrme_banque_stages/screens/internship_forms/generate_documents.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class InternshipDocuments extends StatefulWidget {
  const InternshipDocuments({super.key, required this.internship});

  final Internship internship;

  @override
  State<InternshipDocuments> createState() => _InternshipDocumentsState();
}

class _InternshipDocumentsState extends State<InternshipDocuments> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    try {
      return Padding(
        padding: const EdgeInsets.only(left: 24, right: 24),
        child: ExpansionPanelList(
          elevation: 0,
          expansionCallback: (index, isExpanded) =>
              setState(() => _isExpanded = !_isExpanded),
          children: [
            ExpansionPanel(
              isExpanded: _isExpanded,
              canTapOnHeader: true,
              headerBuilder: (context, isExpanded) => Text('Documents',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(color: Colors.black)),
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...List.generate(
                    widget.internship.nbVersions,
                    (index) => _buildPdfTile(
                      context,
                      title: 'Contrat de stage - Version du '
                          '${DateFormat('yMd', 'fr_CA').format(widget.internship.creationDateFrom(index))}',
                      pdfGeneratorCallback: (format, {required internship}) =>
                          GenerateDocuments.generateInternshipContractPdf(
                              format,
                              internship: internship,
                              versionIndex: index),
                    ),
                  ),
                  _buildEvaluations(
                      title: 'Évaluation des compétences',
                      evaluations: widget.internship.skillEvaluations,
                      pdfGeneratorCallback:
                          GenerateDocuments.generateSkillEvaluationPdf),
                  _buildEvaluations(
                      title: 'Évaluation des attitudes et comportements',
                      evaluations: widget.internship.attitudeEvaluations,
                      pdfGeneratorCallback:
                          GenerateDocuments.generateAttitudeEvaluationPdf),
                  _buildPdfTile(
                    context,
                    title: 'VISA',
                    pdfGeneratorCallback: GenerateDocuments.generateVisaPdf,
                  ),
                ],
              ),
            )
          ],
        ),
      );
    } catch (e) {
      return SizedBox(
        height: 60,
        child: Center(
            child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor)),
      );
    }
  }

  Widget _buildPdfTile(
    BuildContext context, {
    required String title,
    required Future<Uint8List> Function(PdfPageFormat format,
            {required Internship internship})
        pdfGeneratorCallback,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => showDialog(
              context: context,
              builder: (ctx) => PdfPreview(
                    allowPrinting: true,
                    allowSharing: true,
                    canChangeOrientation: false,
                    canChangePageFormat: false,
                    canDebug: false,
                    build: (format) => pdfGeneratorCallback(format,
                        internship: widget.internship),
                  )),
          child: Text(
            title,
            style: const TextStyle(
                color: Colors.blue, decoration: TextDecoration.underline),
          ),
        ),
      ),
    );
  }

  Widget _buildEvaluations(
      {required String title,
      evaluations,
      required Future<Uint8List> Function(PdfPageFormat format,
              {required Internship internship, required int evaluationIndex})
          pdfGeneratorCallback}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title),
          Padding(
            padding: const EdgeInsets.only(left: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (evaluations.isEmpty) const Text('Aucune évalution'),
                if (evaluations.isNotEmpty)
                  ...evaluations.asMap().keys.map(
                        (index) => _buildPdfTile(
                          context,
                          title: 'Formulaire du '
                              '${DateFormat('yMd', 'fr_CA').format(evaluations[index].date)}',
                          pdfGeneratorCallback: (format,
                                  {required internship}) =>
                              pdfGeneratorCallback(format,
                                  internship: internship,
                                  evaluationIndex: index),
                        ),
                      ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
