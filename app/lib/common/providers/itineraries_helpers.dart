import 'package:common/models/itineraries/itinerary.dart';
import 'package:common/utils.dart';
import 'package:common_flutter/providers/teachers_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ItinerariesHelpers {
  static List<Itinerary>? myItinerariesOf(BuildContext context,
          {listen = true}) =>
      TeachersProvider.of(context, listen: listen).myTeacher?.itineraries;

  static void add(BuildContext context, Itinerary item, {bool notify = false}) {
    final teachers = TeachersProvider.of(context, listen: notify);
    final me = teachers.myTeacher;
    if (me == null) throw Exception('No teacher found in context');

    final itineraries = me.itineraries;
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
    final itineraries = myItinerariesOf(context, listen: listen);
    if (itineraries == null) return false;

    final dateAsString = _dateFormat.format(date);
    return itineraries.any((e) => _dateFormat.format(e.date) == dateAsString);
  }

  static Itinerary? fromDate(BuildContext context, DateTime date,
      {bool listen = false}) {
    final itineraries = myItinerariesOf(context, listen: listen);
    if (itineraries == null) return null;

    final dateAsString = _dateFormat.format(date);
    return itineraries
        .firstWhereOrNull((e) => _dateFormat.format(e.date) == dateAsString);
  }
}
