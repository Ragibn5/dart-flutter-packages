import 'package:extended_datetime/src/converters/iso_datetime_converters.dart';
import 'package:extended_datetime/src/extensions/iso_datetime_extensions.dart';
import 'package:test/test.dart';

void main() {
  const converter = ISODateTimeConverters();

  test('toISO8601LocalString returns correct local ISO 8601 string', () {
    final dateTime = DateTime(2023, 10, 5, 12, 30, 45);

    final localString = converter.toISO8601LocalString(dateTime);

    expect(
      localString,
      equals(dateTime.toISO8601LocalString()),
    );
  });

  test('toISO8601UtcString returns correct UTC ISO 8601 string', () {
    final dateTime = DateTime(2023, 10, 5, 12, 30, 45);

    final utcString = converter.toISO8601UtcString(dateTime);

    expect(
      utcString,
      equals(dateTime.toISO8601UtcString()),
    );
  });

  group('fromISO8601StringToLocal', () {
    test('fromISO8601StringToLocal returns correct local DateTime', () {
      final dateTime = DateTime(2023, 10, 5, 12, 30, 45);
      final isoString = dateTime.toIso8601String();

      final parsed = converter.fromISO8601StringToLocal(isoString);

      expect(
        parsed,
        equals(DateTime.parse(isoString).toLocal()),
      );
    });

    test(
      'fromISO8601StringToLocal throws FormatException for invalid string',
      () {
        expect(
          () => converter.fromISO8601StringToLocal('invalid-date'),
          throwsA(isA<FormatException>()),
        );
      },
    );
  });

  group('fromISO8601StringToUtc', () {
    test('fromISO8601StringToUtc returns correct UTC DateTime', () {
      final dateTime = DateTime(2023, 10, 5, 12, 30, 45);
      final isoString = dateTime.toIso8601String();

      final parsed = converter.fromISO8601StringToUtc(isoString);

      expect(
        parsed,
        equals(DateTime.parse(isoString).toUtc()),
      );
    });

    test(
      'fromISO8601StringToUtc throws FormatException for invalid string',
      () {
        expect(
          () => converter.fromISO8601StringToUtc('invalid-date'),
          throwsA(isA<FormatException>()),
        );
      },
    );
  });
}
