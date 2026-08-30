import 'package:net_client/net_client.dart';

Future<void> main() async {
  final client = NetClientFactory().create(
    const ClientConfig(
      baseUrl: 'https://example.com/api',
      connectionTimeout: Duration(seconds: 5),
      receiveTimeout: Duration(seconds: 5),
    ),
  );

  final request = RequestSpec(
    pathOrUrl: '/users',
    method: HttpMethod.POST,
    body: const JsonBody({'name': 'Ragib'}),
    sendTimeout: const Duration(seconds: 2),
    receiveTimeout: const Duration(seconds: 2),
  );

  final result = await client.execute(spec: request);
  result.fold(
    onSuccess: (response) {
      print('Success: ${response.data}');
    },
    onFailure: (error) {
      switch (error) {
        case TransportException(type: final type):
          print('Transport error: $type');
        case UnexpectedException(message: final message):
          print('Unexpected error: $message');
        case CancellationException():
          print('Request was cancelled');
      }
    },
  );
}
