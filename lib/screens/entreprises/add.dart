import 'package:flutter/material.dart';

class AddEntreprise extends StatefulWidget {
  const AddEntreprise({Key? key}) : super(key: key);

  static const route = "/entreprises/add";

  @override
  State<AddEntreprise> createState() => _AddEntrepriseState();
}

class _AddEntrepriseState extends State<AddEntreprise> {
  int _currentStep = 0;

  // Infos
  static const _choicesRecrutedBy = ["?"];
  String _recrutedBy = _choicesRecrutedBy[0];

  bool _shareToOthers = true;

  // Métiers
  static const _choicesSectors = ["sector", "sector2", "sector3"];
  static const _choicesSpecialisation = [
    "specialisation",
    "specialisation2",
    "specialisation3"
  ];
  final List<Metier> _metiers = [
    Metier(_choicesSectors[0], _choicesSpecialisation[0])
  ];

  void addMetier() {
    setState(() {
      _metiers.add(Metier(_choicesSectors[0], _choicesSpecialisation[0]));
    });
  }

  void removeMetier(int index) {
    setState(() {
      _metiers.removeAt(index);

      if (_metiers.isEmpty) {
        addMetier();
      }
    });
  }

  void submit() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nouvelle entreprise"),
      ),
      body: Form(
        child: Stepper(
          type: StepperType.horizontal,
          currentStep: _currentStep,
          onStepContinue: () => setState(() {
            if (_currentStep == 2) {
              submit();
            } else {
              _currentStep += 1;
            }
          }),
          onStepTapped: (int index) => setState(() => _currentStep = index),
          onStepCancel: () => Navigator.pop(context),
          steps: [
            Step(
                isActive: _currentStep == 0,
                title: const Text("Informations"),
                content: SingleChildScrollView(
                  child: Column(
                    children: [
                      ListTile(
                        title: TextFormField(
                          decoration: const InputDecoration(labelText: "Nom"),
                        ),
                      ),
                      ListTile(
                        title: TextFormField(
                          decoration: const InputDecoration(labelText: "NEQ"),
                        ),
                      ),
                      ListTile(
                          title: const Text("Types d'activités"),
                          trailing: TextButton(
                            child: const Text("Modifier"),
                            onPressed: () {},
                          )),
                      ListTile(
                        title: const Text("Entreprise recrutée par"),
                        trailing: DropdownButton<String>(
                          value: _recrutedBy,
                          icon: const Icon(Icons.arrow_downward),
                          elevation: 16,
                          onChanged: (String? newValue) {
                            setState(() {
                              _recrutedBy = newValue!;
                            });
                          },
                          items: _choicesRecrutedBy.map((String value) {
                            return DropdownMenuItem(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                      SwitchListTile(
                          title: const Text("Partager l'entreprise"),
                          value: _shareToOthers,
                          onChanged: (bool newValue) => setState(() {
                                _shareToOthers = newValue;
                              })),
                    ],
                  ),
                )),
            Step(
              isActive: _currentStep == 1,
              title: const Text("Métiers"),
              content: ListView.builder(
                shrinkWrap: true,
                itemCount: _metiers.length,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (BuildContext context, int index) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        visualDensity: const VisualDensity(
                            vertical: VisualDensity.minimumDensity),
                        title: Text("Métier ${index + 1}",
                            textAlign: TextAlign.left),
                        trailing: IconButton(
                          onPressed: () => removeMetier(index),
                          icon: const Icon(Icons.delete_forever),
                          color: Colors.redAccent,
                        ),
                      ),
                      ListTile(
                        title: const Text("Secteur d'activités"),
                        trailing: DropdownButton<String>(
                          value: _metiers[index].sector,
                          icon: const Icon(Icons.arrow_downward),
                          elevation: 16,
                          onChanged: (String? newValue) {
                            setState(() {
                              _metiers[index].sector = newValue!;
                            });
                          },
                          items: _choicesSectors.map((String value) {
                            return DropdownMenuItem(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                      ListTile(
                        title: const Text("Métier semi-spécialisé"),
                        trailing: DropdownButton<String>(
                          value: _metiers[index].specialisation,
                          icon: const Icon(Icons.arrow_downward),
                          elevation: 16,
                          onChanged: (String? newValue) {
                            setState(() {
                              _metiers[index].specialisation = newValue!;
                            });
                          },
                          items: _choicesSpecialisation.map((String value) {
                            return DropdownMenuItem(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      )
                    ]),
              ),
            ),
            Step(
                isActive: _currentStep == 2,
                title: const Text("Contact"),
                content: SingleChildScrollView(
                  child: Column(
                    children: [
                      const Text("Personne contact en entreprise"),
                      ListTile(
                        title: TextFormField(
                          decoration: const InputDecoration(labelText: "Nom"),
                        ),
                      ),
                      ListTile(
                        title: TextFormField(
                          decoration:
                              const InputDecoration(labelText: "Fonction"),
                        ),
                      ),
                      ListTile(
                        title: TextFormField(
                          decoration: InputDecoration(
                              label: Row(children: const [
                            Icon(Icons.phone),
                            Padding(
                              padding: EdgeInsets.only(left: 8.0),
                              child: Text("Téléphone"),
                            )
                          ])),
                        ),
                      ),
                      ListTile(
                        title: TextFormField(
                          decoration: InputDecoration(
                              label: Row(children: const [
                            Icon(Icons.mail),
                            Padding(
                              padding: EdgeInsets.only(left: 8.0),
                              child: Text("Courriel"),
                            )
                          ])),
                        ),
                      ),
                      // const Text("Adresse de l'établissement")
                    ],
                  ),
                ))
          ],
          controlsBuilder: (context, details) => Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Visibility(
                visible: _currentStep == 1,
                child: ElevatedButton(
                  onPressed: () => addMetier(),
                  child: const Text("Ajouter un métier"),
                ),
              ),
              const Expanded(child: SizedBox()),
              OutlinedButton(
                  onPressed: details.onStepCancel,
                  child: const Text("Annuler")),
              const SizedBox(
                width: 20,
              ),
              TextButton(
                  onPressed: details.onStepContinue,
                  child: const Text("Prochain"))
            ],
          ),
        ),
      ),
    );
  }
}

class Metier {
  Metier(this.sector, this.specialisation);

  String sector;
  String specialisation;
}
