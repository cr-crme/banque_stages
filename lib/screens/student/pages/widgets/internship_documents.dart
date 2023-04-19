import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '/common/models/internship.dart';
import '/screens/internship_forms/generate_documents.dart';

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
                GestureDetector(
                  onTap: () {
                    debugPrint('coucou');
                    PdfPreview(
                      allowPrinting: true,
                      allowSharing: true,
                      canChangeOrientation: false,
                      canChangePageFormat: false,
                      canDebug: false,
                      build: (format) {
                        return GenerateDocuments.generateInternshipCardPdf(
                            format);
                      },
                    );
                  },
                  child: const Text('coucou'),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
