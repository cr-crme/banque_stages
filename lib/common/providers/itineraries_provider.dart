import 'package:collection/collection.dart';
import 'package:crcrme_banque_stages/common/providers/auth_provider.dart';
import 'package:enhanced_containers/enhanced_containers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/itinerary.dart';

class ItinerariesProvider extends FirebaseListProvided<Itinerary> {
  ItinerariesProvider({super.mockMe})
      : super(
          pathToData: 'itineraries',
          pathToAvailableDataIds: '',
        );

  void initializeAuth(AuthProvider auth) {
    pathToAvailableDataIds = auth.currentUser == null
        ? ''
        : '/itineraries-ids/${auth.currentUser?.uid ?? (kDebugMode ? 'default' : '')}/';
    initializeFetchingData();
  }

  static ItinerariesProvider of(BuildContext context, {listen = true}) =>
      Provider.of<ItinerariesProvider>(context, listen: listen);

  @override
  Itinerary deserializeItem(data) {
    return Itinerary.fromSerialized(data);
  }

  @override
  Map<String, dynamic> serialize() =>
      {'itinerary': super.map((e) => e.serialize()).toList()};

  // Make this list act as a Map<DateTime, Itinerary> using Itinerary.date
  @override
  void add(Itinerary item, {bool notify = false}) {
    final index = firstWhereOrNull((e) => e.date == item.date);
    if (index == null) {
      super.add(item);
    } else {
      super.replace(item);
    }
  }

  @override
  void replace(Itinerary item, {bool notify = false}) =>
      add(item, notify: notify);

  bool hasDate(DateTime date) {
    final dateAsString = Itinerary.dateFormat.format(date);
    return any((e) => e.dateAsString == dateAsString);
  }

  Itinerary? fromDate(DateTime date) {
    final dateAsString = Itinerary.dateFormat.format(date);
    return firstWhereOrNull((e) => e.dateAsString == dateAsString);
  }
}
