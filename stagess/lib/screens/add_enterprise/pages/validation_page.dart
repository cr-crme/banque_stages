import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:stagess/common/widgets/sub_title.dart';
import 'package:stagess_common/models/enterprises/enterprise.dart';
import 'package:stagess_common/models/enterprises/enterprise_status.dart';
import 'package:stagess_common_flutter/providers/school_boards_provider.dart';
import 'package:stagess_common_flutter/widgets/enterprise_activity_type_list_tile.dart';
import 'package:stagess_common_flutter/widgets/enterprise_job_list_tile.dart';

final _logger = Logger('ValidationPage');

class ValidationPage extends StatefulWidget {
  const ValidationPage({super.key, required this.enterprise});

  final Enterprise enterprise;

  @override
  State<ValidationPage> createState() => _ValidationPageState();
}

class _ValidationPageState extends State<ValidationPage> {
  final _enterpriseJobControllers = {};
  late EnterpriseActivityTypeListController _enterpriseActivityTypesController =
      EnterpriseActivityTypeListController(
          initial: widget.enterprise.activityTypes);

  void _resetControllers() {
    for (final controller in _enterpriseJobControllers.values) {
      controller.dispose();
    }
    _enterpriseJobControllers.clear();
    _enterpriseJobControllers.addAll(
      [...widget.enterprise.jobs].asMap().map(
            (_, job) => MapEntry(
                job.id,
                EnterpriseJobListController(
                    context: context,
                    enterpriseStatus: EnterpriseStatus.active,
                    job: job)),
          ),
    );

    _enterpriseActivityTypesController = EnterpriseActivityTypeListController(
        initial: widget.enterprise.activityTypes);
  }

  @override
  dispose() {
    for (final controller in _enterpriseJobControllers.values) {
      controller.dispose();
    }
    _enterpriseActivityTypesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _logger.finer('Building ValidationPage');
    _resetControllers();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SubTitle('Coordonnées de l\'établissement', left: 0),
          const SizedBox(height: 4),
          Text('Nom de l\'entreprise',
              style: Theme.of(context).textTheme.titleSmall),
          Text(widget.enterprise.name.isEmpty
              ? 'Non spécifié'
              : widget.enterprise.name),
          const SizedBox(height: 8),
          Text('Adresse', style: Theme.of(context).textTheme.titleSmall),
          Text(widget.enterprise.address?.toString() ?? 'Non spécifiée'),
          const SizedBox(height: 8),
          Text('Téléphone de l\'établissement',
              style: Theme.of(context).textTheme.titleSmall),
          Text(widget.enterprise.phone.toString().isEmpty
              ? 'Non spécifié'
              : widget.enterprise.phone.toString()),
          const SizedBox(height: 16),
          const SubTitle('Entreprise représentée par', left: 0),
          const SizedBox(height: 4),
          Text('Nom de la personne représentant l\'entreprise',
              style: Theme.of(context).textTheme.titleSmall),
          Text(widget.enterprise.contact.fullName.isEmpty
              ? 'Non spécifié'
              : widget.enterprise.contact.fullName),
          const SizedBox(height: 8),
          Text('Fonction', style: Theme.of(context).textTheme.titleSmall),
          Text(widget.enterprise.contactFunction.isEmpty
              ? 'Non spécifiée'
              : widget.enterprise.contactFunction),
          const SizedBox(height: 8),
          Text('Téléphone', style: Theme.of(context).textTheme.titleSmall),
          Text(widget.enterprise.contact.phone.toString().isEmpty
              ? 'Non spécifié'
              : widget.enterprise.contact.phone.toString()),
          const SizedBox(height: 8),
          Text('Courriel', style: Theme.of(context).textTheme.titleSmall),
          Text((widget.enterprise.contact.email?.isEmpty ?? true)
              ? 'Non spécifié'
              : widget.enterprise.contact.email!),
          const SizedBox(height: 16),
          Text('Types d\'activités',
              style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 4),
          widget.enterprise.activityTypes.isEmpty
              ? const Text('Non spécifiés')
              : EnterpriseActivityTypeListTile(
                  hideTitle: true,
                  subtitle:
                      '* Sélectionner les mots clefs illustrant les activités de l’entreprise',
                  controller: _enterpriseActivityTypesController,
                  editMode: false,
                  activityTabAtTop: false,
                ),
          const SizedBox(height: 16),
          ...widget.enterprise.jobs.map((job) => EnterpriseJobListTile(
                schools:
                    SchoolBoardsProvider.of(context, listen: false).mySchool ==
                            null
                        ? []
                        : [
                            SchoolBoardsProvider.of(context, listen: false)
                                .mySchool!
                          ],
                elevation: 0,
                initialExpandedState: true,
                canChangeExpandedState: false,
                controller: _enterpriseJobControllers[job.id]!,
              )),
        ],
      ),
    );
  }
}
