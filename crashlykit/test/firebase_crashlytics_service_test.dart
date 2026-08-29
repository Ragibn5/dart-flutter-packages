// ignore_for_file: lines_longer_than_80_chars
// ignore_for_file: avoid_redundant_argument_values

import 'package:crashlykit/src/firebase_crashlytics_service.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockFirebaseCrashlytics extends Mock implements FirebaseCrashlytics {}

void main() {
  const userId = 'userId123';
  const connectionEnabled = true;
  const reason = 'Testing reason';
  const printDetails = true;
  const fatal = false;

  final exp = Exception('flutter error');
  final st = StackTrace.current;
  final flutterError = FlutterErrorDetails(exception: exp, stack: st);

  late _MockFirebaseCrashlytics mockFirebaseCrashlytics;

  late FirebaseCrashlyticsService sut;

  setUpAll(() {
    registerFallbackValue(flutterError);
  });

  setUp(() {
    mockFirebaseCrashlytics = _MockFirebaseCrashlytics();

    sut = FirebaseCrashlyticsService(mockFirebaseCrashlytics);

    when(
      () => mockFirebaseCrashlytics.recordFlutterFatalError(any()),
    ).thenAnswer((_) async {});
    when(
      () => mockFirebaseCrashlytics.recordError(
        any<dynamic>(),
        any(),
        fatal: any(named: 'fatal'),
      ),
    ).thenAnswer((_) async => {});
    when(
      () => mockFirebaseCrashlytics.setUserIdentifier(any()),
    ).thenAnswer((_) async {});
    when(
      () => mockFirebaseCrashlytics.setCrashlyticsCollectionEnabled(any()),
    ).thenAnswer((_) async {});
    when(() => mockFirebaseCrashlytics.log(any())).thenAnswer((_) async {});
    when(
      () => mockFirebaseCrashlytics.recordError(
        anything,
        any(),
        reason: any<dynamic>(named: 'reason'),
        printDetails: any(named: 'printDetails'),
        fatal: any(named: 'fatal'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => mockFirebaseCrashlytics.recordFlutterError(
        any(),
        fatal: any(named: 'fatal'),
      ),
    ).thenAnswer((_) async {});
  });

  test('`initialize` should set delegates to record errors', () async {
    await sut.initialize();

    FlutterError.onError!(flutterError);
    PlatformDispatcher.instance.onError!(exp, st);

    verify(
      () => mockFirebaseCrashlytics.recordFlutterFatalError(flutterError),
    ).called(1);
    verify(
      () => mockFirebaseCrashlytics.recordError(exp, st, fatal: true),
    ).called(1);
  });

  test(
    '`setSessionData` should set user Id and analytics collection enabled status',
    () async {
      await sut.setSessionData(userId, collectionEnabled: connectionEnabled);

      verify(() => mockFirebaseCrashlytics.setUserIdentifier(userId)).called(1);
      verify(
        () => mockFirebaseCrashlytics.setCrashlyticsCollectionEnabled(
          connectionEnabled,
        ),
      ).called(1);
    },
  );

  test(
    '`recordError` should call FirebaseCrashlytics.recordError with appropriate data',
    () async {
      await sut.recordError(
        exp,
        st,
        reason: reason,
        printDetails: printDetails,
        fatal: fatal,
      );

      verify(
        () => mockFirebaseCrashlytics.recordError(
          exp,
          st,
          reason: reason,
          printDetails: printDetails,
          fatal: fatal,
        ),
      ).called(1);
    },
  );
}
