import 'package:backend/database_manager.dart';
import 'package:backend/exceptions.dart';
import 'package:common/communication_protocol.dart';
import 'package:test/test.dart';

void main() {
  test('Get teachers from DatabaseManagers', () async {
    final database = DatabaseManager();
    final teachers = await database.get(RequestFields.teachers, data: null);
    expect(teachers, isA<Map<String, dynamic>>());
    expect(teachers.length, 2);
    expect(teachers['0'], isA<Map<String, dynamic>>());
    expect(teachers['0']['name'], 'John Doe');
    expect(teachers['0']['age'], 60);
    expect(teachers['1'], isA<Map<String, dynamic>>());
    expect(teachers['1']['name'], 'Jane Doe');
    expect(teachers['1']['age'], 50);
  });

  test('Get teacher from DatabaseManagers', () async {
    final database = DatabaseManager();
    final teacher =
        await database.get(RequestFields.teacher, data: {'id': '0'});
    expect(teacher, isA<Map<String, dynamic>>());
    expect(teacher['name'], 'John Doe');
    expect(teacher['age'], 60);
  });

  test('Get teacher from DatabaseManagers with invalid id', () async {
    final database = DatabaseManager();
    expect(
      () async => await database.get(RequestFields.teacher, data: {'id': '2'}),
      throwsA(isA<MissingDataException>()),
    );
  });

  test('Get teacher from DatabaseManagers without id', () async {
    final database = DatabaseManager();
    expect(
      () async => await database.get(RequestFields.teacher, data: null),
      throwsA(isA<MissingFieldException>()),
    );
  });

  test('Set all teachers to DatabaseManagers', () async {
    final database = DatabaseManager();
    expect(
      () async =>
          await database.put(RequestFields.teachers, data: {'0': 'John Doe'}),
      throwsA(isA<InvalidRequestException>()),
    );
  });

  test('Set teacher to DatabaseManagers', () async {
    final database = DatabaseManager();
    final teacher = await database.put(RequestFields.teacher,
        data: {'id': '0', 'name': 'John Smith', 'age': 45});
    expect(teacher, isNull);
    final updatedTeacher =
        await database.get(RequestFields.teacher, data: {'id': '0'});
    expect(updatedTeacher['name'], 'John Smith');
    expect(updatedTeacher['age'], 45);
  });

  test('Set new teacher to DatabaseManagers', () async {
    final database = DatabaseManager();
    final teacher = await database.put(RequestFields.teacher,
        data: {'id': '2', 'name': 'John Smith', 'age': 45});
    expect(teacher, isNull);
    final newTeacher =
        await database.get(RequestFields.teacher, data: {'id': '2'});
    expect(newTeacher['name'], 'John Smith');
    expect(newTeacher['age'], 45);
  });

  test('Set teacher to DatabaseManagers without id', () async {
    final database = DatabaseManager();
    expect(
      () async => await database.put(RequestFields.teacher, data: {
        'name': 'John Smith',
        'age': 45,
      }),
      throwsA(isA<MissingFieldException>()),
    );
  });
}
