part of 'package:crcrme_banque_stages/screens/internship_forms/generate_documents.dart';

final _textStyle = pw.TextStyle(font: pw.Font.times());
final _textStyleBold = pw.TextStyle(font: pw.Font.timesBold());

String _title(student_model.Program program) {
  switch (program) {
    case student_model.Program.fpt:
      return 'Formation préparatoire au travail';
    case student_model.Program.fms:
      return 'Formation menant à l\'exercice d\'un métier semi-spécialisé';
    case student_model.Program.undefined:
      throw ArgumentError('Program must be defined');
  }
}

// TODO Use feminine form?

Future<Uint8List> _generateInternshipContractPdf(format,
    {required Internship internship, required int versionIndex}) async {
  final document = pw.Document(pageMode: PdfPageMode.outlines);

  document.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat.letter,
      header: (context) => pw.Container(
          child: _logo(sizeFactor: context.pageNumber == 1 ? 1.0 : 0.7),
          padding: const pw.EdgeInsets.only(bottom: 12.0)),
      footer: (pw.Context context) {
        return pw.Stack(children: [
          if (context.pageNumber > 1)
            pw.Text(
                'N.B. Ce document est à conserver dans le dossier «	stage » de '
                'l\'élève pendant 3 ans.',
                style: _textStyleBold.copyWith(fontSize: 10)),
          pw.Container(
            alignment: pw.Alignment.centerRight,
            padding: const pw.EdgeInsets.only(top: 12.0, right: 12.0),
            child: context.pageNumber == 1
                ? null
                : pw.Text(
                    context.pageNumber.toString(),
                    style: pw.TextStyle(fontSize: 12, color: PdfColors.grey),
                  ),
          )
        ]);
      },
      build: (context) => [
            pw.SizedBox(
              height:
                  PdfPageFormat.letter.height - 300, // leave space for header
              child: _coverPage(internship),
            ),
            pw.NewPage(),
            _studentObligations(internship),
            pw.NewPage(),
            _contract(internship),
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
  final program = _program(internship);
  final dash = '-';

  return pw.Center(
      child: pw.Column(
    mainAxisSize: pw.MainAxisSize.min,
    children: [
      pw.Text(_title(program).toUpperCase(),
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
  final schoolBoardName =
      _schoolBoardName(internship.schoolBoardId).toUpperCase();
  final schoolName = _schoolName(internship.schoolBoardId).toUpperCase();
  final studentName = _studentName(internship.studentId).toUpperCase();
  final mid = '\u00b7';

  return pw.Column(
    mainAxisSize: pw.MainAxisSize.max,
    children: [
      pw.SizedBox(width: double.infinity),
      pw.SizedBox(height: 24),
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
              text: studentName,
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
            children: [
              pw.TextSpan(
                  text:
                      'À observer l\'horaire établi après entente entre les dirigeants${mid}e${mid}s '
                      'de l\'entreprise et l\'école secondaire ',
                  style: _textStyle),
              pw.TextSpan(
                  text: schoolName,
                  style: _textStyle.copyWith(
                      decoration: pw.TextDecoration.underline)),
              pw.TextSpan(text: ';', style: _textStyle),
            ],
          ),
        ),
      ),
      _BulletPoint(
        child: pw.RichText(
          textAlign: pw.TextAlign.justify,
          text: pw.TextSpan(
            children: [
              pw.TextSpan(
                  text:
                      'À prévenir, le plus tôt possible, l\'enseignant${mid}e responsable des stages '
                      'de l\'école secondaire ',
                  style: _textStyle),
              pw.TextSpan(
                  text: schoolName,
                  style: _textStyle.copyWith(
                      decoration: pw.TextDecoration.underline)),
              pw.TextSpan(
                  text: ' et mon employeur de toute absence, de tout '
                      'accident au travail ou de tout autre problème qui pourrait survenir lors de ma '
                      'formation;',
                  style: _textStyle),
            ],
          ),
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
            children: [
              pw.TextSpan(
                  text:
                      'À faire toute la période de formation exigée par l\'école secondaire ',
                  style: _textStyle),
              pw.TextSpan(
                  text: schoolName,
                  style: _textStyle.copyWith(
                      decoration: pw.TextDecoration.underline)),
              pw.TextSpan(
                  text: ' et l\'entreprise de formation;', style: _textStyle)
            ],
          ),
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
      pw.SizedBox(height: 24),
      _signature('Signature de l\'élève'),
    ],
  );
}

pw.Widget _contract(Internship internship) {
  final schoolBoardName =
      _schoolBoardName(internship.schoolBoardId).toUpperCase();
  final schoolBoardCnesstNumber =
      _schoolBoardCnesstNumber(internship.schoolBoardId);
  final schoolName = _schoolName(internship.schoolBoardId).toUpperCase();
  final program = _program(internship);
  final enterpriseName = _enterpriseName(internship.enterpriseId).toUpperCase();

  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    mainAxisSize: pw.MainAxisSize.max,
    children: [
      pw.SizedBox(width: double.infinity),
      pw.Center(
        child: pw.Text('ENTENTE', style: _textStyleBold.copyWith(fontSize: 18)),
      ),
      pw.SizedBox(height: 16),
      pw.Container(
          width: double.infinity,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.black, width: 2),
          ),
          padding:
              const pw.EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
          child: pw.Text('Entre le $schoolBoardName',
              style: _textStyleBold.copyWith(fontSize: 16))),
      pw.SizedBox(height: 16),
      pw.Container(
          width: double.infinity,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.black, width: 2),
          ),
          padding:
              const pw.EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
          child: pw.Text('L\'école $schoolName',
              style: _textStyleBold.copyWith(fontSize: 16))),
      pw.SizedBox(height: 16),
      pw.Container(
          width: double.infinity,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.black, width: 2),
          ),
          padding:
              const pw.EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
          child: pw.Text('Et l\'entreprise $enterpriseName',
              style: _textStyleBold.copyWith(fontSize: 16))),
      pw.SizedBox(height: 24),
      pw.Padding(
          padding: const pw.EdgeInsets.only(left: 12.0),
          child: pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.black, width: 2),
              ),
              padding:
                  const pw.EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
              child: pw.Text('Objet : ${_title(program)}',
                  style: _textStyleBold.copyWith(fontSize: 14)))),
      pw.SizedBox(height: 24),
      pw.RichText(
          text: pw.TextSpan(text: 'Il est entendu :', style: _textStyle)),
      pw.SizedBox(height: 16),
      _BulletPoint(
        child: pw.RichText(
          textAlign: pw.TextAlign.justify,
          text: pw.TextSpan(
              text:
                  'Que les modalités de la formation concernant la durée, l\'horaire, et les '
                  'tâches à effectuer doivent faire l\'objet d\'un accord entre les parties et '
                  'doivent être respectés;',
              style: _textStyle),
        ),
      ),
      _BulletPoint(
        child: pw.RichText(
          textAlign: pw.TextAlign.justify,
          text: pw.TextSpan(
              text:
                  'Que l\'employeur assigne un travailleur parrain qui se charge '
                  'd\'accompagner le ou la stagiaire et ce, pour toute la durée de la formation en '
                  'entreprise;',
              style: _textStyle),
        ),
      ),
      _BulletPoint(
        child: pw.RichText(
          textAlign: pw.TextAlign.justify,
          text: pw.TextSpan(
            children: [
              pw.TextSpan(
                  text: 'Que le stagiaire travaille sous la supervision ',
                  style: _textStyle),
              pw.TextSpan(
                  text: 'd\'une personne déléguée',
                  style: _textStyle.copyWith(
                      decoration: pw.TextDecoration.underline)),
              pw.TextSpan(text: ' par l\'employeur;', style: _textStyle),
            ],
          ),
        ),
      ),
      _BulletPoint(
        child: pw.RichText(
          textAlign: pw.TextAlign.justify,
          text: pw.TextSpan(
              text:
                  'Que le stagiaire ne se substitue d\'aucune manière à l\'employé en fonction '
                  'mais travaille avec ce dernier en vue de parfaire sa formation;',
              style: _textStyle),
        ),
      ),
      _BulletPoint(
        child: pw.RichText(
          textAlign: pw.TextAlign.justify,
          text: pw.TextSpan(
              text:
                  'Que l\'enseignant responsable des stages a la liberté de se rendre '
                  'régulièrement dans l\'entreprise où a lieu la formation afin d\'échanger avec '
                  'le stagiaire et avec le travailleur parrain;',
              style: _textStyle),
        ),
      ),
      _BulletPoint(
        child: pw.RichText(
          textAlign: pw.TextAlign.justify,
          text: pw.TextSpan(
            children: [
              pw.TextSpan(
                  text:
                      'Que l\'employeur et le travailleur parrain s\'engagent à participer à '
                      'l\'évaluation du stagiaire selon les modalités convenues avec l\'enseignant '
                      'ou l\'enseignante responsable des stages de l\'école secondaire ',
                  style: _textStyle),
              pw.TextSpan(
                  text: schoolName,
                  style: _textStyle.copyWith(
                      decoration: pw.TextDecoration.underline)),
              pw.TextSpan(text: ';', style: _textStyle)
            ],
          ),
        ),
      ),
      _BulletPoint(
        child: pw.RichText(
          textAlign: pw.TextAlign.justify,
          text: pw.TextSpan(
              text:
                  'Que l\'employeur informe l\'élève sur les normes de la santé et sécurité '
                  'obligatoires dans son entreprise;',
              style: _textStyle),
        ),
      ),
      _BulletPoint(
        child: pw.RichText(
          textAlign: pw.TextAlign.justify,
          text: pw.TextSpan(
              text:
                  'Que la Loi sur les accidents de travail et les maladies professionnelles '
                  'protège automatiquement le stagiaire qui effectue une formation non '
                  'rémunérée sous la responsabilité d\'un établissement d\'enseignement;',
              style: _textStyle),
        ),
      ),
      _BulletPoint(
        child: pw.RichText(
          textAlign: pw.TextAlign.justify,
          text: pw.TextSpan(
            children: [
              pw.TextSpan(text: 'Que le ', style: _textStyle),
              pw.TextSpan(
                  text: schoolBoardName,
                  style: _textStyle.copyWith(
                      decoration: pw.TextDecoration.underline)),
              pw.TextSpan(
                  text: ' acquitte la cotisation pour '
                      'la protection assurée par la Loi. Le numéro de dossier du ',
                  style: _textStyle),
              pw.TextSpan(
                  text: schoolBoardName,
                  style: _textStyle.copyWith(
                      decoration: pw.TextDecoration.underline)),
              pw.TextSpan(
                  text: ' pour la Commission des normes, de l\'équité, de la '
                      'santé et de la sécurité du travail (CNESST) est: ',
                  style: _textStyle),
              pw.TextSpan(
                  text: schoolBoardCnesstNumber,
                  style: _textStyle.copyWith(
                      decoration: pw.TextDecoration.underline)),
              pw.TextSpan(text: ';', style: _textStyle),
            ],
          ),
        ),
      ),
      _BulletPoint(
        child: pw.RichText(
          textAlign: pw.TextAlign.justify,
          text: pw.TextSpan(
            children: [
              pw.TextSpan(text: 'Que le ', style: _textStyle),
              pw.TextSpan(
                  text: schoolBoardName,
                  style: _textStyle.copyWith(
                      decoration: pw.TextDecoration.underline)),
              pw.TextSpan(
                  text: ' s\'engage à ajouter le '
                      'stagiaire comme assuré supplémentaire dans son contrat d\'assurance '
                      'responsabilité civile pendant la période de stage;',
                  style: _textStyle),
            ],
          ),
        ),
      ),
      _BulletPoint(
        child: pw.RichText(
          textAlign: pw.TextAlign.justify,
          text: pw.TextSpan(
              text:
                  'Que les parties contractantes peuvent, après entente, mettre fin au stage '
                  'de l\'élève.',
              style: _textStyle),
        ),
      ),
      pw.SizedBox(height: 24),
      pw.Text('En foi de quoi, les parties ont signé la présente :',
          style: _textStyleBold),
      pw.SizedBox(height: 24),
      _signature('Signature de l\'employeur'),
      pw.SizedBox(height: 24),
      _signature('Signature de l\'enseignant\nresponsable des stages'),
      pw.SizedBox(height: 24),
      _signature('Signature du stagiaire'),
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

pw.Widget _signature(String person) {
  return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Column(children: [
          pw.Text('______________________________________________',
              style: _textStyleBold),
          pw.Text(person, style: _textStyle, textAlign: pw.TextAlign.center),
        ]),
        pw.Column(children: [
          pw.Text('____________________________', style: _textStyleBold),
          pw.Text('Date (année/mois/jour)', style: _textStyle),
        ]),
      ]);
}

// pw.Page(
//   build: (pw.Context context) => pw.Center(
//       child: pw.Text('Contrat de stage pour le stage de '
//           '${DateFormat('yMd', 'fr_CA').format(internship.creationDateFrom(versionIndex))}')),
// ),

// TODO: Make these dynamic
String _schoolBoardName(String schoolBoardId) =>
    'CENTRE DE SERVICES SCOLAIRES DES AFFLUENTS';

String _schoolBoardCnesstNumber(String schoolBoardId) => '1234567890';

String _schoolName(String schoolBoardId) => 'ÉCOLE SECONDAIRE DES FLEURS';

String _enterpriseName(String enterpriseId) => 'Les jardins de la technologie';

String _studentName(String studentId) => 'Jean Dupont';

student_model.Program _program(Internship internship) =>
    student_model.Program.fpt;
