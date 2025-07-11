part of 'package:crcrme_banque_stages/screens/internship_forms/generate_documents.dart';

final _textStyle = pw.TextStyle(font: pw.Font.times());
final _textStyleBold = pw.TextStyle(font: pw.Font.timesBold());

Future<Uint8List> _generateInternshipContractPdf(format,
    {required Internship internship, required int versionIndex}) async {
  final document = pw.Document(pageMode: PdfPageMode.outlines);

  document.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.letter,
      header: (context) => pw.Container(
          child: _logo(sizeFactor: context.pageNumber == 1 ? 1.0 : 0.7),
          padding: const pw.EdgeInsets.only(bottom: 12.0)),
      footer: (pw.Context context) {
        return pw.Container(
          alignment: pw.Alignment.centerRight,
          padding: const pw.EdgeInsets.only(top: 12.0, right: 12.0),
          child: context.pageNumber == 1
              ? null
              : pw.Text(
                  context.pageNumber.toString(),
                  style: pw.TextStyle(fontSize: 12, color: PdfColors.grey),
                ),
        );
      },
      build: (context) => [
            pw.SizedBox(
              height:
                  PdfPageFormat.letter.height - 300, // leave space for header
              child: _coverPage(internship),
            ),
            pw.NewPage(),
            _studentObligations(internship),
          ]));

  return document.save();
}

pw.Widget _logo({double sizeFactor = 1.0}) {
  return pw.Container(
    width: 150 * sizeFactor,
    height: 80 * sizeFactor,
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: PdfColors.black),
    ),
    child: pw.Center(child: pw.Text('LOGO')),
  );
}

