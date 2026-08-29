import 'package:extended_datetime/src/extensions/iso_datetime_extensions.dart';
import 'package:test/test.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() {
  setUpAll(tz.initializeTimeZones);

  test('toIso8601LocalString returns correct local ISO 8601 string', () {
    final dateTime = DateTime(2023, 10, 5, 12, 30, 45);
    final localString = dateTime.toISO8601LocalString();

    expect(
      localString,
      equals(dateTime.toLocal().toIso8601String()),
    );
  });

  test('toIso8601UtcString returns correct UTC ISO 8601 string', () {
    final dateTime = DateTime(2023, 10, 5, 12, 30, 45);
    final utcString = dateTime.toISO8601UtcString();

    expect(
      utcString,
      equals(dateTime.toUtc().toIso8601String()),
    );
  });

  test(
    'toIso8601StringInTimeZone returns valid ISO8601 str in given time zone',
    () {
      const timeZoneName = 'America/New_York';
      final dateTime = DateTime(2023, 10, 5, 12, 30, 45);
      final timeZoneString = dateTime.toISO8601StringInTimeZone(timeZoneName);

      final location = tz.getLocation(timeZoneName);
      final dateTimeInTimeZone = tz.TZDateTime.from(dateTime, location);

      expect(
        timeZoneString,
        equals(dateTimeInTimeZone.toIso8601String()),
      );
    },
  );
}
