import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:stagess/screens/internship_forms/pdf_templates/generate_documents.dart';
import 'package:stagess_common/models/internships/internship.dart';

final _logger = Logger('InternshipDocuments');

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
    _logger.finer(
        'Building InternshipDocuments for internship: ${widget.internship.id}');

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
                  _buildPdfTile(
                    context,
                    title: 'Contrat de stage',
                    pdfGeneratorCallback: (context, format,
                            {required internshipId}) =>
                        GenerateDocuments.generateInternshipContractPdf(
                            context, format,
                            internshipId: internshipId),
                  ),
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
    required Future<Uint8List> Function(
            BuildContext context, PdfPageFormat format,
            {required String internshipId})
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
                    build: (format) => pdfGeneratorCallback(context, format,
                        internshipId: widget.internship.id),
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
}
