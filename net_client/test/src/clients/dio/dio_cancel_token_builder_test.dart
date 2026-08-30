// ignore_for_file: lines_longer_than_80_chars

import 'package:dio/dio.dart';
import 'package:net_client/src/clients/dio/dio_cancel_token_builder.dart';
import 'package:net_client/src/enums/http_method.dart';
import 'package:net_client/src/models/request_body.dart';
import 'package:net_client/src/models/request_spec.dart';
import 'package:net_client/src/services/cancellation/request_canceller.dart';
import 'package:test/test.dart';

void main() {
  final spec = RequestSpec(
    pathOrUrl: '/users',
    method: HttpMethod.POST,
    body: const JsonBody({'name': 'Alice'}),
  );

  late DioCancelTokenBuilder sut;

  setUp(() {
    sut = const DioCancelTokenBuilder();
  });

  test(
    'Returns null when requestCanceller is null',
    () {
      final cancelToken = sut.create(spec, null);

      expect(cancelToken, isNull);
    },
  );

  test(
    'Binds requestSpec to requestCanceller',
    () {
      final requestCanceller = RequestCanceller();

      sut.create(spec, requestCanceller);

      expect(requestCanceller.requestSpec, same(spec));
    },
  );

  test(
    'Returns a pre-cancelled CancelToken when requestCanceller is already cancelled',
    () {
      final requestCanceller = RequestCanceller()
        ..cancel(reason: 'user aborted');

      final cancelToken = sut.create(spec, requestCanceller);

      expect(cancelToken, isNotNull);
      expect(cancelToken!.isCancelled, isTrue);
    },
  );

  test(
    'Pre-cancelled reason matches requestCanceller reason',
    () async {
      final requestCanceller = RequestCanceller()
        ..cancel(reason: 'custom abort reason');

      final cancelToken = sut.create(spec, requestCanceller);

      expect(cancelToken, isNotNull);
      await expectLater(
        cancelToken!.whenCancel,
        completion(isA<DioException>()),
      );
    },
  );

  test(
    'Returns a non-cancelled CancelToken when requestCanceller is not yet cancelled',
    () {
      final requestCanceller = RequestCanceller();

      final cancelToken = sut.create(spec, requestCanceller);

      expect(cancelToken, isNotNull);
      expect(cancelToken!.isCancelled, isFalse);
    },
  );

  test(
    'CancelToken is cancelled when requestCanceller.cancel is called later',
    () async {
      final requestCanceller = RequestCanceller();

      final cancelToken = sut.create(spec, requestCanceller)!;

      expect(cancelToken.isCancelled, isFalse);

      requestCanceller.cancel(reason: 'user aborted');
      await Future<void>.delayed(Duration.zero);

      expect(cancelToken.isCancelled, isTrue);
    },
  );

  test(
    'CancelToken receives the cancellation reason when cancelled later',
    () async {
      final requestCanceller = RequestCanceller();

      final cancelToken = sut.create(spec, requestCanceller)!;

      requestCanceller.cancel(reason: 'later abort reason');
      await Future<void>.delayed(Duration.zero);

      expect(cancelToken.isCancelled, isTrue);
    },
  );
}
