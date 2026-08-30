import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:json_serializable_converters_collection/json_serializable_converters_collection.dart';

part 'auth_data_dto.g.dart';

@JsonSerializable()
class AuthDataDTO extends Equatable {
  final String userId;
  final String accessToken;
  final String refreshToken;

  @Rfc3339UTCDateTimeJsonConverter()
  final DateTime accessTokenExpiry;

  @Rfc3339UTCDateTimeJsonConverter()
  final DateTime refreshTokenExpiry;

  const AuthDataDTO({
    required this.userId,
    required this.accessToken,
    required this.refreshToken,
    required this.accessTokenExpiry,
    required this.refreshTokenExpiry,
  });

  Map<String, dynamic> toJson() => _$AuthDataDTOToJson(this);

  factory AuthDataDTO.fromJson(Map<String, dynamic> json) =>
      _$AuthDataDTOFromJson(json);

  @override
  List<Object?> get props => [
    userId,
    accessToken,
    refreshToken,
    accessTokenExpiry,
    refreshTokenExpiry,
  ];
}
