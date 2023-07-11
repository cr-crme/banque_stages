import 'package:crcrme_banque_stages/common/widgets/sub_title.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'package:crcrme_banque_stages/common/models/enterprise.dart';
import 'package:crcrme_banque_stages/common/models/job.dart';
import 'package:crcrme_banque_stages/common/providers/enterprises_provider.dart';
import 'package:crcrme_banque_stages/common/widgets/dialogs/add_sst_event_dialog.dart';
import 'package:crcrme_banque_stages/common/widgets/dialogs/add_text_dialog.dart';
import 'package:crcrme_banque_stages/common/widgets/dialogs/job_creator_dialog.dart';
import 'package:crcrme_banque_stages/misc/storage_service.dart';
import 'jobs_expansion_panels/comments_expansion_panel.dart';
import 'jobs_expansion_panels/photo_expansion_panel.dart';
import 'jobs_expansion_panels/prerequisites_expansion_panel.dart';
import 'jobs_expansion_panels/sst_expansion_panel.dart';
import 'jobs_expansion_panels/supervision_expansion_panel.dart';

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

  Future<void> addJob() async {
    final provider = context.read<EnterprisesProvider>();
    final newJob = await showDialog(
        context: context, builder: (context) => const JobCreatorDialog());

    if (newJob == null) return;
    widget.enterprise.jobs.add(newJob);
    provider.replace(widget.enterprise);
  }

  void _addImage(Job job) async {
    final enterprises = EnterprisesProvider.of(context);

    final images = await ImagePicker().pickMultiImage();

    for (XFile file in images) {
      var url = await StorageService.uploadJobImage(file.path);
      job.photosUrl.add(url);
    }

    enterprises.replace(widget.enterprise);
  }

  void _removeImage(Job job, int index) async {
    final enterprises = EnterprisesProvider.of(context);
    // TODO also remove int storage
    job.photosUrl.removeAt(index);
    enterprises.replace(widget.enterprise);
  }

  void _addSstEvent(Job job) async {
    final enterprises = context.read<EnterprisesProvider>();

    final result = await showDialog(
      context: context,
      builder: (context) => const AddSstEventDialog(),
    );
    if (result == null) return;

    switch (result['eventType']) {
      case SstEventType.pastIncidents:
        job.sstEvaluation.incidents.add(result['description']);
        break;
      case SstEventType.dangerousSituations:
        job.sstEvaluation.dangerousSituations.add(result['description']);
        break;
    }
    enterprises.replaceJob(widget.enterprise, job);
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
            job.id, () => [false, false, false, false, false, false]);
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
                headerBuilder: (context, isExpanded) =>
                    SubTitle(job.specialization.idWithName, top: 12),
                body: Column(
                  children: [
                    ExpansionPanelList(
                      expansionCallback: (panelIndex, isExpanded) => setState(
                          () => _expandedSections[job.id]![panelIndex] =
                              !isExpanded),
                      children: [
                        SstExpansionPanel(
                          isExpanded: _expandedSections[job.id]![0],
                          enterprise: widget.enterprise,
                          job: job,
                          addSstEvent: _addSstEvent,
                        ),
                        PrerequisitesExpansionPanel(
                          isExpanded: _expandedSections[job.id]![1],
                          enterprise: widget.enterprise,
                          job: job,
                        ),
                        SupervisionExpansionPanel(
                          isExpanded: _expandedSections[job.id]![2],
                          job: job,
                        ),
                        PhotoExpansionPanel(
                          isExpanded: _expandedSections[job.id]![3],
                          job: job,
                          addImage: _addImage,
                          removeImage: _removeImage,
                        ),
                        CommentsExpansionPanel(
                          isExpanded: _expandedSections[job.id]![4],
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
