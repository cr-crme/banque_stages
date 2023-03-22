import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '/common/models/enterprise.dart';
import '/common/models/job.dart';
import '/common/providers/enterprises_provider.dart';
import '/common/widgets/dialogs/add_sst_event_dialog.dart';
import '/common/widgets/dialogs/add_text_dialog.dart';
import '/common/widgets/dialogs/job_creator_dialog.dart';
import '/misc/storage_service.dart';
import 'jobs_expansion_panels/comments_expansion_panel.dart';
import 'jobs_expansion_panels/photo_expansion_panel.dart';
import 'jobs_expansion_panels/prerequisites_expansion_panel.dart';
import 'jobs_expansion_panels/sst_expansion_panel.dart';
import 'jobs_expansion_panels/supervision_expansion_panel.dart';
import 'jobs_expansion_panels/tasks_expansion_panel.dart';

class JobsPage extends StatefulWidget {
  const JobsPage({
    super.key,
    required this.enterprise,
  });

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

    for (XFile file in images) {
      var url = await StorageService.uploadJobImage(file.path);
      job.pictures.add(url);
    }
    provider.replace(widget.enterprise);
  }

  void _addSstEvent(Job job) async {
    final provider = context.read<EnterprisesProvider>();

    final eventType = await showDialog(
      context: context,
      builder: (context) => const AddSstEventDialog(),
    );
    if (eventType == null) return;

    if (!mounted) return;
    final description = await showDialog(
      context: context,
      builder: (context) => AddTextDialog(
        title: eventType == 2
            ? 'Décrivez la situation dangereuse identifiée :'
            : 'Racontez ce qu\'il s\'est passé :',
      ),
    );
    if (description == null) return;

    switch (eventType) {
      case SstEventType.pastWounds:
        job.pastWounds.add(description);
        break;
      case SstEventType.pastIncidents:
        job.pastIncidents.add(description);
        break;
      case SstEventType.dangerousSituations:
        job.dangerousSituations.add(description);
        break;
      default:
        return;
    }
    provider.replace(widget.enterprise);
  }

  void _addComment(Job job) async {
    final provider = context.read<EnterprisesProvider>();
    final newComment = await showDialog(
      context: context,
      builder: (context) => const AddTextDialog(
        title: 'Ajouter un commentaire',
      ),
    );

    if (newComment == null) return;
    job.comments.add(newComment);
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
                        job.specialization?.idWithName ?? 'bad id',
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
                        PhotoExpansionPanel(
                          isExpanded: _expandedSections[job.id]![0],
                          job: job,
                          addImage: _addImage,
                        ),
                        TasksExpansionPanel(
                          isExpanded: _expandedSections[job.id]![1],
                          job: job,
                        ),
                        SupervisionExpansionPanel(
                          isExpanded: _expandedSections[job.id]![2],
                          job: job,
                        ),
                        SstExpansionPanel(
                          isExpanded: _expandedSections[job.id]![3],
                          job: job,
                          addSstEvent: _addSstEvent,
                        ),
                        PrerequisitesExpansionPanel(
                          isExpanded: _expandedSections[job.id]![4],
                          job: job,
                        ),
                        CommentsExpansionPanel(
                          isExpanded: _expandedSections[job.id]![5],
                          job: job,
                          addComment: _addComment,
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
