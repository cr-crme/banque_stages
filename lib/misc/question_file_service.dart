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
    return _questions.firstWhere((sector) => sector.id == id);
  }

  static List<Question> get questions => _questions;

  static List<Question> _questions = [];
}

class Question extends ItemSerializable {
  Question.fromSerialized(map)
      : title = map['qp'],
        type = Type.fromSerialized(map['t']),
        choices = Set.from(
            (map['c'] as List?)?.map((e) => (e as String).trim()) ?? []),
        subquestion = map['sp'],
        super.fromSerialized(map);

  @override
  Map<String, dynamic> serializedMap() {
    throw 'Question should not be serialized. Store its ID intead.';
  }

  final String title;
  final Type type;
  final Set<String> choices;
  final String? subquestion;
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
