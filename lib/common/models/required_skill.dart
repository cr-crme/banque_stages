enum RequiredSkills {
  communicateInWriting,
  communicateInEnglish,
  driveTrolley,
  interactWithCustomers,
  handleMoney;

  @override
  String toString() {
    switch (this) {
      case RequiredSkills.communicateInWriting:
        return 'Communiquer à l\'écrit';
      case RequiredSkills.communicateInEnglish:
        return 'Communiquer en anglais';
      case RequiredSkills.driveTrolley:
        return 'Conduire un chariot (élèves CFER)';
      case RequiredSkills.interactWithCustomers:
        return 'Interagir avec des clients';
      case RequiredSkills.handleMoney:
        return 'Manipuler de l\'argent';
    }
  }
}
