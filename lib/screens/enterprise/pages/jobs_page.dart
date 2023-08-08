import 'package:crcrme_banque_stages/common/models/enterprise.dart';
import 'package:crcrme_banque_stages/common/models/incidents.dart';
import 'package:crcrme_banque_stages/common/models/job.dart';
import 'package:crcrme_banque_stages/common/models/pre_internship_request.dart';
import 'package:crcrme_banque_stages/common/providers/enterprises_provider.dart';
import 'package:crcrme_banque_stages/common/widgets/dialogs/add_sst_event_dialog.dart';
import 'package:crcrme_banque_stages/common/widgets/dialogs/add_text_dialog.dart';
import 'package:crcrme_banque_stages/common/widgets/dialogs/confirm_pop_dialog.dart';
import 'package:crcrme_banque_stages/common/widgets/dialogs/job_creator_dialog.dart';
import 'package:crcrme_banque_stages/common/widgets/sub_title.dart';
import 'package:crcrme_banque_stages/misc/storage_service.dart';
import 'package:crcrme_banque_stages/screens/enterprise/pages/jobs_expansion_panels/incidents_expansion_panel.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

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
  final Map<String, GlobalKey<PrerequisitesBodyState>> _prerequisitesFormKeys =
      {};
  final Map<String, bool> _isEditingPrerequisites = {};

  bool get isEditing => _isEditingPrerequisites.containsValue(true);
  void cancelEditing() {
    for (final e in _isEditingPrerequisites.keys) {
      _isEditingPrerequisites[e] = false;
    }
    setState(() {});
  }

  Future<void> addJob() async {
    final enterprises = EnterprisesProvider.of(context, listen: false);
    final newJob = await showDialog(
        context: context,
        builder: (context) => JobCreatorDialog(
              enterprise: widget.enterprise,
            ));

    if (newJob == null) return;
    widget.enterprise.jobs.add(newJob);
    enterprises.replace(widget.enterprise);
  }

  void _addImage(Job job, ImageSource source) async {
    final enterprises = EnterprisesProvider.of(context, listen: false);

    late List<XFile?> images;
    if (source == ImageSource.camera) {
      images = [(await ImagePicker().pickImage(source: ImageSource.camera))];
    } else {
      images = await ImagePicker().pickMultiImage();
    }

    for (XFile? file in images) {
      if (file == null) continue;
      var url = await StorageService.uploadJobImage(file.path);
      job.photosUrl.add(url);
    }

    enterprises.replace(widget.enterprise);
  }

  void _removeImage(Job job, int index) async {
    final enterprises = EnterprisesProvider.of(context, listen: false);
    await StorageService.removeJobImage(job.photosUrl[index]);
    job.photosUrl.removeAt(index);

    enterprises.replace(widget.enterprise);
  }

  void _addSstEvent(Job job) async {
    final enterprises = EnterprisesProvider.of(context, listen: false);

    final result = await showDialog(
      context: context,
      builder: (context) => const AddSstEventDialog(),
    );
    if (result == null) return;

    final incident = Incident(result['description']);
    switch (result['eventType']) {
      case SstEventType.severe:
        job.incidents.severeInjuries.add(incident);
        break;
      case SstEventType.verbal:
        job.incidents.verbalAbuses.add(incident);
        break;
      case SstEventType.minor:
        job.incidents.minorInjuries.add(incident);
        break;
    }
    enterprises.replaceJob(widget.enterprise, job);
  }

  void _addComment(Job job) async {
    final provider = EnterprisesProvider.of(context, listen: false);
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

  void _updateSections() {
    for (Job job in widget.enterprise.jobs) {
      _expandedSections.putIfAbsent(
          job.id, () => [false, false, false, false, false, false]);
      _prerequisitesFormKeys.putIfAbsent(
          job.id, () => GlobalKey<PrerequisitesBodyState>());
      _isEditingPrerequisites.putIfAbsent(job.id, () => false);
    }
    setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _updateSections();
    context.read<EnterprisesProvider>().addListener(() {
      if (mounted) {
        _updateSections();
      }
    });
  }

  void _onClickPrerequisiteEdit(Job job) {
    // If we have to validate something before switching
    if (_isEditingPrerequisites[job.id]!) {
      final formKey =
          _prerequisitesFormKeys[job.id]!.currentState!.formKey.currentState!;
      if (!formKey.validate()) {
        return;
      }

      final enterprises = EnterprisesProvider.of(context, listen: false);

      widget.enterprise.jobs.replace(job.copyWith(
        minimumAge: _prerequisitesFormKeys[job.id]!.currentState!.minimumAge,
        preInternshipRequest: PreInternshipRequest(
            requests:
                _prerequisitesFormKeys[job.id]!.currentState!.prerequisites),
        uniform: _prerequisitesFormKeys[job.id]!.currentState!.uniforms,
        protections: _prerequisitesFormKeys[job.id]!.currentState!.protections,
      ));
      enterprises.replace(widget.enterprise);
    }

    _isEditingPrerequisites[job.id] = !_isEditingPrerequisites[job.id]!;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final jobs = [...widget.enterprise.jobs];
    jobs.sort(
      (a, b) => a.specialization.name
          .toLowerCase()
          .compareTo(b.specialization.name.toLowerCase()),
    );

    return SingleChildScrollView(
      child: ExpansionPanelList.radio(
        initialOpenPanelValue: jobs.length == 1 ? jobs.first.id : null,
        children: jobs
            .map((job) => ExpansionPanelRadio(
                canTapOnHeader: true,
                value: job.id,
                headerBuilder: (context, isExpanded) =>
                    SubTitle(job.specialization.name, top: 12),
                body: Column(
                  children: [
                    ExpansionPanelList(
                      expansionCallback: (panelIndex, isExpanded) async {
                        if (isEditing) {
                          if (!await ConfirmExitDialog.show(
                            context,
                            message:
                                'Enregistrer vos modifications en cliquant sur '
                                'la disquette, sinon, elles seront perdues.',
                          )) return;
                          cancelEditing();
                        }
                        _expandedSections[job.id]![panelIndex] = !isExpanded;
                        setState(() {});
                      },
                      children: [
                        PrerequisitesExpansionPanel(
                          key: _prerequisitesFormKeys[job.id]!,
                          isExpanded: _expandedSections[job.id]![0],
                          isEditing: _isEditingPrerequisites[job.id]!,
                          enterprise: widget.enterprise,
                          job: job,
                          onClickEdit: () => _onClickPrerequisiteEdit(job),
                        ),
                        SstExpansionPanel(
                          isExpanded: _expandedSections[job.id]![1],
                          enterprise: widget.enterprise,
                          job: job,
                          addSstEvent: _addSstEvent,
                        ),
                        IncidentsExpansionPanel(
                          isExpanded: _expandedSections[job.id]![2],
                          enterprise: widget.enterprise,
                          job: job,
                          addSstEvent: _addSstEvent,
                        ),
                        SupervisionExpansionPanel(
                          isExpanded: _expandedSections[job.id]![3],
                          job: job,
                        ),
                        PhotoExpansionPanel(
                          isExpanded: _expandedSections[job.id]![4],
                          job: job,
                          addImage: _addImage,
                          removeImage: _removeImage,
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
