import 'dart:convert';

import 'package:enhanced_containers/enhanced_containers.dart';
import 'package:flutter/services.dart';

abstract class QuestionFileService {
  static Future<void> loadData() async {
    final file = await rootBundle.loadString("assets/questions.json");
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
      : questionProfessor = map["qp"],
        questionStudent = map["qs"],
        type = Type.fromSerialized(map["t"]),
        choices = Set.from(map["c"] ?? []),
        textQuestionProfessor = map["sp"],
        textQuestionStudent = map["ss"],
        super.fromSerialized(map);

  @override
  Map<String, dynamic> serializedMap() {
    throw "Question should not be serialized. Store its ID intead.";
  }

  String getQuestion(bool isProfessor) {
    if (isProfessor) {
      return questionProfessor;
    }

    return questionStudent;
  }

  String? getTextQuestion(bool isProfessor) {
    if (isProfessor) {
      return textQuestionProfessor;
    }

    return textQuestionStudent;
  }

  final String questionProfessor;
  final String questionStudent;
  final Type type;
  final Set<String> choices;
  final String? textQuestionProfessor;
  final String? textQuestionStudent;
}

enum Type {
  text,
  radio,
  checkbox;

  static Type fromSerialized(data) {
    switch (data) {
      case "Texte":
        return Type.text;
      case "Choix de réponse":
        return Type.checkbox;
      default:
        return Type.radio;
    }
  }
}
