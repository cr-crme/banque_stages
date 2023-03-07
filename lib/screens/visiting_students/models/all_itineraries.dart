import 'package:enhanced_containers/enhanced_containers.dart';

import '/screens/visiting_students/models/waypoints.dart';
import 'itinerary.dart';

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
