import 'dart:convert';

import 'package:common/models/generic/geographic_coordinate_system.dart';
import 'package:enhanced_containers_foundation/enhanced_containers_foundation.dart';
import 'package:http/http.dart' as http;

class Address extends ItemSerializable {
  Address({
    super.id,
    this.civicNumber,
    this.street,
    this.apartment,
    this.city,
    this.postalCode,
  });

  static Address get empty => Address();

  final int? civicNumber;
  final String? street;
  final String? apartment;
  final String? city;
  final String? postalCode;

  static Future<Address?> fromCoordinates(
      GeographicCoordinateSystem gcs) async {
    final String url =
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=${gcs.latitude}&lon=${gcs.longitude}';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) return null;

    final data = json.decode(response.body) as Map<String, dynamic>;
    if (data.isEmpty) return null;

    return Address(
      civicNumber: int.tryParse(data['address']['house_number']),
      street: data['address']['road'],
      city: data['address']['city'],
      postalCode: data['address']['postcode'],
    );
  }

  // coverage:ignore-start
  static Future<Address?> fromString(String address) async {
    final gcs = await GeographicCoordinateSystem.fromAddress(address);
    return await Address.fromCoordinates(gcs);
  }
  // coverage:ignore-end

  @override
  Map<String, dynamic> serializedMap() => {
        'civic': civicNumber,
        'street': street,
        'apartment': apartment,
        'city': city,
        'postal_code': postalCode
      };

  static Address fromSerialized(map) => Address(
      id: map['id'],
      civicNumber: map['civic'],
      street: map['street'],
      apartment: map['apartment'],
      city: map['city'],
      postalCode: map['postal_code']);

  Address copyWith({
    String? id,
    int? civicNumber,
    String? street,
    String? apartment,
    String? city,
    String? postalCode,
  }) {
    return Address(
        id: id ?? this.id,
        civicNumber: civicNumber ?? this.civicNumber,
        street: street ?? this.street,
        apartment: apartment ?? this.apartment,
        city: city ?? this.city,
        postalCode: postalCode ?? this.postalCode);
  }

  bool get isEmpty =>
      civicNumber == null &&
      street == null &&
      apartment == null &&
      city == null &&
      postalCode == null;
  bool get isNotEmpty => !isEmpty;

  bool get isValid =>
      civicNumber != null &&
      street != null &&
      city != null &&
      postalCode != null;

  @override
  String toString() {
    return isValid
        ? '$civicNumber $street${apartment == null ? '' : ' #$apartment'}, $city, $postalCode'
        : '';
  }
}
