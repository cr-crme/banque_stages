import 'dart:convert';

import 'package:enhanced_containers/enhanced_containers.dart';
import 'package:flutter/services.dart';

abstract class QuestionFileService {
  static Future<void> loadData() async {
    final file = await rootBundle.loadString('assets/questions.json');
    final json = jsonDecode(file) as List;

    _questions = List.from(
      json.map((e) => Question.fromSerialized(e)),
      growable: false,
    );
  }

  static Question fromId(String id) {
    return _questions.firstWhere((question) => question.id == id);
  }

  static List<Question> get questions => _questions;

  static List<Question> _questions = [];
}

class Question extends ItemSerializable {
  final String idSummary;
  final String question;
  final String? questionSummary;
  final Type type;
  final bool hasOther;
  final Set<String>? choices;
  final String? followUpQuestion;
  final String? followUpQuestionSummary;

  Question.fromSerialized(map)
      : idSummary = map['idSummary'],
        question = map['question'],
        questionSummary = map['summary'],
        type = Type.fromSerialized(map['type']),
        hasOther = map['hasOther'] == "Oui",
        choices = map['choices'] == null
            ? null
            : Set.from(
                (map['choices'] as List).map((e) => (e as String).trim())),
        followUpQuestion = map['followUp'],
        followUpQuestionSummary = map['followUpSummary'],
        super.fromSerialized(map);

  @override
  Map<String, dynamic> serializedMap() {
    throw 'Question should not be serialized. Store its ID intead.';
  }
}

enum Type {
  text,
  radio,
  checkbox;

  static Type fromSerialized(data) {
    switch (data) {
      case 'Texte':
        return Type.text;
      case 'Choix de réponse':
        return Type.checkbox;
      case 'Vrai ou Faux':
        return Type.radio;
      default:
        throw 'Wrong format';
    }
  }
}
