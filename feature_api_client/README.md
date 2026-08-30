# feature_api_client

A feature-based type-safe network client over [`net_client`](https://pub.dev/packages/net_client) package.

## Installation

#### From pub.dev

Add this to your `pubspec.yaml`

```yaml
dependencies:
  dart_functionals: ^1.0.1
  net_client: ^1.0.0
  feature_api_client: ^1.0.0
```

#### Or, From Git repo

```yaml
dependencies:
  dart_functionals:
    git:
      url: https://github.com/Ragibn5/dart-flutter-packages.git
      path: dart_functionals
      ref: dart_functionals-1.0.1
  net_client:
    git:
      url: https://github.com/Ragibn5/dart-flutter-packages.git
      path: net_client
      ref: net_client-1.0.0
  feature_api_client:
    git:
      url: https://github.com/Ragibn5/dart-flutter-packages.git
      path: feature_api_client
      ref: feature_api_client-1.0.0
```

> **Note:** Both `dart_functionals` and `net_client` are required.

## Get started

This package is a thin, feature-based layer over [`net_client`](https://pub.dev/packages/net_client).

You define typed request/response/error contracts per API feature, and the client handles issuing the request and decoding the response — plus uniform error mapping.

### Define a feature client

Extend `FeatureApiClient<Req, Res, Err>` and implement its two contracts:

- `createRequest`: Create the request specification.
- `decodeResponse`: Decode the raw response to the expected type.

```dart
class UserClient extends FeatureApiClient<GetUserRequest, UserResponse, AppError> {
  UserClient(super.client);

  @override
  RequestSpec createRequest(GetUserRequest body) =>
      RequestSpec(
        pathOrUrl: 'https://api.example.com/users/${body.id}',
        method: HttpMethod.GET,
      );

  @override
  ApiResponse<AppError, UserResponse> decodeResponse(
    NetClientResponse response,
  ) =>
      SuccessResponse(
        data: UserResponse.fromJson(response.data),
        statusCode: response.statusCode,
        headers: response.headers,
      );
}
```

### 3. Make the call

```dart
void main() async {
  // ...

  final client = UserClient(netClient);

  final result = await client.request(GetUserRequest(id: '42'));
  result.fold(
    onSuccess: (response) => print('User: ${response.data}'),
    onFailure: (error) => print('Failed: $error'),
  );
}
```

## Example

See the [example](example/example.dart) for a complete demonstration.
