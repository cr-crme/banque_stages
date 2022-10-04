import './risks.dart';

class Skill{
  String _name;
  int _code;
  List<String> _criteria;
  List<String> _task;
  List<Risk> _risks;

  Skill(this._name, this._code, this._criteria, this._task, this._risks);
}