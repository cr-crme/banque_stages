import 'dart:convert';

import 'package:common/models/geographic_coordinate_system.dart';
import 'package:enhanced_containers_foundation/enhanced_containers_foundation.dart';
import 'package:http/http.dart' as http;

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
  bool get isNotEmpty => !isEmpty;

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
