# json_serializable_converters_collection

A collection of reusable JSON converter implementations for json_serializable based modules.

## Installation

#### From pub.dev

Add this to your `pubspec.yaml`

```yaml
dependencies:
  json_serializable_converters_collection: ^1.0.0
```

#### Or, From Git repo

```yaml
dependencies:
  json_serializable_converters_collection:
    git:
      url: https://github.com/Ragibn5/dart-flutter-packages.git
      path: json_serializable_converters_collection
      ref: json_serializable_converters_collection-1.0.0
```

## Usage

Annotate a Dart class with `@JsonSerializable()` and apply the converter annotations you need. Run the build runner to generate the `toJson`/`fromJson` methods:

```sh
dart run build_runner build
```

See the [example](example/example.dart) for a complete runnable demonstration.

## Converters

### `Rfc3339UTCDateTimeJsonConverter`

Serializes `DateTime` fields to and from RFC 3339 UTC strings:

```dart
import 'package:json_annotation/json_annotation.dart';
import 'package:json_serializable_converters_collection/json_serializable_converters_collection.dart';

part 'auth_data_dto.g.dart';

@JsonSerializable()
class AuthDataDTO {
  final String userId;
  final String accessToken;

  @Rfc3339UTCDateTimeJsonConverter()
  final DateTime accessTokenExpiry;

  const AuthDataDTO({
    required this.userId,
    required this.accessToken,
    required this.accessTokenExpiry,
  });

  Map<String, dynamic> toJson() => _$AuthDataDTOToJson(this);

  factory AuthDataDTO.fromJson(Map<String, dynamic> json) =>
      _$AuthDataDTOFromJson(json);
}
```

> Note: Run the build runner afterward for this to take effect.

## Examples

See the [example](example/example.dart) for a complete runnable demonstration.
