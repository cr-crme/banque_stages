import 'package:flutter/material.dart';

enum VisitingPriority {
  none,
  low,
  mid,
  high,
  notApplicable,
}

extension VisitingPriorityStyled on VisitingPriority {
  MaterialColor get color {
    switch (this) {
      case (VisitingPriority.none):
        return Colors.deepPurple;
      case (VisitingPriority.low):
        return Colors.green;
      case (VisitingPriority.mid):
        return Colors.orange;
      case (VisitingPriority.high):
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  static IconData get icon {
    return Icons.flag;
  }
}
