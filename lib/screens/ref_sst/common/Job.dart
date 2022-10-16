/*
Class for convert json to an usable object
 */
import 'package:flutter/cupertino.dart';

class Job {
  String _name;
  int _code;
  List<Skill> _skills_list;

  Job(this._name, this._code, this._skills_list);
}

class Skill {
  String _name;
  int _code;
  List<String> _criteria;
  List<String> _task;
  List<Risk> _risks;

  Skill(this._name, this._code, this._criteria, this._task, this._risks);
}

class Risk {
  String _name;
  bool _isPresent;

  Risk(this._name, this._isPresent);
}
