enum VisitingPriority {
  low,
  mid,
  high,
  notApplicable,
  school;

  VisitingPriority get next => VisitingPriority.values[(index - 1) % 3];

  int serialize() => index;

  static VisitingPriority? deserialize(element) {
    if (element == null) return null;
    try {
      return VisitingPriority.values[element as int];
    } catch (e) {
      return null;
    }
  }
}
