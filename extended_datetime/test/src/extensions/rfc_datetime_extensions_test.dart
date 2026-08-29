import 'package:extended_datetime/src/extensions/iso_datetime_extensions.dart';
import 'package:extended_datetime/src/extensions/rfc_datetime_extensions.dart';
import 'package:test/test.dart';

void main() {
  group('toRfc3339String', () {
    test('toRfc3339String returns correct RFC 3339 string', () {
      final dateTime = DateTime(2023, 10, 5, 12, 30, 45);
      final rfcString = dateTime.toRFC3339String();

      expect(
        rfcString,
        equals(dateTime.toIso8601String()),
      );
    });

    test(
      'toRfc3339StringInTimeZone returns valid RFC 3339 str in given time zone',
      () {
        const timeZoneName = 'America/New_York';
        final dateTime = DateTime(2023, 10, 5, 12, 30, 45);
        final timeZoneRfcString =
            dateTime.toRFC3339StringInTimeZone(timeZoneName);

        expect(
          timeZoneRfcString,
          equals(dateTime.toISO8601StringInTimeZone(timeZoneName)),
        );
      },
    );
  });

  test('toRfc3339LocalString returns correct local RFC 3339 string', () {
    final dateTime = DateTime(2023, 10, 5, 12, 30, 45);
    final localRfcString = dateTime.toRFC3339LocalString();

    expect(
      localRfcString,
      equals(dateTime.toISO8601LocalString()),
    );
  });

  test('toRfc3339UtcString returns correct UTC RFC 3339 string', () {
    final dateTime = DateTime(2023, 10, 5, 12, 30, 45);
    final utcRfcString = dateTime.toRFC3339UtcString();

    expect(
      utcRfcString,
      equals(dateTime.toISO8601UtcString()),
    );
  });
}
