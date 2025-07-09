import 'package:common/models/itineraries/itinerary.dart';
import 'package:common/utils.dart';
import 'package:common_flutter/providers/teachers_provider.dart';
import 'package:intl/intl.dart';

class ItinerariesHelpers {
  static void add(Itinerary item, {required TeachersProvider teachers}) {
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

  static Itinerary? fromDate(DateTime date,
      {required TeachersProvider teachers}) {
    final itineraries = teachers.myTeacher?.itineraries;
    if (itineraries == null) return null;

    final dateAsString = _dateFormat.format(date);
    return itineraries
        .firstWhereOrNull((e) => _dateFormat.format(e.date) == dateAsString);
  }
}
