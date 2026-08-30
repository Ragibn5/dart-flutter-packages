import 'dart:async';

import 'package:meta/meta.dart';
import 'package:net_client/net_client.dart';

class _Task<T, R> {
  final T data;
  final Completer<R> completer;

  _Task(this.data, this.completer);
}

class _PhaseQueue<T, R> {
  final Future<R> Function(T) processor;

  final _queue = <_Task<T, R>>[];

  var _isProcessing = false;

  _PhaseQueue(this.processor);

  Future<R> enqueue(T data) {
    final completer = Completer<R>();
    _queue.add(_Task(data, completer));
    _drain();
    return completer.future;
  }

  void _drain() {
    if (_isProcessing || _queue.isEmpty) return;
    _isProcessing = true;
    _processNext();
  }

  Future<void> _processNext() async {
    final task = _queue.removeAt(0);
    try {
      final result = await processor(task.data);
      task.completer.complete(result);
    } catch (e, st) {
      task.completer.completeError(e, st);
    } finally {
      _isProcessing = false;
      _drain();
    }
  }
}

/// A base interceptor for work that must be handled in order.
///
/// Use this for interceptor logic that coordinates shared state across
/// multiple in-flight calls, such as token refresh, request gating, or
/// similar sequencing-sensitive flows.
///
/// ```dart
/// class MyInterceptor extends QueuedNetClientInterceptor {
///   @override
///   Future<RequestInterceptorResult> handleRequest(RequestSpec spec) async {
///     // attach token, etc.
///   }
/// }
/// ```
abstract class QueuedNetClientInterceptor extends NetClientInterceptor {
  late final _requestQueue =
      _PhaseQueue<RequestSpec, RequestInterceptorResult>(handleRequest);

  late final _responseQueue =
      _PhaseQueue<RawResponse, ResponseInterceptorResult>(handleResponse);

  late final _errorQueue =
      _PhaseQueue<NetClientException, ErrorInterceptorResult>(handleError);

  @internal
  @override
  Future<RequestInterceptorResult> onRequest(RequestSpec request) =>
      _requestQueue.enqueue(request);

  @internal
  @override
  Future<ResponseInterceptorResult> onResponse(RawResponse response) =>
      _responseQueue.enqueue(response);

  @internal
  @override
  Future<ErrorInterceptorResult> onError(NetClientException error) =>
      _errorQueue.enqueue(error);

  /// Handles a queued request hook invocation.
  Future<RequestInterceptorResult> handleRequest(RequestSpec request) =>
      super.onRequest(request);

  /// Handles a queued response hook invocation.
  Future<ResponseInterceptorResult> handleResponse(RawResponse response) =>
      super.onResponse(response);

  /// Handles a queued error hook invocation.
  Future<ErrorInterceptorResult> handleError(NetClientException error) =>
      super.onError(error);
}
