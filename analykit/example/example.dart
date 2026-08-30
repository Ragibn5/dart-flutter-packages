// ignore_for_file: cascade_invocations

import 'package:analykit/analykit.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

void main() {
  // Create an impl from FirebaseAnalytics
  final AnalyticsService analytics = FirebaseAnalyticsService(
    FirebaseAnalytics.instance,
  );

  analytics.setSessionData('user-123', collectionEnabled: true);
  analytics.logEvent('login', {'method': 'email'});
}
