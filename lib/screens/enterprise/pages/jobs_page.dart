import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '/common/models/enterprise.dart';
import '/common/models/job.dart';
import '/common/providers/enterprises_provider.dart';
import '/common/widgets/dialogs/job_creator_dialog.dart';
import '/common/widgets/form_fields/low_high_slider_form_field.dart';
import '/misc/services/storage_service.dart';

class JobsPage extends StatefulWidget {
  const JobsPage({
    Key? key,
    required this.enterprise,
  }) : super(key: key);

  final Enterprise enterprise;

  @override
  State<JobsPage> createState() => JobsPageState();
}

class JobsPageState extends State<JobsPage> {
  final Map<String, List> _expandedSections = {};

  void addJob() async {
    final provider = context.read<EnterprisesProvider>();

    final newJob = await showDialog(
        context: context, builder: (context) => const JobCreatorDialog());

    if (newJob == null) return;

    widget.enterprise.jobs.add(newJob);
    provider.replace(widget.enterprise);
  }

  void _addImage(Job job) async {
    final provider = context.read<EnterprisesProvider>();
    final images = await ImagePicker().pickMultiImage();

    if (images == null) return;

    for (XFile file in images) {
      var url = await StorageService.uploadJobImage(file);
      job.pictures.add(url);
    }

    provider.replace(widget.enterprise);
  }

  void _updateExpandedSections() {
    setState(() {
      for (Job job in widget.enterprise.jobs) {
        _expandedSections.putIfAbsent(
            job.id, () => [true, false, false, false, false, false]);
      }
    });
  }

