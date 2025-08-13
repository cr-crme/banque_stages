import 'package:intl/intl.dart';
import 'package:stagess_common/models/enterprises/job.dart';

extension IncidentExtension on Incident {
  String format() => '${DateFormat('yyyy-MM-dd').format(date)} - $incident';
}
