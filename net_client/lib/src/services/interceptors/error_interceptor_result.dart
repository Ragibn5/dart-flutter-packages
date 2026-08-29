import 'package:net_client/src/models/net_client_exception.dart';
import 'package:net_client/src/models/raw_response.dart';

sealed class ErrorInterceptorResult {
  const ErrorInterceptorResult();
}

/// Continues the interceptor chain with the (possibly replaced) error.
final class ContinueWithError extends ErrorInterceptorResult {
  final NetClientException error;

  const ContinueWithError(this.error);
}

/// Short-circuits the chain, returning this error immediately.
/// Remaining interceptors are skipped.
final class ShortErrorWithFinalError extends ErrorInterceptorResult {
  final NetClientException error;

  const ShortErrorWithFinalError(this.error);
}

/// Short-circuits the chain, recovering from the error and returning a
/// successful response instead. Remaining interceptors are skipped.
final class ShortErrorWithResponse extends ErrorInterceptorResult {
  final RawResponse response;

  const ShortErrorWithResponse(this.response);
}
