/// Represents the HTTP method used in a request.
enum HttpMethod {
  GET('GET'),
  HEAD('HEAD'),
  POST('POST'),
  PUT('PUT'),
  PATCH('PATCH'),
  DELETE('DELETE');

  /// The raw string value passed to the HTTP client.
  final String value;

  const HttpMethod(this.value);

  static HttpMethod fromValue(String value) {
    final normalizedValue = value.trim().toUpperCase();

    return HttpMethod.values.firstWhere(
      (method) => method.value == normalizedValue,
      orElse: () => throw ArgumentError.value(
        value,
        'value',
        'Unsupported HTTP method',
      ),
    );
  }
}
