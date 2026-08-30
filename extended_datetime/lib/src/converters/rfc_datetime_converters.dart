import 'package:extended_datetime/src/converters/iso_datetime_converters.dart';
import 'package:extended_datetime/src/extensions/iso_datetime_extensions.dart';

class RFCDateTimeConverters {
  const RFCDateTimeConverters();

  /// Returns full RFC3339 string representation of this [DateTime] instance.
  ///
  /// **Note:**
  /// - If it is in local time zone, the returned string is in local time zone.
  /// - If it is in UTC time zone, the returned string is in UTC time zone.
  ///
  /// Note, this is same as ISO8601 variant ([DateTime.toIso8601String]),
  /// it is just for convenience.
  String toRFC3339String(DateTime dateTime) {
    return dateTime.toIso8601String();
  }

  /// Returns full RFC3339 string representation of this [DateTime] instance
  /// in the local time zone.
  ///
  /// **Note:**
  /// - If it is already in local time zone, no transformation happens
  ///   (date-time numerics are not altered).
  /// - If it is NOT already in local time zone, it is first converted
  ///   to local timezone (date-time numerics may be altered).
  ///
  /// Note, this is same as ISO8601 variant
  /// ([ISODateTimeExtensions.toISO8601LocalString]),
  /// it is just for convenience.
  String toRFC3339LocalString(DateTime dateTime) {
    return _isoConverter.toISO8601LocalString(dateTime);
  }

  /// Returns full RFC3339 string representation of this [DateTime] instance
  /// in the UTC time zone.
  ///
  /// **Note:**
  /// - If it is already in UTC time zone, no transformation happens
  ///   (date-time numerics are not altered).
  /// - If it is NOT already in UTC time zone, it is first converted
  ///   to UTC time zone (date-time numerics may be altered).
  ///
  /// Note, this is same as ISO8601 variant
  /// ([ISODateTimeExtensions.toISO8601UtcString]), it is just for convenience.
  String toRFC3339UtcString(DateTime dateTime) {
    return _isoConverter.toISO8601UtcString(dateTime);
  }

  /// Returns a local [DateTime] instance from a full RFC3339 string
  ///
  /// **Note:**
  /// If the [dateTimeString] does not represent a time in the device's local
  /// time zone, the returned [DateTime] instance may point to a different
  /// date-time, which is the result of converting the given time to local
  /// time.
  DateTime fromRFC3339StringToLocal(String dateTimeString) {
    return DateTime.parse(dateTimeString).toLocal();
  }

  /// Returns a UTC [DateTime] instance from a full RFC3339 string
  ///
  /// **Note:**
  /// If the [dateTimeString] does not represent a UTC time,
  /// the returned [DateTime] instance may point to a different date-time,
  /// which is the result of converting the given time to the equivalent
  /// UTC time.
  DateTime fromRFC3339StringToUtc(String dateTimeString) {
    return DateTime.parse(dateTimeString).toUtc();
  }

  /// We should define a const getter instead of instance field
  /// if we want to make the class constructor a constant constructor.
  /// See [https://dart.dev/tools/linter-rules/avoid_field_initializers_in_const_classes]
  /// for more information.
  ISODateTimeConverters get _isoConverter => const ISODateTimeConverters();
}
