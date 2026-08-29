import 'package:extended_datetime/extended_datetime.dart';

void main() {
  // Create a sample DateTime object
  final dateTime = DateTime(2023, 10, 5, 12, 30, 45);
  const isoConverter = ISODateTimeConverters();
  const rfcConverter = RFCDateTimeConverters();

  // Using IsoDateTimeExtensions
  print('--- Using IsoDateTimeExtensions ---');
  print('Local ISO 8601 String: ${dateTime.toISO8601LocalString()}');
  print('UTC ISO 8601 String: ${dateTime.toISO8601UtcString()}');
  print(
    'ISO 8601 String in "America/New_York": '
    '${dateTime.toISO8601StringInTimeZone("America/New_York")}',
  );

  // Convert to a DateTime in a different time zone
  final dateTimeInNewYork = dateTime.toDateTimeInTimeZone('America/New_York');
  print('DateTime in "America/New_York": $dateTimeInNewYork');

  // Using RfcDateTimeExtensions
  print('\n--- Using RfcDateTimeExtensions ---');
  print('RFC 3339 String: ${dateTime.toRFC3339String()}');
  print('Local RFC 3339 String: ${dateTime.toRFC3339LocalString()}');
  print('UTC RFC 3339 String: ${dateTime.toRFC3339UtcString()}');
  print(
    'RFC 3339 String in "America/New_York": '
    '${dateTime.toRFC3339StringInTimeZone("America/New_York")}',
  );

  // Convert to a DateTime in a different time zone
  final dateTimeInLondon = dateTime.toDateTimeInTimeZone('Europe/London');
  print('DateTime in "Europe/London": $dateTimeInLondon');

  // Using ZonedDateTimeExtensions
  print('\n--- Using ZonedDateTimeExtensions ---');
  final dateTimeInTokyo = dateTime.toDateTimeInTimeZone('Asia/Tokyo');
  print('DateTime in "Asia/Tokyo": $dateTimeInTokyo');

  final dateTimeInUtc = dateTime.toDateTimeInTimeZone('UTC');
  print('DateTime in "UTC": $dateTimeInUtc');

  // Using IsoDateTimeConverters
  print('\n--- Using IsoDateTimeConverters ---');
  print(
    'Local ISO 8601 String: '
    '${isoConverter.toISO8601LocalString(dateTime)}',
  );
  print(
    'UTC ISO 8601 String: '
    '${isoConverter.toISO8601UtcString(dateTime)}',
  );

  final isoLocalDateTime =
      isoConverter.fromISO8601StringToLocal('2023-10-05T12:30:45');
  print('Parsed Local DateTime from ISO 8601 String: $isoLocalDateTime');

  final isoUtcDateTime =
      isoConverter.fromISO8601StringToUtc('2023-10-05T12:30:45Z');
  print('Parsed UTC DateTime from ISO 8601 String: $isoUtcDateTime');

  // Using RfcDateTimeConverters
  print('\n--- Using RfcDateTimeConverters ---');
  print('RFC 3339 String: ${rfcConverter.toRFC3339String(dateTime)}');
  print(
    'Local RFC 3339 String: '
    '${rfcConverter.toRFC3339LocalString(dateTime)}',
  );
  print(
    'UTC RFC 3339 String: '
    '${rfcConverter.toRFC3339UtcString(dateTime)}',
  );

  final rfcLocalDateTime =
      rfcConverter.fromRFC3339StringToLocal('2023-10-05T12:30:45');
  print('Parsed Local DateTime from RFC 3339 String: $rfcLocalDateTime');

  final rfcUtcDateTime =
      rfcConverter.fromRFC3339StringToUtc('2023-10-05T12:30:45Z');
  print('Parsed UTC DateTime from RFC 3339 String: $rfcUtcDateTime');
}
