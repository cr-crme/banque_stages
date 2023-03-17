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

  IconData get icon {
    switch (this) {
      case (VisitingPriority.low):
        return Icons.looks_one;
      case (VisitingPriority.mid):
        return Icons.looks_two;
      case (VisitingPriority.high):
        return Icons.looks_3;
      default:
        return Icons.cancel;
    }
  }

  VisitingPriority next() {
    return VisitingPriority.values[(index + 1) % 3];
  }
}
