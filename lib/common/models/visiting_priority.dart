import 'package:flutter/material.dart';

enum VisitingPriority {
  low,
  mid,
  high,
  notApplicable,
}

extension VisitingPriorityStyled on VisitingPriority {
  MaterialColor get color {
    switch (this) {
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

  VisitingPriority next() {
    return VisitingPriority.values[(index + 1) % 3];
  }
}
