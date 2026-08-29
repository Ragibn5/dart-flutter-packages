import 'package:base_auth_interceptor/base_auth_interceptor.dart';
import 'package:dart_functionals/dart_functionals.dart';
import 'package:net_client/net_client.dart';

class _AuthDataProvider implements AuthDataProvider<String> {
  @override
  Future<String?> getAuthData() async => 'my-token';

  @override
  Future<String?> requestAuthDataRefresh(String oldAuthData) async => null;
}

class _RequestRetrier implements RequestRetrier<String> {
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

class _AuthRefreshPolicy implements AuthRefreshPolicy<String> {
  @override
  bool didServerReportAuthError(RawResponse response) =>
      response.statusCode == 401;

  @override
  bool shouldRefreshAuthData(RequestSpec request, String authData) => false;
}

class _AuthRequestTransformer implements AuthRequestTransformer<String> {
  @override
  Future<RequestSpec> transformRequestWithAuthData(
    RequestSpec request,
    String authData,
  ) async {
    request.headers.addAll({'Authorization': 'Bearer $authData'});
    return request;
  }
}

class AppAuthInterceptor extends BaseAuthInterceptor<String> {
  AppAuthInterceptor()
      : super(
          _AuthDataProvider(),
          _AuthRefreshPolicy(),
          _AuthRequestTransformer(),
          _RequestRetrier(),
        );
}
