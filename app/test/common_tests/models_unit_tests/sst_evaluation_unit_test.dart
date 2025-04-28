import 'package:common/models/enterprises/job.dart';
import 'package:flutter_test/flutter_test.dart';

import '../utils.dart';

void main() {
  group('SstEvaluation', () {
    test('empty one is tagged non-filled', () {
      final sstEvaluation = JobSstEvaluation.empty;
      expect(sstEvaluation.isFilled, isFalse);

      sstEvaluation.update(questions: {
        'Q1': ['My answer']
      });
      expect(sstEvaluation.isFilled, isTrue);
    });

    test('"update" erases old answers', () {
      final sstEvaluation = JobSstEvaluation.empty;
      sstEvaluation.update(questions: {
        'Q1': ['My first answer']
      });
      expect(sstEvaluation.questions.length, 1);

      sstEvaluation.update(questions: {
        'Q2': ['My second first answer']
      });
      expect(sstEvaluation.questions.length, 1);

      sstEvaluation.update(questions: {
        'Q1': ['My first answer'],
        'Q2': ['My true second answer']
      });
      expect(sstEvaluation.questions.length, 2);
    });

    test('serialization and deserialization works', () {
      final sstEvaluation = dummyJobSstEvaluation();
      final serialized = sstEvaluation.serialize();
      final deserialized = JobSstEvaluation.fromSerialized(serialized);

      expect(serialized, {
        'id': sstEvaluation.id,
        'questions': sstEvaluation.questions,
        'date': DateTime(2000, 1, 1).millisecondsSinceEpoch,
      });

      expect(deserialized.id, sstEvaluation.id);
      expect(deserialized.questions, sstEvaluation.questions);

      // Test for empty deserialize to make sure it doesn't crash
      final emptyDeserialized =
          JobSstEvaluation.fromSerialized({'id': 'emptyId'});
      expect(emptyDeserialized.id, 'emptyId');
      expect(emptyDeserialized.questions, {});
      expect(emptyDeserialized.date.millisecondsSinceEpoch, 0);
    });
  });
}
