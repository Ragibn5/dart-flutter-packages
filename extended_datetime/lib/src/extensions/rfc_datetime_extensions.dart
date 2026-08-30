import 'package:extended_datetime/src/extensions/iso_datetime_extensions.dart';

extension RFCDateTimeExtensions on DateTime {
  /// Returns full RFC3339 string representation of this [DateTime] instance.
  ///
  /// **Note:**
  /// - If it is in local time zone, the returned string is in local time zone.
  /// - If it is in UTC time zone, the returned string is in UTC time zone.
  ///
  /// Note, this is same as ISO8601 variant ([toIso8601String]),
  /// it is just for convenience.
  String toRFC3339String() {
    return toIso8601String();
  }

  /// Returns full RFC3339 string representation of this [DateTime] instance
  /// in the local time zone.
  ///
  /// **Note:**
  /// - If it is already in local time zone, no transformation happens
  ///   (date-time numerics are not altered).
  /// - If it is NOT already in local time zone, it is first converted
  ///   to local timezone (date-time numerics can be altered).
  ///
  /// Note, this is same as ISO8601 variant ([toISO8601LocalString]),
  /// it is just for convenience.
  String toRFC3339LocalString() {
    return toISO8601LocalString();
  }

  /// Returns full RFC3339 string representation of this [DateTime] instance
  /// in the UTC time zone.
  ///
  /// **Note:**
  /// - If it is already in UTC time zone, no transformation happens
  ///   (date-time numerics are not altered).
  /// - If it is NOT already in UTC time zone, it is first converted
  ///   to UTC time zone (date-time numerics can be altered).
  ///
  /// Note, this is same as ISO8601 variant ([toISO8601UtcString]),
  /// it is just for convenience.
  String toRFC3339UtcString() {
    return toISO8601UtcString();
  }

  /// Returns full RFC3339 string representation of this [DateTime] instance
  /// in the specified time zone.
  ///
  /// **Note:**
  /// - If it is already in the specified time zone, no transformation happens
  ///   (date-time numerics are not altered).
  /// - If it is NOT already in the specified time zone, it is first converted
  ///   to the specified timezone (date-time numerics are altered).
  ///
  /// Note, this is same as ISO8601 variant ([toISO8601StringInTimeZone]),
  /// it is just for convenience.
  String toRFC3339StringInTimeZone(String timeZoneName) {
    return toISO8601StringInTimeZone(timeZoneName);
  }
}
