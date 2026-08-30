import 'package:extended_datetime/src/extensions/zoned_datetime_extensions.dart';
import 'package:test/test.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() {
  setUpAll(tz.initializeTimeZones);

  test('toDateTimeInTimeZone converts DateTime to specified time zone', () {
    const timeZoneName = 'America/New_York';
    final dateTime = DateTime(2023, 10, 5, 12, 30, 45);

    final dateTimeInTimeZone = dateTime.toDateTimeInTimeZone(timeZoneName);

    final location = tz.getLocation(timeZoneName);
    final expectedDateTimeInTimeZone = tz.TZDateTime.from(dateTime, location);

    expect(
      dateTimeInTimeZone,
      equals(expectedDateTimeInTimeZone),
    );
  });

  test('toDateTimeInTimeZone handles UTC time zone correctly', () {
    const timeZoneName = 'UTC';
    final dateTime = DateTime(2023, 10, 5, 12, 30, 45);

    final dateTimeInTimeZone = dateTime.toDateTimeInTimeZone(timeZoneName);

    final location = tz.getLocation(timeZoneName);
    final expectedDateTimeInTimeZone = tz.TZDateTime.from(dateTime, location);

    expect(
      dateTimeInTimeZone,
      equals(expectedDateTimeInTimeZone),
    );
  });

  test(
    'toDateTimeInTimeZone handles non-existent time zone gracefully',
    () {
      const timeZoneName = 'Invalid/TimeZone';
      final dateTime = DateTime(2023, 10, 5, 12, 30, 45);

      expect(
        () => dateTime.toDateTimeInTimeZone(timeZoneName),
        throwsA(isA<tz.LocationNotFoundException>()),
      );
    },
  );
}
