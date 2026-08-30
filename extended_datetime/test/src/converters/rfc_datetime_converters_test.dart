import 'package:extended_datetime/src/converters/rfc_datetime_converters.dart';
import 'package:extended_datetime/src/extensions/iso_datetime_extensions.dart';
import 'package:test/test.dart';

void main() {
  const converter = RFCDateTimeConverters();

  test('toRFC3339String returns correct RFC 3339 string', () {
    final dateTime = DateTime(2023, 10, 5, 12, 30, 45);

    final rfcString = converter.toRFC3339String(dateTime);

    expect(
      rfcString,
      equals(dateTime.toIso8601String()),
    );
  });

  test('toRFC3339LocalString returns correct local RFC 3339 string', () {
    final dateTime = DateTime(2023, 10, 5, 12, 30, 45);

    final localRfcString = converter.toRFC3339LocalString(dateTime);

    expect(
      localRfcString,
      equals(dateTime.toISO8601LocalString()),
    );
  });

  test('toRFC3339UtcString returns correct UTC RFC 3339 string', () {
    final dateTime = DateTime(2023, 10, 5, 12, 30, 45);

    final utcRfcString = converter.toRFC3339UtcString(dateTime);

    expect(
      utcRfcString,
      equals(dateTime.toISO8601UtcString()),
    );
  });

  group('fromRFC3339StringToLocal', () {
    test('fromRFC3339StringToLocal returns correct local DateTime', () {
      final dateTime = DateTime(2023, 10, 5, 12, 30, 45);
      final rfcString = dateTime.toIso8601String();

      final parsed = converter.fromRFC3339StringToLocal(rfcString);

      expect(
        parsed,
        equals(DateTime.parse(rfcString).toLocal()),
      );
    });

    test(
      'fromRFC3339StringToLocal throws FormatException for invalid string',
      () {
        expect(
          () => converter.fromRFC3339StringToLocal('invalid-date'),
          throwsA(isA<FormatException>()),
        );
      },
    );
  });

  group('fromRFC3339StringToUtc', () {
    test('fromRFC3339StringToUtc returns correct UTC DateTime', () {
      final dateTime = DateTime(2023, 10, 5, 12, 30, 45);
      final rfcString = dateTime.toIso8601String();

      final parsed = converter.fromRFC3339StringToUtc(rfcString);

      expect(
        parsed,
        equals(DateTime.parse(rfcString).toUtc()),
      );
    });

    test(
      'fromRFC3339StringToUtc throws FormatException for invalid string',
      () {
        expect(
          () => converter.fromRFC3339StringToUtc('invalid-date'),
          throwsA(isA<FormatException>()),
        );
      },
    );
  });
}
