enum VisitingPriority {
  low,
  mid,
  high,
  notApplicable,
  school;

  VisitingPriority get next => VisitingPriority.values[(index - 1) % 3];
}
