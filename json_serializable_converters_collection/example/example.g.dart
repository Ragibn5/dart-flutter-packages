// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'example.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuthData _$AuthDataFromJson(Map<String, dynamic> json) => AuthData(
      accessToken: json['accessToken'] as String,
      expiresAt: const Rfc3339UTCDateTimeJsonConverter()
          .fromJson(json['expiresAt'] as String),
    );

Map<String, dynamic> _$AuthDataToJson(AuthData instance) => <String, dynamic>{
      'accessToken': instance.accessToken,
      'expiresAt':
          const Rfc3339UTCDateTimeJsonConverter().toJson(instance.expiresAt),
    };
