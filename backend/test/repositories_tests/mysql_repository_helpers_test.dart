import 'package:backend/repositories/mysql_helpers.dart';
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
    final query =
        _cleanQuery(MySqlHelpers.craftSelectQuery(tableName: 'my_table'));

    expect(query, 'SELECT t.* FROM my_table t');
  });

  test('MySql query crafter element in table', () {
    final query = _cleanQuery(
        MySqlHelpers.craftSelectQuery(tableName: 'my_table', id: 'my_id'));

    expect(query, 'SELECT t.* FROM my_table t WHERE t.id = "my_id"');
  });

  test('MySql query crafter element in table with specific id', () {
    final query = _cleanQuery(MySqlHelpers.craftSelectQuery(
        tableName: 'my_table', idName: 'my_named_id', id: 'my_id'));

    expect(query, 'SELECT t.* FROM my_table t WHERE t.my_named_id = "my_id"');
  });

  test('MySql query crafter with table', () {
    final query = _cleanQuery(
        MySqlHelpers.craftSelectQuery(tableName: 'my_table', sublists: [
      MySqlSelectSubQuery(
          dataTableName: 'table_name',
          idNameToDataTable: 'subtable_id',
          idNameToMainTable: 'table_id',
          fieldsToFetch: ['field1', 'field2'],
          asName: 'new_table'),
    ]));

    expect(
        query,
        'SELECT t.*, IFNULL(( SELECT JSON_ARRAYAGG( JSON_OBJECT( \'field1\', st.field1, \'field2\', st.field2 ) ) '
        'FROM table_name st WHERE st.subtable_id = t.table_id ), JSON_ARRAY()) AS new_table FROM my_table t');
  });

  test('MySql query crafter with normalized table', () {
    final query = _cleanQuery(MySqlHelpers.craftSelectQuery(
        tableName: 'my_table',
        idName: 'my_named_id',
        id: 'my_id',
        sublists: [
          MySqlJoinSubQuery(
            dataTableName: 'subtable_name',
            dataTableIdName: 'subtable_id',
            relationTableName: 'my_relation_table_name',
            idNameToDataTable: 'to_subtable_id',
            idNameToMainTable: 'to_main_table_id',
            mainTableIdName: 'main_id',
            fieldsToFetch: ['field1', 'field2'],
          ),
        ]));

    expect(
        query,
        'SELECT t.*, IFNULL(( SELECT JSON_ARRAYAGG( JSON_OBJECT( \'field1\', st.field1, \'field2\', st.field2 ) ) '
        'FROM my_relation_table_name idt JOIN subtable_name st ON idt.to_subtable_id = st.subtable_id '
        'WHERE idt.to_main_table_id = t.main_id ), JSON_ARRAY()) AS subtable_name '
        'FROM my_table t WHERE t.my_named_id = "my_id"');
  });

  test('MySql query crafter insert element', () {
    final query = _cleanQuery(MySqlHelpers.craftInsertQuery(
        tableName: 'my_table', data: {'field1': 'value1', 'field2': 'value2'}));

    expect(query, 'INSERT INTO my_table (field1, field2) VALUES (?, ?)');
  });

  test('MySql query crafter update element', () {
    final query = _cleanQuery(MySqlHelpers.craftUpdateQuery(
        tableName: 'my_table',
        idName: 'my_id',
        data: {'field1': 'value1', 'field2': 'value2'}));

    expect(query, 'UPDATE my_table SET field1 = ?, field2 = ? WHERE my_id = ?');
  });

  test('MySql query crafter delete element', () {
    final query = _cleanQuery(
        MySqlHelpers.craftDeleteQuery(tableName: 'my_table', idName: 'my_id'));

    expect(query, 'DELETE FROM my_table WHERE my_id = ?');
  });
}
