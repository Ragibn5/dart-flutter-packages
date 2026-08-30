import 'package:dart_functionals/dart_functionals.dart';
import 'package:net_client/src/models/net_client_exception.dart';
import 'package:net_client/src/models/raw_response.dart';
import 'package:net_client/src/models/request_spec.dart';
import 'package:net_client/src/services/cancellation/request_canceller.dart';
import 'package:net_client/src/types/progress_listener.dart';

abstract interface class NetworkRequestAdapter {
  /// Perform the actual HTTP request.
  Future<Result<NetClientException, RawResponse>> performRequest({
    required RequestSpec spec,
    ProgressListener? onSendProgress,
    ProgressListener? onReceiveProgress,
    RequestCanceller? requestCanceller,
  });

  /// Closes the adapter and frees its resources.
  Future<void> close();
}
