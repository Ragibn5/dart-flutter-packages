// ignore_for_file: cascade_invocations

import 'package:net_client/src/enums/http_method.dart';
import 'package:net_client/src/models/request_body.dart';
import 'package:net_client/src/models/request_spec.dart';
import 'package:net_client/src/services/cancellation/request_canceller.dart';
import 'package:test/test.dart';

void main() {
  late RequestCanceller sut;

  setUp(() {
    sut = RequestCanceller();
  });

  test('Starts with no cancellation state', () {
    expect(sut.isCancelled, isFalse);
    expect(sut.reason, isNull);
    expect(sut.requestSpec, isNull);
  });

  test(
    'Completes an existing whenCancel listener after cancel is called',
    () async {
      final pendingCancellation = sut.whenCancel;

      sut.cancel(reason: 'User aborted');

      await expectLater(pendingCancellation, completion('User aborted'));
    },
  );

  test('Completes whenCancel with the provided reason', () async {
    sut.cancel(reason: 'User aborted');

    final reason = await sut.whenCancel;

    expect(reason, 'User aborted');
  });

  test('Stores the cancellation reason after cancel', () {
    sut.cancel(reason: 'User aborted');

    expect(sut.isCancelled, isTrue);
    expect(sut.reason, 'User aborted');
  });

  test(
    'Returns the same reason from whenCancel after prior cancellation',
    () async {
      sut.cancel(reason: 'User aborted');

      await expectLater(sut.whenCancel, completion('User aborted'));
    },
  );

  test('Accepts a non-String cancellation reason', () async {
    final reason = Exception('User aborted');

    sut.cancel(reason: reason);

    await expectLater(sut.whenCancel, completion(same(reason)));
    expect(sut.reason, same(reason));
  });

  test('Does not replace the reason when cancelled twice', () {
    sut.cancel(reason: 'First reason');
    sut.cancel(reason: 'Second reason');

    expect(sut.isCancelled, isTrue);
    expect(sut.reason, 'First reason');
  });

  test('Binds requestSpec only once', () {
    final firstSpec = RequestSpec(
      pathOrUrl: '/users/42',
      method: HttpMethod.GET,
      body: const JsonBody({}),
    );
    final secondSpec = RequestSpec(
      pathOrUrl: '/users/99',
      method: HttpMethod.POST,
      body: const JsonBody({'payload': 'value'}),
    );

    sut.bindRequestSpec(firstSpec);
    sut.bindRequestSpec(secondSpec);

    expect(sut.requestSpec, same(firstSpec));
  });
}
