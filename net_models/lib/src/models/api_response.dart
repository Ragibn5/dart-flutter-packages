sealed class ApiResponse<Err, Res> {
  final int statusCode;
  final Map<String, List<String>>? headers;

  ApiResponse({required this.statusCode, required this.headers});

  T fold<T>({
    required T Function(Err) onFailure,
    required T Function(Res) onSuccess,
  }) {
    final self = this;
    return switch (self) {
      FailureResponse<Err>() => onFailure(self.error),
      SuccessResponse<Res>() => onSuccess(self.data),
      _ => throw StateError(
          'Invalid state: '
          'should have been either $FailureResponse, or $SuccessResponse',
        ),
    };
  }
}

final class SuccessResponse<Res> extends ApiResponse<Never, Res> {
  final Res data;

  SuccessResponse({
    required this.data,
    required super.statusCode,
    required super.headers,
  });
}

final class FailureResponse<Err> extends ApiResponse<Err, Never> {
  final Err error;

  FailureResponse({
    required this.error,
    required super.statusCode,
    required super.headers,
  });
}
