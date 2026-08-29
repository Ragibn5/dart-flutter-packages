// ignore_for_file: avoid_redundant_argument_values, lines_longer_than_80_chars

import 'package:json_converters/json_converters.dart';
import 'package:test/test.dart';

void main() {
  const sut = Rfc3339UTCDateTimeJsonConverter();

  group('`fromJson`', () {
    test('Parses RFC-3339 string and returns UTC DateTime', () {
      final dt = sut.fromJson('2023-05-12T13:27:45.123456Z');
      expect(dt.year, 2023);
      expect(dt.month, 5);
      expect(dt.day, 12);
      expect(dt.hour, 13);
      expect(dt.minute, 27);
      expect(dt.second, 45);
      expect(dt.millisecond, 123);
      expect(dt.microsecond, 456);
      expect(dt.isUtc, true);
    });

    test('Parses string without fractional seconds', () {
      final dt = sut.fromJson('2023-05-12T13:27:45Z');
      expect(dt.millisecond, 0);
      expect(dt.microsecond, 0);
    });

    test('Converts non-UTC timezone offset to UTC', () {
      final dt = sut.fromJson('2023-05-12T10:27:45.000+05:30');
      expect(dt.hour, 4);
      expect(dt.minute, 57);
      expect(dt.isUtc, true);
    });

    test('Throws FormatException for unparseable string', () {
      expect(() => sut.fromJson(''), throwsA(isA<FormatException>()));
      expect(() => sut.fromJson('not-a-date'), throwsA(isA<FormatException>()));
    });
  });

  group('`toJson`', () {
    test('Returns RFC-3339 UTC string with microsecond precision', () {
      final dt = DateTime.utc(2024, 6, 18, 9, 42, 37, 789, 123);
      expect(sut.toJson(dt), '2024-06-18T09:42:37.789123Z');
    });

    test('Omits trailing zero fractional digits', () {
      final dt = DateTime.utc(2024, 6, 18, 9, 42, 0, 0, 0);
      expect(sut.toJson(dt), '2024-06-18T09:42:00.000Z');
    });
  });

  group('Round-trip', () {
    test('fromJson → toJson → fromJson preserves the same instant', () {
      const original = '2024-12-25T15:30:45.123456Z';
      final dt = sut.fromJson(original);
      final json = sut.toJson(dt);
      expect(sut.fromJson(json), dt);
    });

    test('Non-UTC DateTime round-trips to the same instant', () {
      final dt = DateTime.parse('2024-06-18T14:30:00.000+05:30');
      final json = sut.toJson(dt);
      final parsed = sut.fromJson(json);
      expect(parsed.millisecondsSinceEpoch, dt.millisecondsSinceEpoch);
    });
  });
}
