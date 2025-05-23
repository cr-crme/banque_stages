import 'package:admin_app/screens/enterprises/enterprise_list_tile.dart';
import 'package:common/models/enterprises/enterprise.dart';
import 'package:flutter/material.dart';

class AddEnterpriseDialog extends StatefulWidget {
  const AddEnterpriseDialog({super.key});

  @override
  State<AddEnterpriseDialog> createState() => _AddEnterpriseDialogState();
}

class _AddEnterpriseDialogState extends State<AddEnterpriseDialog> {
  final _editingKey = GlobalKey();

  Future<void> _onClickedConfirm() async {
    final state = _editingKey.currentState as EnterpriseListTileState;

    // Validate the form
    if (!(await state.validate()) || !mounted) return;
    Navigator.of(context).pop(state.editedEnterprise);
  }

  void _onClickedCancel() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Text(
                'Nouvelle entreprise',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 16),

            const SizedBox(height: 12),
            Text('Compléter les informations'),
            const SizedBox(height: 8),
            EnterpriseListTile(
              key: _editingKey,
              enterprise: Enterprise.empty,
              isExpandable: false,
              forceEditingMode: true,
            ),
          ],
        ),
      ),
      actions: [
        OutlinedButton(onPressed: _onClickedCancel, child: Text('Annuler')),
        TextButton(onPressed: _onClickedConfirm, child: Text('Confirmer')),
      ],
    );
  }
}
