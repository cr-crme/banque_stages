import 'package:backend/repositories/mysql_repository_helpers.dart';
import 'package:test/test.dart';

String _cleanQuery(String query) {
  return query
      .replaceAll(RegExp(r'\s+'),
          ' ') // Replace multiple spaces/tabs/newlines with single space
      .trim(); // Remove leading/trailing whitespace
}

void main() {
  test('MySql query crafter all table', () {
    // Remove spaces and new lines for comparison
    final query = _cleanQuery(craftSelectQuery(tableName: 'my_table'));

    expect(query, 'SELECT t.* FROM my_table t');
  });

  test('MySql query crafter element in table', () {
    final query =
        _cleanQuery(craftSelectQuery(tableName: 'my_table', id: 'my_id'));

    expect(query, 'SELECT t.* FROM my_table t WHERE t.id = "my_id"');
  });

  test('MySql query crafter element in table with specific id', () {
    final query = _cleanQuery(craftSelectQuery(
        tableName: 'my_table', idName: 'my_named_id', id: 'my_id'));

    expect(query, 'SELECT t.* FROM my_table t WHERE t.my_named_id = "my_id"');
  });

  test('MySql query crafter with table', () {
    final query =
        _cleanQuery(craftSelectQuery(tableName: 'my_table', sublists: [
      MySqlTable(
          tableName: 'table_name',
          referenceIdName: 'table_id',
          fieldsToFetch: ['field1', 'field2'],
          tableIdName: 'subtable_id'),
    ]));

    expect(
        query,
        'SELECT t.*, IFNULL(( SELECT JSON_ARRAYAGG( JSON_OBJECT( \'field1\', ml.field1, \'field2\', ml.field2 ) ) '
        'FROM table_name ml WHERE ml.table_id = t.subtable_id ), JSON_ARRAY()) AS table_name FROM my_table t');
  });

  test('MySql query crafter with normalized table', () {
    final query = _cleanQuery(craftSelectQuery(
        tableName: 'my_table',
        idName: 'my_named_id',
        id: 'my_id',
        sublists: [
          MySqlReferencedTable(
            tableName: 'subtable_name',
            fieldsToFetch: ['field1', 'field2'],
            referenceIdName: 'table_id',
            tableIdName: 'subtable_id',
          ),
        ]));

    expect(
        query,
        'SELECT t.*, ( SELECT JSON_ARRAYAGG( JSON_OBJECT( \'field1\', st.field1, \'field2\', st.field2 ) ) '
        'FROM subtable_name st WHERE st.table_id = t.subtable_id ) AS subtable_name '
        'FROM my_table t WHERE t.my_named_id = "my_id"');
  });

  test('MySql query crafter insert element', () {
    final query = _cleanQuery(craftInsertQuery(
        tableName: 'my_table', data: {'field1': 'value1', 'field2': 'value2'}));

    expect(query, 'INSERT INTO my_table (field1, field2) VALUES (?, ?)');
  });

  test('MySql query crafter update element', () {
    final query = _cleanQuery(craftUpdateQuery(
        tableName: 'my_table',
        idName: 'my_id',
        data: {'field1': 'value1', 'field2': 'value2'}));

    expect(query, 'UPDATE my_table SET field1 = ?, field2 = ? WHERE my_id = ?');
  });

  test('MySql query crafter delete element', () {
    final query =
        _cleanQuery(craftDeleteQuery(tableName: 'my_table', idName: 'my_id'));

    expect(query, 'DELETE FROM my_table WHERE my_id = ?');
  });
}
