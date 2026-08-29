// ignore_for_file: cascade_invocations

import 'package:crashlykit/crashlykit.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

void main() {
  final crashlytics = FirebaseCrashlyticsService(FirebaseCrashlytics.instance);

  crashlytics.setSessionData('user-123', collectionEnabled: true);

  try {
    throw Exception('Something went wrong');
  } catch (e, s) {
    crashlytics.recordError(e, s, fatal: true);
  }
}
