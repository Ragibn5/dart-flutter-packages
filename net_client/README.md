# net_client

An opinionated HTTP client.

## Installation

Add this to your `pubspec.yaml`

```yaml
dependencies:
  net_client: ^1.0.0
```

#### Or, From Git repo

```yaml
dependencies:
  net_client:
    git:
      url: https://github.com/Ragibn5/dart-flutter-packages.git
      path: net_client
      ref: net_client-1.0.0
```

Now run `dart pub get` (or `flutter pub get`).


## ✨ Features

Key features:

- ⚙️ Client configuration with per-request overrides.
- 📦 Typed request bodies with inferred content types.
- 🏷️ Customizable response classification.
- ⌨️ Granular, typed errors via `NetClientException` subtypes.
- 🔌 Plugins-free interceptor pipeline for request, response, and error lifecycle.
- 🛑 Cancellation of in-flight requests.
- 📊 Upload/download progress callbacks.

## 🚀 Get started

The usual flow is:

1. 🛠️ Create the client with base options/config.
2. 📝 Build the request specification that you want to execute.
3. 🚀 Execute and get the result/error.

For example,

```dart
import 'package:net_client/net_client.dart';

Future<void> main() async {
  // Create the client with base options/config
  final client = NetClientFactory().create(
    const ClientConfig(baseUrl: 'https://api.example.com'),
  );

  // Build the request specification that you want to execute
  final request = RequestSpec(
    pathOrUrl: '/users',
    method: HttpMethod.POST,
    body: const JsonBody({'name': 'Ragib'}),
  );

  // Execute and get the result/error.
  final result = await client.execute(spec: request);
  result.fold(
    onSuccess: (response) {
      print('Success: ${response.data}');
    },
    onFailure: (error) {
      switch (error) {
        case TransportException(type: final type):
          print('Transport error: $type');
        case CancellationException():
          print('Request was cancelled');
        case UnexpectedException(message: final message):
          print('Unexpected error: $message');
      }
    },
  );
}
```

### ⚙️ Configuration

Set defaults once on the client via `ClientConfig`:

```dart
final client = NetClientFactory().create(
  const ClientConfig(
    baseUrl: 'https://api.example.com',
    sendTimeout: Duration(seconds: 10),
    receiveTimeout: Duration(seconds: 10),
    connectionTimeout: Duration(seconds: 5),
    queryParameters: {'api_key': '...'},
    headers: {'x-app-id': 'my-app'},
    followRedirects: true,
    maxRedirects: 5,
  ),
);
```

Every default can be overridden per request. `RequestSpec` accepts the same fields, and per-request values take precedence over the client config. For collection fields (headers, query parameters), the values are merged with the request-specific entries taking precedence:

```dart
final request = RequestSpec(
  pathOrUrl: '/users',
  method: HttpMethod.GET,
  baseUrl: 'https://other-api.example.com', // overrides client baseUrl
  queryParameters: {'page': '1'}, // merged with the client defaults
  sendTimeout: const Duration(seconds: 3), // overrides client sendTimeout
);
```

### 📦 Request bodies

Bodies are represented as typed objects with an inferred content type. Currently, we have support for the following.

- `JsonBody` — maps to `application/json`.
- `FormUrlEncodedBody` — `application/x-www-form-urlencoded`.
- `MultipartBody` — `multipart/form-data`, with `MultipartFilePart` entries that take a `BytesSource` or `StreamSource`.
- `RawBody` — a `RawString`, `RawBytes`, or `RawStream`; its content type **must** be provided explicitly.

For example,

```dart
void main() {
  final jsonBody = JsonBody({'name': 'Ragib'}); // application/json
  final formBody = FormUrlEncodedBody({'q': 'dart'}); // application/x-www-form-urlencoded
  final multiPartBody = MultipartBody(fields, files); // multipart/form-data
  final rawBody = RawBody(RawString('raw'), contentType: 'text/plain'); // (Content type must be provided manually)
}
```

### 🏷️ Response classification

A `ResponseClassifier` decides whether a response is treated as an error:

```dart
class RefreshAwareClassifier implements ResponseClassifier {
  @override
  bool isError(RawResponse response) => response.statusCode >= 400;
}
```

Pass an instance as the `responseClassifier` argument to `execute(...)`. The default treats any status `>= 400` as an error.

### ⌨️ Typed errors

Failures are returned as typed `NetClientException` subtypes, so they can be handled exhaustively:

- `TransportException` — network failures, categorized via `TransportExceptionType` (e.g. connection/send/receive timeouts, connection errors, bad certificates).
- `CancellationException` — the request was explicitly cancelled through a `RequestCanceller`.
- `UnexpectedException` — anything else, with a summary `message`.

```dart
void main() {
  result.fold(
    onSuccess: (response) {
      // ...
    },
    onFailure: (error) {
      switch (error) {
        case TransportException(type: final type):
          print('Transport error: $type');
        case CancellationException():
          print('Request was cancelled');
        case UnexpectedException(message: final message):
          print('Unexpected error: $message');
      }
    },
  );
}
```

### 🔌 Interceptors

Interceptors hook into the request, response, and error lifecycle. Extend `NetClientInterceptor` and override any of `onRequest`, `onResponse`, or `onError`:

```dart
class LoggingInterceptor extends NetClientInterceptor {
  @override
  Future<RequestInterceptorResult> onRequest(RequestSpec request) async {
    print('-> ${request.method} ${request.pathOrUrl}');
    return ContinueWithRequest(request);
  }
}

void main() {
  // ...
  
  client.interceptors.add(LoggingInterceptor());
}
```

Each hook returns a result that either continues the chain or short-circuits it:

- **Request** — `ContinueWithRequest` (optionally modified), `ShortRequestWithError`, or `ShortRequestWithResponse` (skip the transport and return a synthetic response).
- **Response** — `ContinueWithResponse`, `ShortResponseWithError`, or `ShortResponseWithFinalResponse`.
- **Error** — `ContinueWithError`, `ShortErrorWithFinalError`, or `ShortErrorWithResponse` (recover from the error and return a response).

For sequencing-sensitive work (e.g. token refresh), extend `QueuedNetClientInterceptor` instead. It processes each phase in order across in-flight calls, so shared state is never raced.

### 🛑 Cancellation

To cancel an in-flight request, create a `RequestCanceller` and pass it to `execute(...)`:

```dart
void main() async {
  // ...
  
  final canceller = RequestCanceller();
  final result = await client.execute(spec: request, requestCanceller: canceller);

  // elsewhere...
  // canceller.cancel(reason: 'user navigated away');
}
```

Cancelling produces a `CancellationException`, which is handled by the usual error flow.

### 📊 Progress callbacks

Track upload/download progress via the `onSendProgress` and `onReceiveProgress` callbacks:

```dart
void main() async {
  // ...
  
  final result = await client.execute(
    spec: request,
    onSendProgress: (count, total) => print('sent $count/$total'),
    onReceiveProgress: (count, total) => print('received $count/$total'),
  );
}
```

> Progress callback may not be available or function in all request types.

## 📝 Example

See the [example](example/example.dart) and the source code documentations for more.