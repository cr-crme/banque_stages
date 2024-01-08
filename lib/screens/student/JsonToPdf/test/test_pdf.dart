/*
 * Copyright (C) 2017, David PHAM-VAN <dev.nfet.net@gmail.com>
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import 'dart:convert';
import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart' show PdfPageFormat;
import '../package/json_widget.dart' show JSONWidget;

void main() async {
  String jsonString = File('./test.json').readAsStringSync();
  var jsonData = json.decode(jsonString);
  pw.Document pdf = pw.Document();
  for (var page in jsonData['pages']) {
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          List<pw.Widget> widgets = [];
          for (var element in page['elements']) {
            widgets.add(JSONWidget.createWidget(element));
          }

          // final data = [
          //   ['', '', '', '', '', '', '']
          // ];

          // final headers = [
          //   'lundi',
          //   'mardi',
          //   'mercredi',
          //   'jeudi',
          //   'vendredi',
          //   'samedi',
          //   'dimanche'
          // ];
          // pw.Container row = pw.Container(
          //     decoration: const pw.BoxDecoration(border: pw.TableBorder(
          //       bottom: BorderSide(width: 1, color: PdfColor.fromInt(0xff000000)),
          //       left: BorderSide(width: 1, color: PdfColor.fromInt(0xff000000)),
          //       top: BorderSide(width: 1, color: PdfColor.fromInt(0xff000000)),
          //     )),
          //     width: double.infinity,
          //     child: pw.Row(mainAxisSize: MainAxisSize.min, children: [
          //       pw.Container(
          //         child: pw.Text('Heures\nDe travail', textAlign: pw.TextAlign.center),
          //         padding: const pw.EdgeInsets.all(12)
          //       ),

          //       pw.TableHelper.fromTextArray(
          //           data: data,
          //           cellHeight: 60,
          //           headerHeight: 12,
          //           headers: headers,
          //           columnWidths: {
          //             0: const pw.FixedColumnWidth(65),
          //             1: const pw.FixedColumnWidth(65),
          //             2: const pw.FixedColumnWidth(65),
          //             3: const pw.FixedColumnWidth(65),
          //             4: const pw.FixedColumnWidth(65),
          //             5: const pw.FixedColumnWidth(65),
          //             6: const pw.FixedColumnWidth(65)
          //           })
          //     ]));

          // widgets.add(row);
          return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: widgets);
        },
      ),
    );
  }
  save(pdf);
}

Future<void> save(pw.Document pdf) async {
  final file = File('widgets-foorm.pdf');
  await file.writeAsBytes(await pdf.save());
  // Your asynchronous code goes here
}
