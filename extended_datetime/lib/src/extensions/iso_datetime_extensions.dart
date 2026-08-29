import 'package:extended_datetime/src/extensions/zoned_datetime_extensions.dart';

extension ISODateTimeExtensions on DateTime {
  /// Returns full ISO8601 string representation of this [DateTime] instance
  /// in the local time zone.
  ///
  /// **Note:**
  /// - If it is already in local time zone, no transformation happens
  ///   (date-time numerics are not altered).
  /// - If it is NOT already in local time zone, it is first converted
  ///   to local timezone (date-time numerics may be altered).
  String toISO8601LocalString() {
    return toLocal().toIso8601String();
  }

  /// Returns full ISO8601 string representation of this [DateTime] instance
  /// in the UTC time zone.
  ///
  /// **Note:**
  /// - If it is already in UTC time zone, no transformation happens
  ///   (date-time numerics are not altered).
  /// - If it is NOT already in UTC time zone, it is first converted
  ///   to UTC time zone (date-time numerics may be altered).
  String toISO8601UtcString() {
    return toUtc().toIso8601String();
  }

  /// Returns full ISO8601 string representation of this [DateTime] instance
  /// in the specified time zone.
  ///
  /// **Note:**
  /// - If it is already in the specified time zone, no transformation happens
  ///   (date-time numerics are not altered).
  /// - If it is NOT already in the specified time zone, it is first converted
  ///   to the specified timezone (date-time numerics may be altered).
  String toISO8601StringInTimeZone(String timeZoneName) {
    return toDateTimeInTimeZone(timeZoneName).toIso8601String();
  }
}
