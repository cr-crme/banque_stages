import 'package:common/utils.dart';
import 'package:test/test.dart';

void main() {
  test('Is list equal', () {
    expect(isListEqual([1, 2, 3], [1, 2, 3]), true);
    expect(isListEqual([1, 2, 3], [1, 2]), false);
    expect(isListEqual([1, 2, 3], [1, 2, 3, 4]), false);
    expect(isListEqual([1, 2, 3], [1, 2, 4]), false);
    expect(isListEqual([1, 2, 3], [3, 2, 1]), false);

    expect(isNotListEqual([1, 2, 3], [1, 2, 3]), false);
    expect(isNotListEqual([1, 2, 3], [1, 2]), true);
    expect(isNotListEqual([1, 2, 3], [1, 2, 3, 4]), true);
    expect(isNotListEqual([1, 2, 3], [1, 2, 4]), true);
    expect(isNotListEqual([1, 2, 3], [3, 2, 1]), true);
  });

  test('List accessors', () {
    expect([1, 2, 3].firstOrNull, 1);
    expect([].firstOrNull, null);
    expect([1, 2, 3].firstWhereOrNull((e) => e == 2), 2);
    expect([1, 2, 3].firstWhereOrNull((e) => e == 4), null);
    expect([].firstWhereOrNull((e) => e == 4), null);
  });
}
