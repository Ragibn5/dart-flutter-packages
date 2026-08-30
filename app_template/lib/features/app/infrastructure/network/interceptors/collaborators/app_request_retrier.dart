import 'package:app_template/features/app/domain/models/auth_info.dart';
import 'package:base_auth_interceptor/base_auth_interceptor.dart';
import 'package:net_client/net_client.dart';

/// Replays a request against the target client, possibly with refreshed auth
/// data.
class AppRequestRetrier implements RequestRetrier<AuthInfo> {
  final NetClient _targetClient;

  AppRequestRetrier(this._targetClient);

  @override
  Future<ApiCallResult> retryRequest(
    RequestSpec request,
    AuthInfo refreshedAuthData,
  ) => _targetClient.execute(spec: request);
}
