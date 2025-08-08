enum EnterpriseStatus {
  active,
  noLongerAcceptingInternships,
  bannedFromAcceptingInternships;

  @override
  String toString() {
    switch (this) {
      case EnterpriseStatus.active:
        return 'Milieu de stage actif';
      case EnterpriseStatus.noLongerAcceptingInternships:
        return 'Entreprise n\'accepte plus d\'élèves en stage (ex. entreprise fermée)';
      case EnterpriseStatus.bannedFromAcceptingInternships:
        return 'Entreprise n\'est plus autorisée à accueillir des stagiaires';
    }
  }

  int serialize() {
    return index;
  }

  static EnterpriseStatus? from(int? value) {
    if (value == null || value < 0 || value >= EnterpriseStatus.values.length) {
      return null;
    }
    return EnterpriseStatus.values[value];
  }
}
