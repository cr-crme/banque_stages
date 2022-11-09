import 'package:enhanced_containers/enhanced_containers.dart';

import 'itinerary.dart';
import 'package:crcrme_banque_stages/screens/visiting_students/models/waypoints.dart';

class AllItineraries extends MapProvided<Itinerary> {
  @override
  Itinerary deserializeItem(data) {
    final out = Itinerary();
    out.deserialize(data);
    return out;
  }
}

class AllStudentsWaypoints extends ListProvided<Waypoint> {
  @override
  Waypoint deserializeItem(data) {
    return Waypoint.deserialize(data);
  }
}
