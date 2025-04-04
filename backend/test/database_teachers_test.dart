import 'package:backend/database_teachers.dart';
import 'package:backend/exceptions.dart';
import 'package:test/test.dart';

void main() {
  test('Get teachers from DatabaseTeachers', () async {
    final teachers = await getTeachers();
    expect(teachers, isA<Map<String, dynamic>>());
    expect(teachers.length, 2);
    expect(teachers['0'], isA<Map<String, dynamic>>());
    expect(teachers['0']['name'], 'John Doe');
    expect(teachers['0']['age'], 60);
    expect(teachers['1'], isA<Map<String, dynamic>>());
    expect(teachers['1']['name'], 'Jane Doe');
    expect(teachers['1']['age'], 50);
  });

  test('Set all teachers to DatabaseTeachers', () async {
    expect(
      () async => await putTeachers(data: {'1': 'John Doe'}),
      throwsA(isA<InvalidRequestException>()),
    );
  });

  test('Get teacher from DatabaseTeachers', () async {
    final teacher = await getTeacher(id: '0');
    expect(teacher, isA<Map<String, dynamic>>());
    expect(teacher['name'], 'John Doe');
    expect(teacher['age'], 60);
  });

  test('Get teacher from DatabaseTeachers with invalid id', () async {
    expect(
      () async => await getTeacher(id: '2'),
      throwsA(isA<MissingDataException>()),
    );
  });

  test('Set teacher to DatabaseTeachers', () async {
    final teacher = await putTeacher(
      id: '0',
      data: {'name': 'John Smith', 'age': 45},
    );
    expect(teacher, isNull);
    final updatedTeacher = await getTeacher(id: '0');
    expect(updatedTeacher['name'], 'John Smith');
    expect(updatedTeacher['age'], 45);
  });

  test('Set new teacher to DatabaseTeachers', () async {
    final teacher = await putTeacher(
      id: '2',
      data: {'name': 'John Smith', 'age': 45},
    );
    expect(teacher, isNull);
    final newTeacher = await getTeacher(id: '2');
    expect(newTeacher['name'], 'John Smith');
    expect(newTeacher['age'], 45);
  });
}
