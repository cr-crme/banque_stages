import 'package:admin_app/providers/teachers_provider.dart';
import 'package:admin_app/widgets/animated_expanding_card.dart';
import 'package:common/models/persons/teacher.dart';
import 'package:common/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TeacherListTile extends StatefulWidget {
  const TeacherListTile({
    super.key,
    required this.teacher,
    this.isExpandable = true,
    this.forceEditingMode = false,
  });

  final Teacher teacher;
  final bool isExpandable;
  final bool forceEditingMode;

  @override
  State<TeacherListTile> createState() => TeacherListTileState();
}

class TeacherListTileState extends State<TeacherListTile> {
  final formKey = GlobalKey<FormState>();
  bool _isExpanded = false;
  bool _isEditing = false;
  TextEditingController? _firstNameController;
  String get firstName =>
      _firstNameController?.text ?? widget.teacher.firstName;

  TextEditingController? _lastNameController;
  String get lastName => _lastNameController?.text ?? widget.teacher.lastName;

  final List<TextEditingController> _currentGroups = [];
  List<int> get groups =>
      _currentGroups
          .map((e) => int.tryParse(e.text))
          .where((e) => e != null)
          .map((e) => e!)
          .toList();

  TextEditingController? _emailController;
  String? get email => _emailController?.text ?? widget.teacher.email;

  @override
  void initState() {
    super.initState();
    if (widget.forceEditingMode) _onClickedEditing();
  }

  void _onClickedEditing() {
    if (_isEditing) {
      // Finish editing
      final newTeacher = widget.teacher.copyWith(
        firstName: _firstNameController?.text,
        lastName: _lastNameController?.text,
        email: _emailController?.text,
        groups:
            _currentGroups
                .map((e) => e.text)
                .where((e) => e.isNotEmpty)
                .toList(),
      );

      if (newTeacher.getDifference(widget.teacher).isNotEmpty) {
        TeachersProvider.of(context, listen: false).replace(newTeacher);
      }
    } else {
      // Start editing
      _firstNameController = TextEditingController(
        text: widget.teacher.firstName,
      );
      _lastNameController = TextEditingController(
        text: widget.teacher.lastName,
      );
      _currentGroups.clear();
      for (var group in widget.teacher.groups) {
        _currentGroups.add(TextEditingController(text: group));
      }
      _emailController = TextEditingController(text: widget.teacher.email);
    }

    setState(() => _isEditing = !_isEditing);
  }

  @override
  Widget build(BuildContext context) {
    return widget.isExpandable
        ? AnimatedExpandingCard(
          initialExpandedState: _isExpanded,
          onTapHeader: (isExpanded) => setState(() => _isExpanded = isExpanded),
          header: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 12.0, top: 8, bottom: 8),
                child: Text(
                  '${widget.teacher.firstName} ${widget.teacher.lastName}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              if (_isExpanded)
                IconButton(
                  icon: Icon(
                    _isEditing ? Icons.save : Icons.edit,
                    color: Colors.black,
                  ),
                  onPressed: _onClickedEditing,
                ),
            ],
          ),
          child: _buildEditingForm(),
        )
        : _buildEditingForm();
  }

  Widget _buildEditingForm() {
    return Form(
      key: formKey,
      child: Padding(
        padding: const EdgeInsets.only(left: 24.0, bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildName(),
            const SizedBox(height: 4),
            _buildGroups(),
            const SizedBox(height: 4),
            _buildEmail(),
          ],
        ),
      ),
    );
  }

  Widget _buildName() {
    return _isEditing
        ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _firstNameController,
              validator:
                  (value) =>
                      value?.isEmpty == true ? 'Le prénom est requis' : null,
              decoration: const InputDecoration(labelText: 'Prénom'),
            ),
            TextFormField(
              controller: _lastNameController,
              validator:
                  (value) =>
                      value?.isEmpty == true ? 'Le nom est requis' : null,
              decoration: const InputDecoration(labelText: 'Nom de famille'),
            ),
          ],
        )
        : Container();
  }

  Widget _buildGroups() {
    if (widget.teacher.groups.isEmpty && !_isEditing) {
      return const Text('Aucun groupe');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_isEditing)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < _currentGroups.length; i++)
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _currentGroups[i],
                        keyboardType: TextInputType.number,
                        decoration:
                            i == 0
                                ? const InputDecoration(labelText: 'Groupes')
                                : null,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed:
                          () => setState(() => _currentGroups.removeAt(i)),
                      icon: Icon(Icons.delete, color: Colors.red),
                    ),
                  ],
                ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextButton(
                    onPressed:
                        () => setState(
                          () => _currentGroups.add(TextEditingController()),
                        ),
                    child: const Text('Ajouter un groupe'),
                  ),
                ),
              ),
            ],
          ),
        if (!_isEditing) Text('Groupes : ${widget.teacher.groups.join(', ')}'),
      ],
    );
  }

  Widget _buildEmail() {
    return _isEditing
        ? TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value?.isEmpty == true) {
              return 'Le courriel est requis';
            }

            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value!)) {
              return 'Le courriel est invalide';
            }
            return null;
          },
          decoration: const InputDecoration(labelText: 'Courriel'),
        )
        : Text('Courriel : ${widget.teacher.email ?? 'Courriel introuvable'}');
  }
}
