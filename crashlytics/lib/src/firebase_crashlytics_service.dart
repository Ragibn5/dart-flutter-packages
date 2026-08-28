import 'package:crashlytics/src/crashlytics_service.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class FirebaseCrashlyticsService extends CrashlyticsService {
  final FirebaseCrashlytics _crashlytics;

  FirebaseCrashlyticsService(this._crashlytics);

  @override
  Future<void> initialize() async {
    await super.initialize();

    FlutterError.onError = _crashlytics.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      _crashlytics.recordError(error, stack, fatal: true);
      return true;
    };
  }

  @override
  Future<void> setSessionData(
    String userId, {
    required bool collectionEnabled,
  }) async {
    await _crashlytics.setUserIdentifier(userId);
    await _crashlytics.setCrashlyticsCollectionEnabled(collectionEnabled);
  }

  @override
  Future<void> recordError(
    dynamic exception,
    StackTrace? stackTrace, {
    dynamic reason,
    bool? printDetails,
    bool fatal = false,
  }) {
    return _crashlytics.recordError(
      exception,
      stackTrace,
      reason: reason,
      printDetails: printDetails,
      fatal: fatal,
    );
  }
}
