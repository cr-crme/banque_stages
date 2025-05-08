import 'package:common/models/itineraries/itinerary.dart';
import 'package:common/utils.dart';
import 'package:crcrme_banque_stages/common/providers/teachers_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ItinerariesHelpers {
  static List<Itinerary> myIninerariesOf(BuildContext context,
          {listen = true}) =>
      TeachersProvider.of(context, listen: listen).currentTeacher.itineraries;

  static void add(BuildContext context, Itinerary item, {bool notify = false}) {
    final teachers = TeachersProvider.of(context, listen: notify);
    final me = teachers.currentTeacher;

    final itineraries = teachers.currentTeacher.itineraries;
    final index = itineraries.indexWhere((e) => e.date == item.date);
    if (index < 0) {
      itineraries.add(item);
    } else {
      itineraries[index] = item;
    }
    teachers.replace(me.copyWith(itineraries: itineraries));
  }

  static final _dateFormat = DateFormat('dd_MM_yyyy');

  static bool hasDate(BuildContext context, DateTime date,
      {bool listen = false}) {
    final itineraries = myIninerariesOf(context, listen: listen);
    final dateAsString = _dateFormat.format(date);
    return itineraries.any((e) => _dateFormat.format(e.date) == dateAsString);
  }

  static Itinerary? fromDate(BuildContext context, DateTime date,
      {bool listen = false}) {
    final itineraries = myIninerariesOf(context, listen: listen);
    final dateAsString = _dateFormat.format(date);
    return itineraries
        .firstWhereOrNull((e) => _dateFormat.format(e.date) == dateAsString);
  }
}
