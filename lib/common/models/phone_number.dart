const _regExp =
    r'^(?:\+\(d{1,3})?\s?\(?(\d{3})(?:[-.\)\s]|\)\s)?(\d{3})[-.\s]?(\d{4,6})(?:\s(?:poste)?\s(\d{1,6}))?$';

class PhoneNumber {
  final String? areaCode;
  final String? cityCode;
  final String? number;
  final String? extension;

  static bool isValid(String number) => RegExp(_regExp).hasMatch(number);

  const PhoneNumber(
      {this.areaCode, this.cityCode, this.number, this.extension});

  factory PhoneNumber.fromString(number) {
    final reg = RegExp(_regExp);
    if (!reg.hasMatch(number)) return const PhoneNumber();

    final result = RegExp(_regExp).firstMatch(number)!;
    if (result.groupCount != 4) {
      throw 'Invalid number if PhoneNumber constructor';
    }

    return PhoneNumber(
        areaCode: result.group(1),
        cityCode: result.group(2),
        number: result.group(3),
        extension: result.group(4));
  }

  @override
  String toString() {
    return areaCode == null || cityCode == null || number == null
        ? ''
        : '($areaCode) $cityCode-$number${extension != null ? ' poste $extension' : ''}';
  }

  PhoneNumber deepCopy() {
    return PhoneNumber(
        areaCode: areaCode,
        cityCode: cityCode,
        number: number,
        extension: extension);
  }
}
