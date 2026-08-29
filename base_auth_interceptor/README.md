# base_auth_interceptor

A reusable auth interceptor base based on [`net_client`](https://pub.dev/packages/net_client) package.

## Installation

#### From pub.dev

Add this to your `pubspec.yaml`

```yaml
dependencies:
  base_auth_interceptor: ^1.0.0
```

#### Or, From Git repo

```yaml
dependencies:
  base_auth_interceptor:
    git:
      url: https://github.com/Ragibn5/dart-flutter-packages.git
      path: base_auth_interceptor
      ref: base_auth_interceptor-1.0.0
```

## 🚀 Get started

### AuthDataProvider

Supplies current and refreshed auth data.

```dart
/// Demo implementation
class AuthDataProviderImpl implements AuthDataProvider<String> {
  @override
  Future<String?> getAuthData() async => 'my-token';

  @override
  Future<String?> requestAuthDataRefresh(String oldAuthData) async => null;
}
```

### AuthRefreshPolicy

Decides when an auth error should trigger a refresh.

```dart
/// Demo implementation
class AuthRefreshPolicyImpl implements AuthRefreshPolicy<String> {
  @override
  bool didServerReportAuthError(RawResponse response) =>
      response.statusCode == HttpStatus.unauthorized;

  @override
  bool shouldRefreshAuthData(RequestSpec request, String authData) => false;
}
```

### AuthRequestTransformer

Adds auth data to requests.

```dart
/// Demo implementation
class AuthRequestTransformerImpl implements AuthRequestTransformer<String> {
  @override
  Future<RequestSpec> transformRequestWithAuthData(RequestSpec request,
      String authData,) async =>
      request.copyWith(
        headers: {...request.headers, HttpHeaders.authorizationHeader: 'Bearer $authData'},
      );
}
```

### RequestRetrier

Replays a request with refreshed auth data.

```dart
/// Demo implementation
class RequestRetrierImpl implements RequestRetrier<String> {
  @override
  Future<ApiCallResult> retryRequest(RequestSpec request,
      String refreshedAuthData,) async =>
      Success(NetClientResponse(
        isError: false,
        statusCode: 200,
        data: '',
        headers: {},
        requestSpec: request,
      ));
}
```

### Compose

Compose the earlier dependencies to build the interceptor.

```dart
/// Demo implementation
class AppAuthInterceptor extends BaseAuthInterceptor<String> {
  AppAuthInterceptor() : super(
    AuthDataProviderImpl(),
    AuthRefreshPolicyImpl(),
    AuthRequestTransformerImpl(),
    RequestRetrierImpl(),
  );
}
```

## 🧪 Example

See the [example](example/example.dart) for a complete demonstration.
