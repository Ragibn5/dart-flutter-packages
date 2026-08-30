import 'package:app_template/features/auth/data/clients/app_server_token_refresh_api_client.dart';
import 'package:app_template/features/auth/data/models/auth_data_dto.dart';
import 'package:app_template/features/auth/data/models/token_refresh_request.dart';
import 'package:app_template/features/auth/data/sources/remote_auth_data_source.dart';
import 'package:dart_functionals/dart_functionals.dart';
import 'package:net_models/net_models.dart';
import 'package:shared_models/shared_models.dart';

class RemoteAuthDataSourceImpl implements RemoteAuthDataSource {
  final AppServerTokenRefreshApiClient _client;

  RemoteAuthDataSourceImpl(this._client);

  @override
  Future<Either<ApiError, Either<ServerMessage, AuthDataDTO>>>
  getRefreshedAuthData(TokenRefreshRequest tokenRefreshRequest) async {
    final r = await _client.request(tokenRefreshRequest);
    return r.fold(
      onLeft: Left.new,
      onRight: (r) => Right(
          r.fold(onFailure: Left.new, onSuccess: Right.new)
      ),
    );
  }
}
