import 'package:crcrme_banque_stages/common/models/task_appreciation.dart';
import 'package:flutter_test/flutter_test.dart';

import '../utils.dart';

void main() {
  group('TaskAppreciation', () {
    test('get all', () {
      final taskAppreciations = byTaskAppreciationLevel;
      expect(taskAppreciations.length, 5);
    });

    test('"abbreviations" are the right label', () {
      expect(TaskAppreciationLevel.values.length, 6);
      expect(TaskAppreciationLevel.autonomous.abbreviation(), 'A');
      expect(TaskAppreciationLevel.withReminder.abbreviation(), 'B');
      expect(TaskAppreciationLevel.withHelp.abbreviation(), 'C');
      expect(TaskAppreciationLevel.withConstantHelp.abbreviation(), 'D');
      expect(TaskAppreciationLevel.notEvaluated.abbreviation(), 'NF');
      expect(TaskAppreciationLevel.evaluated.abbreviation(), '');
    });

    test('is shown properly', () {
      expect(TaskAppreciationLevel.autonomous.toString(), 'De façon autonome');
      expect(TaskAppreciationLevel.withReminder.toString(), 'Avec rappel');
      expect(TaskAppreciationLevel.withHelp.toString(),
          'Avec de l\'aide occasionnelle');
      expect(TaskAppreciationLevel.withConstantHelp.toString(),
          'Avec de l\'aide constante');
      expect(
          TaskAppreciationLevel.notEvaluated.toString(),
          'Non faite (élève ne fait pas encore la tâche ou cette tâche '
          'n\'est pas offerte dans le milieu)');
      expect(TaskAppreciationLevel.evaluated.toString(), '');
    });

    test('serialization and deserialization works', () {
      final taskAppreciation = dummyTaskAppreciation();
      final serialized = taskAppreciation.serialize();
      final deserialized = TaskAppreciation.fromSerialized(serialized);

      expect(serialized, {
        'id': taskAppreciation.id,
        'title': taskAppreciation.title,
        'level': taskAppreciation.level.index,
      });

      expect(deserialized.id, taskAppreciation.id);
      expect(deserialized.title, taskAppreciation.title);
      expect(deserialized.level, taskAppreciation.level);

      // Test for empty deserialize to make sure it doesn't crash
      final emptyDeserialized =
          TaskAppreciation.fromSerialized({'id': 'emptyId'});
      expect(emptyDeserialized.id, 'emptyId');
      expect(emptyDeserialized.title, '');
      expect(emptyDeserialized.level, TaskAppreciationLevel.notEvaluated);
    });
  });
}
