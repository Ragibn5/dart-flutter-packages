import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:json_converters/json_converters.dart';

part 'example.g.dart';

@JsonSerializable()
class AuthData {
  final String accessToken;

  @Rfc3339UTCDateTimeJsonConverter()
  final DateTime expiresAt;

  const AuthData({required this.accessToken, required this.expiresAt});

  Map<String, dynamic> toJson() => _$AuthDataToJson(this);

  factory AuthData.fromJson(Map<String, dynamic> json) =>
      _$AuthDataFromJson(json);
}

void main() {
  // An API login response where the date-time arrives as an RFC 3339 string.
  final body = jsonDecode('''
  {
    "accessToken": "eyJhbGciOiJIUzI1NiJ9.token",
    "expiresAt": "2024-06-18T09:42:37.789123Z"
  }
  ''');

  final auth = AuthData.fromJson(body as Map<String, dynamic>);
  print('expiresAt (DateTime): ${auth.expiresAt}');

  final json = auth.toJson();
  print('toJson: $json');
}
