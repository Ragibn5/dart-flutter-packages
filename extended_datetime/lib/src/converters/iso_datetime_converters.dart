import 'package:extended_datetime/src/extensions/iso_datetime_extensions.dart';

class ISODateTimeConverters {
  const ISODateTimeConverters();

  /// Returns full ISO8601 string representation of this [DateTime] instance
  /// in the local time zone.
  ///
  /// **Note:**
  /// - If it is already in local time zone, no transformation happens
  ///   (date-time numerics are not altered).
  /// - If it is NOT already in local time zone, it is first converted
  ///   to local timezone (date-time numerics may be altered).
  String toISO8601LocalString(DateTime dateTime) {
    return dateTime.toISO8601LocalString();
  }

  /// Returns full ISO8601 string representation of this [DateTime] instance
  /// in the UTC time zone.
  ///
  /// **Note:**
  /// - If it is already in UTC time zone, no transformation happens
  ///   (date-time numerics are not altered).
  /// - If it is NOT already in UTC time zone, it is first converted
  ///   to UTC time zone (date-time numerics may be altered).
  String toISO8601UtcString(DateTime dateTime) {
    return dateTime.toISO8601UtcString();
  }

  /// Returns a [DateTime] instance (in local time zone) from a full ISO8601
  /// string representation.
  ///
  /// **Note:**
  /// If the [dateTimeString] does not represent a time in the device's local
  /// time zone, the returned [DateTime] instance may point to a different
  /// date-time, which is the result of converting the given time to local
  /// time.
  DateTime fromISO8601StringToLocal(String dateTimeString) {
    return DateTime.parse(dateTimeString).toLocal();
  }

  /// Returns a [DateTime] instance (in UTC time zone) from a full ISO8601
  /// string representation.
  ///
  /// **Note:**
  /// If the [dateTimeString] does not represent a UTC time,
  /// the returned [DateTime] instance may point to a different date-time,
  /// which is the result of converting the given time to the equivalent
  /// UTC time.
  DateTime fromISO8601StringToUtc(String dateTimeString) {
    return DateTime.parse(dateTimeString).toUtc();
  }
}
