import 'package:common/models/enterprises/job.dart';
import 'package:intl/intl.dart';

extension IncidentExtension on Incident {
  String format() => '${DateFormat('yyyy-MM-dd').format(date)} - $incident';
}
