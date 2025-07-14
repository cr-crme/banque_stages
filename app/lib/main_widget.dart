import 'package:crcrme_banque_stages/screens/internship_forms/generate_documents.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

void main() async {
  runApp(MaterialApp(
    home: Scaffold(
      body: MyWidget(),
    ),
  ));
}

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return PdfPreview(
      allowPrinting: true,
      allowSharing: true,
      canChangeOrientation: false,
      canChangePageFormat: false,
      canDebug: false,
      build: (format) => GenerateDocuments.generateInternshipContractPdf(
          context, format,
          internshipId: '0'),
    );
  }
}
