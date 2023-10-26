import 'package:enhanced_containers/item_serializable.dart';

List<TaskAppreciationLevel> get byTaskAppreciationLevel => [
      TaskAppreciationLevel.autonomous,
      TaskAppreciationLevel.withReminder,
      TaskAppreciationLevel.withHelp,
      TaskAppreciationLevel.withConstantHelp,
      TaskAppreciationLevel.notEvaluated,
    ];

enum TaskAppreciationLevel {
  autonomous,
  withReminder,
  withHelp,
  withConstantHelp,
  notEvaluated,
  // The appreciation level does not apply when evaluating globally, we are
  // only interested to know if the task was evaluated or not
  evaluated;

  @override
  String toString() {
    switch (this) {
      case TaskAppreciationLevel.autonomous:
        return 'De façon autonome';
      case TaskAppreciationLevel.withReminder:
        return 'Avec rappel';
      case TaskAppreciationLevel.withHelp:
        return 'Avec de l\'aide occasionnelle';
      case TaskAppreciationLevel.withConstantHelp:
        return 'Avec de l\'aide constante';
      case TaskAppreciationLevel.notEvaluated:
        return 'Non faite (élève ne fait pas encore la tâche ou cette tâche '
            'n\'est pas offerte dans le milieu)';
      case TaskAppreciationLevel.evaluated:
        return '';
    }
  }

  String abbreviation() {
    switch (this) {
      case TaskAppreciationLevel.autonomous:
        return 'A';
      case TaskAppreciationLevel.withReminder:
        return 'B';
      case TaskAppreciationLevel.withHelp:
        return 'C';
      case TaskAppreciationLevel.withConstantHelp:
        return 'D';
      case TaskAppreciationLevel.notEvaluated:
        return 'NF';
      case TaskAppreciationLevel.evaluated:
        return '';
    }
  }
}

class TaskAppreciation extends ItemSerializable {
  final String title;
  final TaskAppreciationLevel level;

  TaskAppreciation({required this.title, required this.level});

  TaskAppreciation.fromSerialized(map)
      : title = map['title'] ?? '',
        level = map['level'] == null
            ? TaskAppreciationLevel.notEvaluated
            : TaskAppreciationLevel.values[map['level']],
        super.fromSerialized(map);

  @override
  Map<String, dynamic> serializedMap() =>
      {'id': id, 'title': title, 'level': level.index};
}
