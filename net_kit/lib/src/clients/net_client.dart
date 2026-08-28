import 'dart:async';

import 'package:net_kit/src/clients/interceptor_pipeline.dart';
import 'package:net_kit/src/models/request_spec.dart';
import 'package:net_kit/src/services/cancellation/request_canceller.dart';
import 'package:net_kit/src/services/mappers/response_classifier.dart';
import 'package:net_kit/src/types/api_call_result.dart';
import 'package:net_kit/src/types/progress_listener.dart';

abstract interface class NetClient {
  /// Executes the given [spec] and returns a typed [ApiCallResult].
  Future<ApiCallResult> execute({
    required RequestSpec spec,
    ProgressListener? onSendProgress,
    ProgressListener? onReceiveProgress,
    RequestCanceller? requestCanceller,
    ResponseClassifier responseClassifier = const DefaultResponseClassifier(),
  });

  /// Closes the client and frees its resources.
  Future<void> close();

  /// The pipeline of interceptors attached to this client.
  InterceptorPipeline get interceptors;
}
