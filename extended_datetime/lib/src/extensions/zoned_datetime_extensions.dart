import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

extension ZonedDateTimeExtensions on DateTime {
  /// Converts this [DateTime] instance to another [DateTime] instance
  /// in the specified time zone. The [timeZoneName] should be a valid
  /// time zone name.
  DateTime toDateTimeInTimeZone(String timeZoneName) {
    tz.initializeTimeZones();
    final location = tz.getLocation(timeZoneName);
    return tz.TZDateTime.from(this, location);
  }
}
