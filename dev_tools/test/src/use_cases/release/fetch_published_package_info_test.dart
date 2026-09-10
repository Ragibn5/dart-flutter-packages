// ignore_for_file: prefer_const_constructors

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dev_tools/src/models/published_package_info.dart';
import 'package:dev_tools/src/use_cases/release/fetch_published_package_info.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class _FakeHttpClientResponse extends Fake implements HttpClientResponse {
  _FakeHttpClientResponse(this.statusCode, this._body);

  @override
  final int statusCode;
  final String _body;

  @override
  Stream<S> transform<S>(StreamTransformer<List<int>, S> streamTransformer) {
    return Stream<List<int>>.fromIterable([utf8.encode(_body)]).transform(
      streamTransformer,
    );
  }
}

class _FakeHttpClientRequest extends Fake implements HttpClientRequest {
  _FakeHttpClientRequest(this._statusCode, this._body);

  final int _statusCode;
  final String _body;

  @override
  Future<HttpClientResponse> close() async {
    return _FakeHttpClientResponse(_statusCode, _body);
  }
}

class _FakeHttpClient extends Fake implements HttpClient {
  _FakeHttpClient({
    this.statusCode = HttpStatus.ok,
    this.body = '',
  });

  final int statusCode;
  final String body;

  @override
  Future<HttpClientRequest> getUrl(Uri url) async {
    return _FakeHttpClientRequest(statusCode, body);
  }

  @override
  void close({bool force = false}) {}
}

class _UnreachableHttpClient extends Fake implements HttpClient {
  _UnreachableHttpClient();

  @override
  Future<HttpClientRequest> getUrl(Uri url) async {
    throw const SocketException('connection refused');
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  late FetchPublishedPackageInfo sut;

  setUp(() {
    sut = const FetchPublishedPackageInfo();
  });

  Future<PublishedPackageInfo> run(HttpClient client) {
    return HttpOverrides.runZoned(
      () => sut('foo'),
      createHttpClient: (_) => client,
    );
  }

  test('should return empty info when the package has never been published',
      () async {
    final info = await run(_FakeHttpClient(statusCode: HttpStatus.notFound));

    expect(info.latestVersion, isNull);
    expect(info.versions, isEmpty);
  });

  test('should return the latest and all published versions', () async {
    final client = _FakeHttpClient(
      body: '{"latest": {"version": "2.0.0"}, '
          '"versions": [{"version": "1.0.0"}, {"version": "2.0.0"}]}',
    );

    final info = await run(client);

    expect(info.latestVersion, '2.0.0');
    expect(info.versions, <String>['1.0.0', '2.0.0']);
  });

  test('should throw PubDevLookupException on unexpected status codes',
      () async {
    await expectLater(
      run(_FakeHttpClient(statusCode: HttpStatus.internalServerError)),
      throwsA(
        isA<PubDevLookupException>().having(
          (e) => e.message,
          'message',
          contains('pub.dev returned status 500'),
        ),
      ),
    );
  });

  test('should throw PubDevLookupException when pub.dev cannot be reached',
      () async {
    await expectLater(
      run(_UnreachableHttpClient()),
      throwsA(
        isA<PubDevLookupException>().having(
          (e) => e.message,
          'message',
          contains('Could not reach pub.dev to verify foo'),
        ),
      ),
    );
  });
}
