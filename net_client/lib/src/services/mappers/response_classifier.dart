import 'package:net_client/src/models/raw_response.dart';

abstract interface class ResponseClassifier {
  /// Determines whether a [response] should be treated as an error.
  bool isError(RawResponse response);
}

class DefaultResponseClassifier implements ResponseClassifier {
  const DefaultResponseClassifier();

  @override
  bool isError(RawResponse response) => response.statusCode >= 400;
}
