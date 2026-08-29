import 'package:analykit/analykit.dart';
import 'package:app_template/features/app/application/use_cases/initialize_app_use_case.dart';
import 'package:crashlykit/crashlykit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqlite_db/sqlite_db.dart';

class _MockCrashlyticsService extends Mock implements CrashlyticsService {}

class _MockAnalyticsService extends Mock implements AnalyticsService {}

class _MockSQLiteDb extends Mock implements SQLiteDb {}

void main() {
  late _MockCrashlyticsService mockCrashlytics;
  late _MockAnalyticsService mockAnalytics;
  late _MockSQLiteDb mockDatabase;

  late InitializeAppUseCase sut;

  setUp(() {
    mockCrashlytics = _MockCrashlyticsService();
    mockAnalytics = _MockAnalyticsService();
    mockDatabase = _MockSQLiteDb();

    when(() => mockCrashlytics.initialize()).thenAnswer((_) async {});
    when(() => mockAnalytics.initialize()).thenAnswer((_) async {});
    when(() => mockDatabase.initialize()).thenAnswer((_) async {});

    sut = InitializeAppUseCase(mockCrashlytics, mockAnalytics, mockDatabase);
  });

  test('Should initialize all services in order', () async {
    await sut();

    verifyInOrder([
      () => mockCrashlytics.initialize(),
      () => mockAnalytics.initialize(),
      () => mockDatabase.initialize(),
    ]);
  });
}
