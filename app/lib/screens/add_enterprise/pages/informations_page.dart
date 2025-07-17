import 'package:common/models/enterprises/enterprise.dart';
import 'package:common_flutter/widgets/address_list_tile.dart';
import 'package:common_flutter/widgets/enterprise_activity_type_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

final _logger = Logger('InformationsPage');

class InformationsPage extends StatefulWidget {
  const InformationsPage({super.key});

  @override
  State<InformationsPage> createState() => InformationsPageState();
}

class InformationsPageState extends State<InformationsPage> {
  final _formKey = GlobalKey<FormState>();

  String? name;
  final addressController = AddressController();
  String? neq;

  final _activityTypesController = EnterpriseActivityTypeListController(
    initial: {},
  );
  Set<ActivityTypes> get activityTypes =>
      _activityTypesController.activityTypes;

  Future<String?> validate() async {
    _logger.finer('Validating InformationsPage with name: $name');

    await addressController.requestValidation();

    if (!_formKey.currentState!.validate()) {
      return 'Remplir tous les champs avec un *.';
    }

    _formKey.currentState!.save();

    return null;
  }

  @override
  Widget build(BuildContext context) {
    _logger.finer('Building InformationsPage of with name: $name');

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: FocusScope(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration:
                    const InputDecoration(labelText: '* Nom de l\'entreprise'),
                validator: (text) =>
                    text!.isEmpty ? 'Ajouter le nom de l\'entreprise.' : null,
                onSaved: (name) => this.name = name,
              ),
              SizedBox(height: 8),
              EnterpriseActivityTypeListTile(
                controller: _activityTypesController,
                editMode: true,
                activityTabAtTop: false,
              ),
              AddressListTile(
                title: 'Adresse',
                isMandatory: true,
                enabled: true,
                addressController: addressController,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
