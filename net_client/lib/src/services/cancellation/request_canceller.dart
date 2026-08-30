import 'dart:async';

import 'package:meta/meta.dart';
import 'package:net_client/src/models/request_spec.dart';

/// Transport-agnostic request cancellation handle.
class RequestCanceller {
  Object? _reason;
  RequestSpec? _requestSpec;
  final _whenCancelCompleter = Completer<Object>();

  /// Corresponding request options for the request.
  ///
  /// This field can be null if the request was never submitted.
  RequestSpec? get requestSpec => _requestSpec;

  /// The reason of the cancellation.
  ///
  /// Note:
  /// - If [cancel] is not yet called, this will be null.
  /// - Otherwise, this will contain the reason passed with the [cancel] method.
  Object? get reason => _reason;

  /// When cancelled, this future will be resolved.
  Future<Object> get whenCancel => _whenCancelCompleter.future;

  /// Whether the token is cancelled.
  bool get isCancelled => _reason != null;

  /// Cancel the corresponding request.
  void cancel({required Object reason}) {
    if (_reason != null) {
      return;
    }

    _reason = reason;
    _whenCancelCompleter.complete(reason);
  }

  @internal
  void bindRequestSpec(RequestSpec requestSpec) {
    _requestSpec ??= requestSpec;
  }
}
