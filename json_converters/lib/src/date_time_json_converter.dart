import 'package:extended_datetime/extended_datetime.dart';
import 'package:json_annotation/json_annotation.dart';

class Rfc3339UTCDateTimeJsonConverter
    implements JsonConverter<DateTime, String> {
  const Rfc3339UTCDateTimeJsonConverter();

  @override
  DateTime fromJson(String json) {
    return _rfcConverter.fromRFC3339StringToUtc(json);
  }

  @override
  String toJson(DateTime dateTime) {
    return dateTime.toRFC3339UtcString();
  }

  RFCDateTimeConverters get _rfcConverter => const RFCDateTimeConverters();
}
