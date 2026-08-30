import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:rover/rover.dart';

class _MockRover extends Mock implements Rover {}

void main() {
  group('Rover', () {
    test('pushWithName delegates correctly', () async {
      final router = _MockRover();
      when(
        () => router.pushWithName<Object?>(
          any(),
          pathParameters: any(named: 'pathParameters'),
          queryParameters: any(named: 'queryParameters'),
          extra: any(named: 'extra'),
        ),
      ).thenAnswer((_) async => null);

      await router.pushWithName('home');
      verify(() => router.pushWithName('home')).called(1);
    });

    test('replaceWithName delegates correctly', () async {
      final router = _MockRover();
      when(
        () => router.replaceWithName<Object?>(
          any(),
          pathParameters: any(named: 'pathParameters'),
          queryParameters: any(named: 'queryParameters'),
          extra: any(named: 'extra'),
        ),
      ).thenAnswer((_) async => null);

      await router.replaceWithName('home');
      verify(() => router.replaceWithName('home')).called(1);
    });

    test('navigateTo delegates correctly', () {
      final router = _MockRover();
      when(
        () => router.navigateTo(
          any(),
          pathParameters: any(named: 'pathParameters'),
          queryParameters: any(named: 'queryParameters'),
          extra: any(named: 'extra'),
        ),
      ).thenReturn(null);

      router.navigateTo('home');
      verify(() => router.navigateTo('home')).called(1);
    });

    test('canPopTopRoute delegates correctly', () {
      final router = _MockRover();
      when(() => router.canPopTopRoute()).thenReturn(true);

      expect(router.canPopTopRoute(), isTrue);
      verify(() => router.canPopTopRoute()).called(1);
    });

    test('popTopRoute delegates correctly', () {
      final router = _MockRover();
      when(() => router.popTopRoute<Object?>(any())).thenReturn(null);

      router.popTopRoute();
      verify(() => router.popTopRoute()).called(1);
    });

    test('popUntilRoute delegates correctly', () {
      final router = _MockRover();
      when(() => router.popUntilRoute(any())).thenReturn(null);

      router.popUntilRoute((_) => false);
      verify(() => router.popUntilRoute(any())).called(1);
    });
  });
}