pw.Widget _coverPage(Internship internship) {
  final schoolBoardName = _schoolBoardName(internship.schoolBoardId);
  final dash = '-';

  return pw.Center(
      child: pw.Column(
    mainAxisSize: pw.MainAxisSize.min,
    children: [
      pw.Text('FORMATION PRÉPARATOIRE AU TRAVAIL',
          style: _textStyle.copyWith(fontSize: 18)),
      pw.Padding(
        padding:
            const pw.EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
        child: pw.Container(
          width: double.infinity,
          decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.black),
              color: PdfColors.grey300),
          child: pw.Padding(
            padding:
                const pw.EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
            child: pw.Column(
              children: [
                pw.Text('CONTRAT DE STAGE',
                    style: _textStyleBold.copyWith(fontSize: 20)),
                pw.SizedBox(height: 20),
                pw.Text(
                  'ENTENTE ENTRE LES PARTIES',
                  style: _textStyle.copyWith(fontSize: 16),
                ),
                pw.Text(
                    '${schoolBoardName.toUpperCase()} $dash ELEVE $dash ENTREPRISE $dash SUPERVISEUR DE STAGE $dash ECOLE',
                    style: _textStyle.copyWith(fontSize: 16),
                    textAlign: pw.TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    ],
  ));
}

pw.Widget _studentObligations(Internship internship) {
  final schoolBoardName = _schoolBoardName(internship.schoolBoardId);
  final schoolName = _schoolName(internship.schoolBoardId);
  final mid = '\u00b7';

  return pw.Column(
    mainAxisSize: pw.MainAxisSize.max,
    children: [
      pw.SizedBox(width: double.infinity),
      pw.Center(
          child: pw.Column(children: [
        pw.Text('ENGAGEMENT DE L\'ÉLÈVE',
            style: _textStyleBold.copyWith(fontSize: 18)),
        pw.SizedBox(height: 16),
        pw.Text('Formation en entreprise',
            style: _textStyleBold.copyWith(fontSize: 16)),
        pw.SizedBox(height: 16),
        pw.RichText(
            text: pw.TextSpan(children: [
          pw.TextSpan(text: 'Je, soussigné${mid}e, ', style: _textStyle),
          pw.TextSpan(
              text: _studentName(internship.studentId),
              style:
                  _textStyle.copyWith(decoration: pw.TextDecoration.underline)),
          pw.TextSpan(text: ', m\'engage :', style: _textStyle),
        ])),
        pw.SizedBox(height: 16),
      ])),
      _BulletPoint(
        child: pw.RichText(
          textAlign: pw.TextAlign.justify,
          text: pw.TextSpan(
              text:
                  'À observer l\'horaire établi après entente entre les dirigeants${mid}e${mid}s '
                  'de l\'entreprise et l\'école secondaire ${schoolName.toUpperCase()};',
              style: _textStyle),
        ),
      ),
      _BulletPoint(
        child: pw.RichText(
          textAlign: pw.TextAlign.justify,
          text: pw.TextSpan(
              text:
                  'À prévenir, le plus tôt possible, l\'enseignant${mid}e responsable des stages '
                  'de l\'école secondaire ${schoolName.toUpperCase()} et mon employeur de toute absence, de tout '
                  'accident au travail ou de tout autre problème qui pourrait survenir lors de ma '
                  'formation;',
              style: _textStyle),
        ),
      ),
      _BulletPoint(
        child: pw.RichText(
          textAlign: pw.TextAlign.justify,
          text: pw.TextSpan(
              text:
                  'À fournir à la personne désignée un billet médical ou légal pour justifier toute absence;',
              style: _textStyle),
        ),
      ),
      _BulletPoint(
        child: pw.RichText(
          textAlign: pw.TextAlign.justify,
          text: pw.TextSpan(
              text:
                  'À ne pas demander ni directement ni indirectement, de salaire ou de compensation '
                  'pour le travail effectué durant les heures de formation;',
              style: _textStyle.copyWith(color: PdfColors.red)),
        ),
      ),
      _BulletPoint(
        child: pw.RichText(
          textAlign: pw.TextAlign.justify,
          text: pw.TextSpan(
              text:
                  'À faire toute la période de formation exigée par l\'école secondaire $schoolName '
                  'et l\'entreprise de formation;',
              style: _textStyle),
        ),
      ),
      _BulletPoint(
        child: pw.RichText(
          textAlign: pw.TextAlign.justify,
          text: pw.TextSpan(
              text:
                  'À demander des explications supplémentaires lorsqu\'il y a doute pour éviter '
                  'des erreurs coûteuses;',
              style: _textStyle),
        ),
      ),
      _BulletPoint(
        child: pw.RichText(
          textAlign: pw.TextAlign.justify,
          text: pw.TextSpan(
              text:
                  'À me conformer aux règlements, politiques et mesures de sécurité relatives '
                  'aux tâches qui me seront assignées;',
              style: _textStyle),
        ),
      ),
      _BulletPoint(
        child: pw.RichText(
          textAlign: pw.TextAlign.justify,
          text: pw.TextSpan(
              text:
                  'À suivre les règlements de l\'ENTREPRISE et du ${schoolBoardName.toUpperCase()} '
                  'en me conformant aux politiques, directives et pratiques courantes dont on m\'aura '
                  'préalablement informé${mid}e, notamment les règles d\'utilisation du matériel '
                  'informatique et technologique (cellulaire, internet, réseaux sociaux, etc.);',
              style: _textStyle),
        ),
      ),
      _BulletPoint(
        child: pw.RichText(
          textAlign: pw.TextAlign.justify,
          text: pw.TextSpan(
              text:
                  'À respecter la propriété des autres et à ne jamais m\'approprier ce qui n\'est '
                  'pas à moi;',
              style: _textStyle),
        ),
      ),
      _BulletPoint(
        child: pw.RichText(
          textAlign: pw.TextAlign.justify,
          text: pw.TextSpan(
              text:
                  'À informer l\'enseignant${mid}e responsable des stages à l\'école si je n\'ai '
                  'pas accès à l\'équipement de protection individuelle (EPI) en lien avec les mesures '
                  'sanitaires et les tâches exécutées en milieu de stage;',
              style: _textStyle),
        ),
      ),
      _BulletPoint(
        child: pw.RichText(
          textAlign: pw.TextAlign.justify,
          text: pw.TextSpan(
              text:
                  'À respecter les règles de santé, de sécurité, d\'hygiène et de salubrité '
                  'selon les techniques de travail et les normes prescrites.',
              style: _textStyle),
        ),
      ),
      _BulletPoint(
        child: pw.RichText(
          textAlign: pw.TextAlign.justify,
          text: pw.TextSpan(
              text:
                  'À respecter les règles de santé, de sécurité, d\'hygiène et de salubrité '
                  'selon les techniques de travail et les normes prescrites.',
              style: _textStyle),
        ),
      ),
      _BulletPoint(
        child: pw.RichText(
          textAlign: pw.TextAlign.justify,
          text: pw.TextSpan(
              text:
                  'À respecter les règles de santé, de sécurité, d\'hygiène et de salubrité '
                  'selon les techniques de travail et les normes prescrites.',
              style: _textStyle),
        ),
      ),
      _BulletPoint(
        child: pw.RichText(
          textAlign: pw.TextAlign.justify,
          text: pw.TextSpan(
              text:
                  'À respecter les règles de santé, de sécurité, d\'hygiène et de salubrité '
                  'selon les techniques de travail et les normes prescrites.',
              style: _textStyle),
        ),
      ),
    ],
  );
}

class _BulletPoint extends pw.StatelessWidget {
  _BulletPoint({required this.child});

  final pw.Widget child;

  @override
  pw.Widget build(pw.Context context) {
    return pw.Container(
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('\u0097', style: _textStyle),
          pw.SizedBox(width: 6.0),
          pw.Expanded(child: child),
        ],
      ),
      padding: const pw.EdgeInsets.only(bottom: 12.0),
    );
  }
}

// pw.Page(
//   build: (pw.Context context) => pw.Center(
//       child: pw.Text('Contrat de stage pour le stage de '
//           '${DateFormat('yMd', 'fr_CA').format(internship.creationDateFrom(versionIndex))}')),
// ),

// TODO: Make these dynamic
String _schoolBoardName(String schoolBoardId) =>
    'CENTRE DE SERVICES SCOLAIRES DES AFFLUENTS';

String _schoolName(String schoolBoardId) => 'ÉCOLE SECONDAIRE DES FLEURS';

String _enterpriseName(String enterpriseId) => 'Les jardins de la technologie';

String _studentName(String studentId) => 'Jean Dupont';
