import 'package:enhanced_containers/enhanced_containers.dart';
import 'package:geocoding/geocoding.dart';

class Address extends ItemSerializable {
  Address({
    this.civicNumber,
    this.street,
    this.appartment,
    this.city,
    this.postalCode,
  });

  final int? civicNumber;
  final String? street;
  final String? appartment;
  final String? city;
  final String? postalCode;

  static Future<Address?> fromAddress(String address) async {
    final location = await locationFromAddress(address);
    if (location.isEmpty) return null;

    final placemark = await placemarkFromCoordinates(
        location.last.latitude, location.last.longitude);
    if (placemark.isEmpty) return null;

    return Address(
      civicNumber: int.tryParse(placemark.first.subThoroughfare!),
      street: placemark.first.thoroughfare,
      city: placemark.first.locality,
      postalCode: placemark.first.postalCode,
    );
  }

  @override
  Map<String, dynamic> serializedMap() => {
        'number': civicNumber,
        'street': street,
        'appartment': appartment,
        'city': city,
        'postalCode': postalCode
      };

  static Address fromSerialized(map) {
    return Address(
        civicNumber:
            map != null && map.containsKey('number') ? map['number'] : null,
        street: map != null && map.containsKey('street') ? map['street'] : null,
        appartment: map != null && map.containsKey('appartment')
            ? map['appartment']
            : null,
        city: map != null && map.containsKey('city') ? map['city'] : null,
        postalCode: map != null && map.containsKey('postalCode')
            ? map['postalCode']
            : null);
  }

  Address copyWith(
      {int? civicNumber,
      String? street,
      String? appartment,
      String? city,
      String? postalCode}) {
    return Address(
        civicNumber: civicNumber ?? this.civicNumber,
        street: street ?? this.street,
        appartment: appartment ?? this.appartment,
        city: city ?? this.city,
        postalCode: postalCode ?? this.postalCode);
  }

  Address deepCopy() {
    return Address(
        civicNumber: civicNumber,
        street: street,
        appartment: appartment,
        city: city,
        postalCode: postalCode);
  }

  bool get isEmpty =>
      civicNumber == null &&
      street == null &&
      appartment == null &&
      city == null &&
      postalCode == null;

  @override
  String toString() {
    return isEmpty
        ? ''
        : '$civicNumber $street${appartment == null ? '' : ' #$appartment'}, $city, $postalCode';
  }
}
