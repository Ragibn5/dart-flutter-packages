import 'dart:async';

import 'package:net_client/net_client.dart';
import 'package:test/test.dart';

class _TestQueuedInterceptor extends QueuedNetClientInterceptor {
  final Future<RequestInterceptorResult> Function(RequestSpec)? requestHandler;
  final Future<ResponseInterceptorResult> Function(RawResponse)?
      responseHandler;
  final Future<ErrorInterceptorResult> Function(NetClientException)?
      errorHandler;

  _TestQueuedInterceptor({
    this.requestHandler,
    this.responseHandler,
    this.errorHandler,
  });

  @override
  Future<RequestInterceptorResult> handleRequest(RequestSpec request) =>
      requestHandler?.call(request) ?? super.handleRequest(request);

  @override
  Future<ResponseInterceptorResult> handleResponse(RawResponse response) =>
      responseHandler?.call(response) ?? super.handleResponse(response);

  @override
  Future<ErrorInterceptorResult> handleError(NetClientException error) =>
      errorHandler?.call(error) ?? super.handleError(error);
}

RequestSpec _request(String path) =>
    RequestSpec(pathOrUrl: path, method: HttpMethod.GET);

RawResponse _response(String body) => RawResponse(
      statusCode: 200,
      rawResponseBody: body,
      responseHeaders: const {},
      request: _request('/source'),
    );

/// Returns a gate to pause/resume the first item, and events to assert on.
({Completer<void> gate, List<String> events}) _makeGate() =>
    (gate: Completer<void>(), events: <String>[]);

void main() {
  test('Processes requests in arrival order', () async {
    final (:gate, :events) = _makeGate();
    final firstStarted = Completer<void>();

    final sut = _TestQueuedInterceptor(
      requestHandler: (request) async {
        events.add('${request.pathOrUrl}-start');
        if (request.pathOrUrl == '/first') {
          firstStarted.complete();
          await gate.future;
        }
        events.add('${request.pathOrUrl}-end');
        return ContinueWithRequest(request);
      },
    );

    final firstFuture = sut.onRequest(_request('/first'));
    await firstStarted.future;

    final secondFuture = sut.onRequest(_request('/second'));
    await Future<void>.delayed(Duration.zero);

    expect(events, ['/first-start']);
    gate.complete();
    await Future.wait([firstFuture, secondFuture]);
    expect(
      events,
      ['/first-start', '/first-end', '/second-start', '/second-end'],
    );
  });

  test('Processes responses in arrival order', () async {
    final (:gate, :events) = _makeGate();
    final firstStarted = Completer<void>();

    final sut = _TestQueuedInterceptor(
      responseHandler: (response) async {
        // ignore: cast_nullable_to_non_nullable
        final marker = response.rawResponseBody as String;
        events.add('$marker-start');
        if (marker == 'first') {
          firstStarted.complete();
          await gate.future;
        }
        events.add('$marker-end');
        return ContinueWithResponse(response);
      },
    );

    final firstFuture = sut.onResponse(_response('first'));
    await firstStarted.future;

    final secondFuture = sut.onResponse(_response('second'));
    await Future<void>.delayed(Duration.zero);

    expect(events, ['first-start']);
    gate.complete();
    await Future.wait([firstFuture, secondFuture]);
    expect(events, ['first-start', 'first-end', 'second-start', 'second-end']);
  });

  test('Processes errors in arrival order', () async {
    final (:gate, :events) = _makeGate();
    final firstStarted = Completer<void>();

    final sut = _TestQueuedInterceptor(
      errorHandler: (error) async {
        final marker = (error as UnexpectedException).message;
        events.add('$marker-start');
        if (marker == 'first') {
          firstStarted.complete();
          await gate.future;
        }
        events.add('$marker-end');
        return ContinueWithError(error);
      },
    );

    final firstFuture = sut.onError(UnexpectedException(
      message: 'first',
      request: _request('/first'),
    ));
    await firstStarted.future;

    final secondFuture = sut.onError(UnexpectedException(
      message: 'second',
      request: _request('/second'),
    ));
    await Future<void>.delayed(Duration.zero);

    expect(events, ['first-start']);
    gate.complete();
    await Future.wait([firstFuture, secondFuture]);
    expect(events, ['first-start', 'first-end', 'second-start', 'second-end']);
  });

  test('Does not block one phase on another phase', () async {
    final requestGate = Completer<void>();
    final responseGate = Completer<void>();
    final requestStarted = Completer<void>();
    final responseStarted = Completer<void>();
    final events = <String>[];

    final sut = _TestQueuedInterceptor(
      requestHandler: (request) async {
        events.add('request-start');
        requestStarted.complete();
        await requestGate.future;
        events.add('request-end');
        return ContinueWithRequest(request);
      },
      responseHandler: (response) async {
        events.add('response-start');
        responseStarted.complete();
        await responseGate.future;
        events.add('response-end');
        return ContinueWithResponse(response);
      },
    );

    final requestFuture = sut.onRequest(_request('/first'));
    await requestStarted.future;

    final responseFuture = sut.onResponse(_response('first'));
    await responseStarted.future;

    expect(events, ['request-start', 'response-start']);

    requestGate.complete();
    responseGate.complete();
    await Future.wait([requestFuture, responseFuture]);
    expect(
      events,
      ['request-start', 'response-start', 'request-end', 'response-end'],
    );
  });
}
