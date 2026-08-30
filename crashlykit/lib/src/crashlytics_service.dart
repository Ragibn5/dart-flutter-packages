import 'dart:async';

import 'package:meta/meta.dart';

abstract class CrashlyticsService {
  const CrashlyticsService();

  /// Initializes the analytics service.
  ///
  /// Must be called before any other methods.
  @mustCallSuper
  Future<void> initialize() async {}

  /// Associates crash reports with the given [userId]
  /// and optionally enables or disables crash reporting collection.
  Future<void> setSessionData(String userId, {required bool collectionEnabled});

  /// Records an error with the given [exception] and [stackTrace].
  ///
  /// Optionally accepts a [reason], [printDetails] flag, and whether
  /// the error was [fatal].
  Future<void> recordError(
    dynamic exception,
    StackTrace? stackTrace, {
    dynamic reason,
    bool? printDetails,
    bool fatal = false,
  });
}
