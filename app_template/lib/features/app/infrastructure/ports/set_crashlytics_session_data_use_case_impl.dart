import 'package:app_template/features/app/application/use_cases/set_crashlytics_session_data_use_case.dart';
import 'package:crashlykit/crashlykit.dart';

class SetCrashlyticsSessionDataUseCaseImpl
    implements SetCrashlyticsSessionDataUseCase {
  final CrashlyticsService _crashlyticsService;

  SetCrashlyticsSessionDataUseCaseImpl(this._crashlyticsService);

  @override
  Future<void> call(String userId, {required bool collectionEnabled}) {
    return _crashlyticsService.setSessionData(
      userId,
      collectionEnabled: collectionEnabled,
    );
  }
}
