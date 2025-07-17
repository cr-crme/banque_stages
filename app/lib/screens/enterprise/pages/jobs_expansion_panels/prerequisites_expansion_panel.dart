import 'package:common/models/enterprises/enterprise.dart';
import 'package:common/models/enterprises/job.dart';
import 'package:common_flutter/widgets/checkbox_with_other.dart';
import 'package:common_flutter/widgets/enterprise_job_list_tile.dart';
import 'package:common_flutter/widgets/radio_with_follow_up.dart';
import 'package:crcrme_banque_stages/common/widgets/itemized_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logging/logging.dart';

final _logger = Logger('PrerequisitesExpansionPanel');

class PrerequisitesExpansionPanel extends ExpansionPanel {
  PrerequisitesExpansionPanel({
    required GlobalKey<PrerequisitesBodyState> key,
    required super.isExpanded,
    required bool isEditing,
    required Enterprise enterprise,
    required Function() onClickEdit,
    required Job job,
  }) : super(
          canTapOnHeader: true,
          body: _PrerequisitesBody(
            key: key,
            job: job,
            enterprise: enterprise,
            isEditing: isEditing,
          ),
          headerBuilder: (context, isExpanded) => ListTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Prérequis et équipements'),
                if (isExpanded)
                  SizedBox(
                    width: 50,
                    height: 50,
                    child: InkWell(
                        onTap: onClickEdit,
                        borderRadius: BorderRadius.circular(25),
                        child: Icon(isEditing ? Icons.save : Icons.edit,
                            color: Theme.of(context).primaryColor)),
                  ),
              ],
            ),
          ),
        );
}

class _PrerequisitesBody extends StatefulWidget {
  const _PrerequisitesBody({
    required super.key,
    required this.job,
    required this.enterprise,
    required this.isEditing,
  });

  final Job job;
  final Enterprise enterprise;
  final bool isEditing;

  @override
  State<_PrerequisitesBody> createState() => PrerequisitesBodyState();
}

class PrerequisitesBodyState extends State<_PrerequisitesBody> {
  final formKey = GlobalKey<FormState>();

  late final _ageController =
      TextEditingController(text: widget.job.minimumAge.toString());
  int get minimumAge =>
      _ageController.text.isEmpty ? -1 : int.parse(_ageController.text);

  final _uniformRequestKey = GlobalKey<RadioWithFollowUpState<UniformStatus>>();
  final _uniformTextController = TextEditingController();
  Uniforms get uniforms => Uniforms(
      status: _uniformRequestKey.currentState!.value!,
      uniforms: _uniformRequestKey.currentState!.value! == UniformStatus.none
          ? null
          : [_uniformTextController.text]);

  final _protectionsRequestKey =
      GlobalKey<RadioWithFollowUpState<ProtectionsStatus>>();
  final _protectionsController =
      GlobalKey<CheckboxWithOtherState<ProtectionsType>>();
  Protections get protections => Protections(
      status: _protectionsRequestKey.currentState!.value!,
      protections:
          _protectionsRequestKey.currentState!.value! == ProtectionsStatus.none
              ? []
              : _protectionsController.currentState!.values);

  final _preInternshipRequestKey =
      GlobalKey<CheckboxWithOtherState<PreInternshipRequestTypes>>();
  List<String> get prerequisites =>
      _preInternshipRequestKey.currentState!.values;

  @override
  Widget build(BuildContext context) {
    _logger.finer(
        'Building PrerequisitesExpansionPanel for job: ${widget.job.specialization.name}');

    return FocusScope(
      child: Form(
        key: formKey,
        child: SizedBox(
          width: Size.infinite.width,
          child: Padding(
            padding: const EdgeInsets.only(left: 24, right: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMinimumAge(),
                const SizedBox(height: 12),
                _buildEntepriseRequests(),
                const SizedBox(height: 12),
                _buildUniform(),
                const SizedBox(height: 12),
                _buildProtections(),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMinimumAge() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Âge minimum',
            style: TextStyle(fontWeight: FontWeight.bold)),
        widget.isEditing
            ? Row(
                children: [
                  SizedBox(
                    width: 100,
                    height: 35,
                    child: TextFormField(
                      controller: _ageController,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        final current = int.tryParse(value!);
                        if (current == null) return 'Préciser';
                        if (current < 10 || current > 30) {
                          return 'Entre 10 et 30';
                        }
                        return null;
                      },
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                  const Text(' ans')
                ],
              )
            : Text('${widget.job.minimumAge} ans'),
      ],
    );
  }

  Widget _buildUniform() {
    // Workaround for job.uniforms
    final uniforms = widget.job.uniforms;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tenue de travail',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        widget.isEditing
            ? BuildUniformRadio(
                hideTitle: true,
                uniformKey: _uniformRequestKey,
                uniformTextController: _uniformTextController
                  ..text = uniforms.status == UniformStatus.none
                      ? ''
                      : uniforms.uniforms.join('\n'),
                initialSelection: uniforms.status,
                onChanged: (value) => setState(() {}),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (uniforms.status == UniformStatus.none)
                    const Text('Aucune consigne de l\'entreprise'),
                  if (uniforms.status == UniformStatus.suppliedByEnterprise)
                    const Text('Fournie par l\'entreprise\u00a0:'),
                  if (uniforms.status == UniformStatus.suppliedByStudent)
                    const Text('Fournie par l\'élève\u00a0:'),
                  ItemizedText(uniforms.uniforms),
                ],
              )
      ],
    );
  }

  Widget _buildEntepriseRequests() {
    final requests = widget.job.preInternshipRequests.requests
        .map((e) => e.toString())
        .toList();
    if (widget.job.preInternshipRequests.other != null) {
      requests.add(widget.job.preInternshipRequests.other!);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Exigences de l\'entreprise',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        widget.isEditing
            ? BuildPrerequisitesCheckboxes(
                checkBoxKey: _preInternshipRequestKey,
                initialValues: requests,
                hideTitle: true,
              )
            : requests.isEmpty
                ? const Text('Aucune exigence particulière')
                : ItemizedText(requests),
      ],
    );
  }

  Widget _buildProtections() {
    final protections = widget.job.protections;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Équipements de protection individuelle',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        widget.isEditing
            ? BuildProtectionsRadio(
                hideTitle: true,
                protectionsKey: _protectionsRequestKey,
                protectionsTypeKey: _protectionsController,
                initialSelection: protections.status,
                initialItems: protections.protections,
                onChanged: (status, protections) => setState(() {}),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (protections.status == ProtectionsStatus.none)
                    const Text('Aucun équipement requis'),
                  if (protections.status ==
                      ProtectionsStatus.suppliedByEnterprise)
                    const Text('Fournis par l\'entreprise\u00a0:'),
                  if (protections.status == ProtectionsStatus.suppliedBySchool)
                    const Text(
                        'Non fournis par l\'entreprise.\n L\'élève devra porter\u00a0:'),
                  ItemizedText(protections.protections),
                ],
              )
      ],
    );
  }
}