  // TODO: Clean this up
  Widget _ratingBar({
    required Widget title,
    required double rating,
  }) {
    // TODO: Add a placeholer for invalid values
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          title,
          const SizedBox(height: 4),
          RatingBarIndicator(
            rating: rating,
            itemBuilder: (context, index) => Icon(
              Icons.star,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _updateExpandedSections();
    context.read<EnterprisesProvider>().addListener(() {
      if (mounted) {
        _updateExpandedSections();
      }
    });
  }

  // TODO: Separate all ExpansionPanels
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: ExpansionPanelList.radio(
        initialOpenPanelValue: widget.enterprise.jobs.first.id,
        children: widget.enterprise.jobs
            .map((job) => ExpansionPanelRadio(
                canTapOnHeader: true,
                value: job.id,
                headerBuilder: (context, isExpanded) => ListTile(
                      title: Text(
                        job.specialization,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                body: Column(
                  children: [
                    ExpansionPanelList(
                      expansionCallback: (panelIndex, isExpanded) => setState(
                          () => _expandedSections[job.id]![panelIndex] =
                              !isExpanded),
                      children: [
                        ExpansionPanel(
                          isExpanded: _expandedSections[job.id]![0],
                          canTapOnHeader: true,
                          headerBuilder: (context, isExpanded) => ListTile(
                            title: const Text("Photos du poste de travail"),
                            trailing: isExpanded
                                ? IconButton(
                                    onPressed: () => _addImage(job),
                                    icon: const Icon(
                                        Icons.add_photo_alternate_outlined))
                                : null,
                          ),
                          body: Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: job.pictures.isEmpty
                                    ? [const Text("Aucune image disponible")]
                                    : job.pictures
                                        .map(
                                          // TODO: Make images clicables and deletables
                                          (url) => Card(
                                            child: Image.network(
                                              url,
                                              height: 250,
                                            ),
                                          ),
                                        )
                                        .toList(),
                              ),
                            ),
                          ),
                        ),
                        ExpansionPanel(
                          isExpanded: _expandedSections[job.id]![1],
                          canTapOnHeader: true,
                          headerBuilder: (context, isExpanded) =>
                              const ListTile(
                            title: Text(
                                "Tâches et exigences envers les stagiaires"),
                          ),
                          body: SizedBox(
                            width: Size.infinite.width,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 32),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Variété des tâches",
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    child: LowHighSliderFormField(
                                      initialValue: job.taskVariety,
                                      enabled: false,
                                    ),
                                  ),
                                  Text(
                                    "Compétences obligatoires",
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 16),
                                    child: Column(
                                      children: job.skillsRequired.isEmpty
                                          ? [
                                              const Text(
                                                  "Aucune compétence requise")
                                            ]
                                          : job.skillsRequired
                                              .map(
                                                  (skills) => Text("- $skills"))
                                              .toList(),
                                    ),
                                  ),
                                  Text(
                                    "Niveau d’autonomie souhaité",
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    child: LowHighSliderFormField(
                                      initialValue: job.autonomyExpected,
                                      enabled: false,
                                    ),
                                  ),
                                  Text(
                                    "Rendement attendu",
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    child: LowHighSliderFormField(
                                      initialValue: job.efficiencyWanted,
                                      enabled: false,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        ExpansionPanel(
                          isExpanded: _expandedSections[job.id]![2],
                          canTapOnHeader: true,
                          headerBuilder: (context, isExpanded) =>
                              const ListTile(
                            title: Text(
                              "Type d'encadrement des stagiaires",
                            ),
                          ),
                          body: SizedBox(
                            width: Size.infinite.width,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 32),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _ratingBar(
                                    title: Text(
                                      "Accueil de stagiaires TSA",
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                    ),
                                    rating: job.welcomingTSA,
                                  ),
                                  _ratingBar(
                                    title: Text(
                                      "Accueil de stagiaires de classe communication",
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                    ),
                                    rating: job.welcomingCommunication,
                                  ),
                                  _ratingBar(
                                    title: Text(
                                      "Accueil de stagiaires avec une déficience intellectuelle",
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                    ),
                                    rating: job.welcomingMentalDeficiency,
                                  ),
                                  _ratingBar(
                                    title: Text(
                                      "Accueil de stagiaires avec un trouble de santé mentale",
                                      style:
                                          Theme.of(context).textTheme.bodyLarge,
                                    ),
                                    rating: job.welcomingMentalHealthIssue,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        ExpansionPanel(
                          isExpanded: _expandedSections[job.id]![3],
                          canTapOnHeader: true,
                          headerBuilder: (context, isExpanded) =>
                              const ListTile(
                            title: Text(
                              "Santé et Sécurité du travail (SST)",
                            ),
                          ),
                          body: SizedBox(
                            width: Size.infinite.width,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 32),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Équipements de protection individuelle requis",
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 16),
                                    child: Column(
                                      children: job.equipmentRequired.isEmpty
                                          ? [
                                              const Text(
                                                  "Aucun équipement de protection requis")
                                            ]
                                          : job.equipmentRequired
                                              .map((equipment) =>
                                                  Text("- $equipment"))
                                              .toList(),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Situations dangereuses identifiées",
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 16),
                                    child: Column(
                                      children: job.dangerousSituations.isEmpty
                                          ? [
                                              const Text(
                                                  "Aucune situation dangereuse signalée")
                                            ]
                                          : job.dangerousSituations
                                              .map((situation) =>
                                                  Text("- $situation"))
                                              .toList(),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Blessures d’élèves lors de stages précédents",
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 16),
                                    child: Column(
                                      children: job.pastWounds.isEmpty
                                          ? [
                                              const Text(
                                                  "Aucune blessure signalée")
                                            ]
                                          : job.pastWounds
                                              .map((wound) => Text("- $wound"))
                                              .toList(),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Incidents lors de stages précédents (p. ex. agression verbale, harcèlement)?",
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 16),
                                    child: Column(
                                      children: job.pastIncidents.isEmpty
                                          ? [
                                              const Text(
                                                  "Aucun incident de ce type signalé")
                                            ]
                                          : job.pastIncidents
                                              .map((incident) =>
                                                  Text("- $incident"))
                                              .toList(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        ExpansionPanel(
                          isExpanded: _expandedSections[job.id]![4],
                          canTapOnHeader: true,
                          headerBuilder: (context, isExpanded) =>
                              const ListTile(
                            title: Text(
                              "Pré-requis pour le recrutement",
                            ),
                          ),
                          body: SizedBox(
                            width: Size.infinite.width,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 32),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Âge minimum",
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 16),
                                    child: Text("${job.minimalAge} ans"),
                                  ),
                                  Text(
                                    "Uniforme en vigueur",
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 16),
                                    child: job.uniform.isEmpty
                                        ? const Text("Aucun uniforme requis")
                                        : Text(job.uniform),
                                  ),
                                  Text(
                                    "L'élève doit :",
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 16),
                                    child: Column(
                                      children: job.requiredForJob.isEmpty
                                          ? [
                                              const Text(
                                                  "Il n'y a aucun pré-requis pour ce métier")
                                            ]
                                          : job.requiredForJob
                                              .map((requirement) =>
                                                  Text("- $requirement"))
                                              .toList(),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        ExpansionPanel(
                          isExpanded: _expandedSections[job.id]![5],
                          canTapOnHeader: true,
                          headerBuilder: (context, isExpanded) =>
                              const ListTile(
                            title: Text(
                              "Autres commentaires",
                            ),
                          ),
                          body: SizedBox(
                            width: Size.infinite.width,
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 32),
                              child: Column(
                                children: job.comments.isEmpty
                                    ? [
                                        const Text(
                                            "Il n'y a présentement aucun commentaire"),
                                        const SizedBox(height: 16)
                                      ]
                                    : job.comments
                                        .map((comment) => Padding(
                                              padding: const EdgeInsets.only(
                                                  bottom: 16),
                                              child: Text(comment),
                                            ))
                                        .toList(),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                )))
            .toList(),
      ),
    );
  }
}
