import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '/common/models/enterprise.dart';
import '/common/models/job.dart';
import '/common/providers/enterprises_provider.dart';

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

  void addJob() {}

  void _addImage(Job job) async {
    List<XFile>? images = await ImagePicker().pickMultiImage();

    if (images == null) return;

    for (XFile file in images) {
      // Add to Firebase hosting
    }
  }

  void _updateExpandedSections() {
    setState(() {
      for (Job job in widget.enterprise.jobs) {
        _expandedSections.putIfAbsent(
            job.id, () => [true, false, false, false, false, false]);
      }
    });
  }

  Widget _ratingBar({
    required Widget title,
    required double rating,
  }) {
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
    context.read<EnterprisesProvider>().addListener(_updateExpandedSections);
  }

  // TODO: Handle missing fields (add placeholder)
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
                            title: const Text(
                              "Photos du poste de travail",
                            ),
                            trailing: isExpanded
                                ? IconButton(
                                    onPressed: () => _addImage(job),
                                    icon: const Icon(
                                        Icons.add_photo_alternate_outlined))
                                : null,
                          ),
                          body: Row(
                            children: job.pictures
                                .map((url) => Image.network(url))
                                .toList(),
                          ),
                        ),
                        ExpansionPanel(
                          isExpanded: _expandedSections[job.id]![1],
                          canTapOnHeader: true,
                          headerBuilder: (context, isExpanded) =>
                              const ListTile(
                            title: Text(
                              "Tâches et exigences envers les stagiaires",
                            ),
                          ),
                          body: Column(
                            children: [
                              // TODO: Make the low/medium/high sliders
                              Text(
                                "Compétences obligatoires",
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                child: Column(
                                  children: job.skillsRequired
                                      .map((skills) => Text("- $skills"))
                                      .toList(),
                                ),
                              ),
                            ],
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
                          body: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Column(
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
                        ExpansionPanel(
                          isExpanded: _expandedSections[job.id]![3],
                          canTapOnHeader: true,
                          headerBuilder: (context, isExpanded) =>
                              const ListTile(
                            title: Text(
                              "Santé et Sécurité du travail (SST)",
                            ),
                          ),
                          body: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Équipements de protection individuelle requis",
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  child: Column(
                                    children: job.equipmentRequired
                                        .map(
                                            (equipment) => Text("- $equipment"))
                                        .toList(),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Situations dangereuses identifiées",
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  child: Column(
                                    children: job.dangerousSituations
                                        .map(
                                            (situation) => Text("- $situation"))
                                        .toList(),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Blessures d’élèves lors de stages précédents",
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  child: Column(
                                    children: job.pastWounds
                                        .map((wound) => Text("- $wound"))
                                        .toList(),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Incidents lors de stages précédents (p. ex. agression verbale, harcèlement)?",
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  child: Column(
                                    children: job.pastIncidents
                                        .map((incident) => Text("- $incident"))
                                        .toList(),
                                  ),
                                ),
                              ],
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
                          body: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Column(
                              children: [
                                Text(
                                  "Âge minimum",
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  child: Text("${job.minimalAge} ans"),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Uniforme en vigueur",
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  child: Text(job.uniform),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "L'élève doit :",
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  child: Column(
                                    children: job.requiredForJob
                                        .map((requirement) =>
                                            Text("- $requirement"))
                                        .toList(),
                                  ),
                                ),
                              ],
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
                          body: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Column(
                              children: job.comments
                                  .map((comment) => Text(comment))
                                  .toList(),
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
