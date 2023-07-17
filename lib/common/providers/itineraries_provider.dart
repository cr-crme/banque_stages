import 'package:collection/collection.dart';
import 'package:crcrme_banque_stages/common/providers/auth_provider.dart';
import 'package:enhanced_containers/enhanced_containers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/itinerary.dart';

class ItinerariesProvider extends FirebaseListProvided<Itinerary> {
  ItinerariesProvider()
      : super(
          pathToData: 'itineraries',
          pathToAvailableDataIds: '',
        );

  void initializeAuth(AuthProvider auth) {
    pathToAvailableDataIds = auth.currentUser == null
        ? ''
        : '/itineraries-ids/${auth.currentUser!.uid}/';
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
      {'itinerary': super.map((e) => e.serialize())};

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

  bool containsKey(String key) => hasId(key);

  bool hasDate(DateTime date) {
    final dateAsString = Itinerary.dateFormat.format(date);
    return indexWhere((e) => e.dateAsString == dateAsString) >= 0;
  }

  Itinerary? fromDate(DateTime date) {
    final dateAsString = Itinerary.dateFormat.format(date);
    return firstWhereOrNull((e) => e.dateAsString == dateAsString);
  }
}
