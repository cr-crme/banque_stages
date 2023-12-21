import 'package:enhanced_containers/enhanced_containers.dart';
import 'package:geocoding/geocoding.dart';

class Address extends ItemSerializable {
  Address({
    super.id,
    this.civicNumber,
    this.street,
    this.appartment,
    this.city,
    this.postalCode,
  });

  static Address get empty => Address();

  final int? civicNumber;
  final String? street;
  final String? appartment;
  final String? city;
  final String? postalCode;

  // coverage:ignore-start
  static Future<Address?> fromString(String address) async {
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
  // coverage:ignore-end

  @override
  Map<String, dynamic> serializedMap() => {
        'number': civicNumber,
        'street': street,
        'appartment': appartment,
        'city': city,
        'postalCode': postalCode
      };

  static Address fromSerialized(map) => Address(
      id: map['id'],
      civicNumber: map['number'],
      street: map['street'],
      appartment: map['appartment'],
      city: map['city'],
      postalCode: map['postalCode']);

  Address copyWith({
    String? id,
    int? civicNumber,
    String? street,
    String? appartment,
    String? city,
    String? postalCode,
  }) {
    return Address(
        id: id ?? this.id,
        civicNumber: civicNumber ?? this.civicNumber,
        street: street ?? this.street,
        appartment: appartment ?? this.appartment,
        city: city ?? this.city,
        postalCode: postalCode ?? this.postalCode);
  }

  bool get isEmpty =>
      civicNumber == null &&
      street == null &&
      appartment == null &&
      city == null &&
      postalCode == null;

  bool get isValid =>
      civicNumber != null &&
      street != null &&
      city != null &&
      postalCode != null;

  @override
  String toString() {
    return isValid
        ? '$civicNumber $street${appartment == null ? '' : ' #$appartment'}, $city, $postalCode'
        : '';
  }
}
