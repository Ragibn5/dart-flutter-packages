import 'package:analykit/src/analytics_service.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class FirebaseAnalyticsService extends AnalyticsService {
  final FirebaseAnalytics _firebaseAnalytics;

  FirebaseAnalyticsService(this._firebaseAnalytics);

  @override
  Future<void> setSessionData(
    String userId, {
    required bool collectionEnabled,
  }) async {
    await _firebaseAnalytics.setUserId(id: userId);
    await _firebaseAnalytics.setAnalyticsCollectionEnabled(collectionEnabled);
  }

  @override
  Future<void> logEvent(String name, [Map<String, Object>? params]) {
    return _firebaseAnalytics.logEvent(name: name, parameters: params);
  }
}
