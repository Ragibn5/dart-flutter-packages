import 'package:analytics/analytics.dart';
import 'package:crashlytics/crashlytics.dart';
import 'package:sqlite_db/sqlite_db.dart';

/// Initializes the app.
class InitializeAppUseCase {
  final CrashlyticsService _crashlyticsService;
  final AnalyticsService _analyticsService;
  final SQLiteDb _appDatabase;

  InitializeAppUseCase(
    this._crashlyticsService,
    this._analyticsService,
    this._appDatabase,
  );

  Future<void> call() async {
    await _crashlyticsService.initialize();
    await _analyticsService.initialize();
    await _appDatabase.initialize();
  }
}
