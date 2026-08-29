import 'package:meta/meta.dart';

abstract class AnalyticsService {
  const AnalyticsService();

  /// Initializes the analytics service.
  ///
  /// Must be called before any other methods.
  @mustCallSuper
  Future<void> initialize() async {}

  /// Associates analytics data with the given [userId]
  /// and optionally  enables or disables analytics collection.
  Future<void> setSessionData(String userId, {required bool collectionEnabled});

  /// Logs an analytics event with the given [name] and optional parameters.
  Future<void> logEvent(String name, [Map<String, Object>? params]);
}
