import 'package:app_template/features/auth/data/clients/app_server_token_refresh_api_client.dart';
import 'package:app_template/features/auth/data/models/auth_data_dto.dart';
import 'package:app_template/features/auth/data/models/token_refresh_request.dart';
import 'package:meta/meta.dart';
import 'package:net_client/net_client.dart';
import 'package:net_models/net_models.dart';
import 'package:shared_models/shared_models.dart';

class AppServerTokenRefreshApiClientImpl
    extends AppServerTokenRefreshApiClient {
  @visibleForTesting
  static const path = 'refresh-token';

  AppServerTokenRefreshApiClientImpl(super.client);

  @override
  RequestSpec createRequest(TokenRefreshRequest body) {
    return RequestSpec(
      pathOrUrl: path,
      method: HttpMethod.GET,
      body: JsonBody(body.toJson()),
    );
  }

  @override
  ApiResponse<ServerMessage, AuthDataDTO> decodeResponse(
    NetClientResponse response,
  ) {
    if (response.isError) {
      return FailureResponse(
        error: ServerMessage.fromJson(response.data! as Map<String, dynamic>),
        statusCode: response.statusCode,
        headers: response.headers,
      );
    }

    return SuccessResponse(
      data: AuthDataDTO.fromJson(response.data! as Map<String, dynamic>),
      statusCode: response.statusCode,
      headers: response.headers,
    );
  }
}
