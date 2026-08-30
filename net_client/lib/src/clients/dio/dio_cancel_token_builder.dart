import 'dart:async';

import 'package:dio/dio.dart';
import 'package:net_client/src/models/request_spec.dart';
import 'package:net_client/src/services/cancellation/request_canceller.dart';

class DioCancelTokenBuilder {
  const DioCancelTokenBuilder();

  CancelToken? create(
    RequestSpec requestSpec,
    RequestCanceller? requestCanceller,
  ) {
    if (requestCanceller == null) {
      return null;
    }

    requestCanceller.bindRequestSpec(requestSpec);

    final cancelToken = CancelToken();
    final reason = requestCanceller.reason;
    if (reason != null) {
      cancelToken.cancel(reason);
      return cancelToken;
    } else {
      unawaited(
        requestCanceller.whenCancel.then(cancelToken.cancel),
      );
    }

    return cancelToken;
  }
}
