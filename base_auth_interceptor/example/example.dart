import 'package:base_auth_interceptor/base_auth_interceptor.dart';
import 'package:dart_functionals/dart_functionals.dart';
import 'package:net_client/net_client.dart';

class AppAuthInterceptor extends BaseAuthInterceptor<String> {
  @override
  Future<String?> getAuthData() async => 'my-token';

  @override
  Future<RequestSpec> transformRequestWithAuthData(
    RequestSpec request,
    String authData,
  ) async {
    request.headers.addAll({'Authorization': 'Bearer $authData'});
    return request;
  }

  @override
  bool didServerReportAuthError(RawResponse response) =>
      response.statusCode == 401;

  @override
  bool shouldRefreshAuthData(RequestSpec request, String authData) => false;

  @override
  Future<String?> requestAuthDataRefresh(String oldAuthData) async => null;

  @override
  Future<ApiCallResult> retryRequest(
    RequestSpec request,
    String refreshedAuthData,
  ) async =>
      Success(
        NetClientResponse(
          isError: false,
          statusCode: 200,
          data: '',
          headers: {},
          requestSpec: request,
        ),
      );
}
