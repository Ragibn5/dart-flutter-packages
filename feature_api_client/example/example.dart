import 'package:feature_api_client/feature_api_client.dart';
import 'package:net_client/net_client.dart';
import 'package:net_models/net_models.dart';

class MyRequest {
  final String id;

  MyRequest(this.id);
}

class MyResponse {
  final String data;

  MyResponse(this.data);
}

class MyError {
  final String message;

  MyError(this.message);
}

class MyClient extends FeatureApiClient<MyRequest, MyResponse, MyError> {
  MyClient(super.client);

  @override
  RequestSpec createRequest(MyRequest body) => RequestSpec(
        pathOrUrl: 'https://api.example.com/${body.id}',
        method: HttpMethod.GET,
      );

  @override
  ApiResponse<MyError, MyResponse> decodeResponse(
    NetClientResponse response,
  ) =>
      SuccessResponse(
        data: MyResponse(response.data.toString()),
        statusCode: response.statusCode,
        headers: response.headers,
      );
}

void main() {
  print('FeatureApiClient ready');
}
