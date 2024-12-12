import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class HalfPage extends pw.StatelessWidget {
  HalfPage({required this.left, required this.right, this.separatorSize});

  pw.Widget left;
  pw.Widget right;
  Size? separatorSize;

  @override
  pw.Widget build(pw.Context context) {
    return pw.FullPage(
        ignoreMargins: true,
        child: pw.LayoutBuilder(
            builder: (context, constraints) => pw.Stack(
                  children: [
                    pw.Positioned(
                        child: pw.SizedBox(
                            width: constraints!.maxWidth / 2, child: left)),
                    if (separatorSize != null)
                      pw.Positioned(
                          left: constraints.maxWidth / 2 - separatorSize!.width,
                          child: pw.SizedBox(
                              width: separatorSize!.width,
                              height: separatorSize!.height,
                              child: pw.Container(color: PdfColors.grey200))),
                    pw.Positioned(
                        left: constraints.maxWidth / 2,
                        child: pw.SizedBox(
                            width: constraints.maxWidth / 2, child: right)),
                  ],
                )));
  }
}
