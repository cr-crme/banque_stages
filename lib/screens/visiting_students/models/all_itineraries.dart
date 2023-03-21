import 'package:enhanced_containers/enhanced_containers.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/screens/visiting_students/models/waypoints.dart';
import 'itinerary.dart';

class AllItineraries extends MapProvided<Itinerary> {
  static AllItineraries of(BuildContext context, {listen = true}) =>
      Provider.of<AllItineraries>(context, listen: listen);

  @override
  Itinerary deserializeItem(data) {
    final out = Itinerary();
    out.deserialize(data);
    return out;
  }
}

class AllStudentsWaypoints extends ListProvided<Waypoint> {
  static AllStudentsWaypoints of(BuildContext context, {listen = true}) =>
      Provider.of<AllStudentsWaypoints>(context, listen: listen);

  @override
  void notifyListeners() {
    super.notifyListeners();
  }

  @override
  Waypoint deserializeItem(data) {
    return Waypoint.deserialize(data);
  }
}
