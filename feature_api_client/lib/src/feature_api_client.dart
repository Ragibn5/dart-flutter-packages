import 'package:dart_functionals/dart_functionals.dart';
import 'package:feature_api_client/src/services/net_client_exception_transformer.dart';
import 'package:feature_api_client/src/services/net_client_request_builder.dart';
import 'package:feature_api_client/src/services/net_client_response_decoder.dart';
import 'package:meta/meta.dart';
import 'package:net_client/net_client.dart';
import 'package:net_models/net_models.dart';

abstract class FeatureApiClient<Req, Res, Err>
    implements NetClientRequestBuilder<Req>, NetClientResponseDecoder<Err, Res> {
  final NetClient _client;
  final NetClientExceptionTransformer _netKitExceptionTransformer;

  FeatureApiClient(NetClient client)
      : this._(client, const NetClientExceptionTransformer());

  @visibleForTesting
  FeatureApiClient.test(
    NetClient client,
    NetClientExceptionTransformer netKitExceptionTransformer,
  ) : this._(client, netKitExceptionTransformer);

  FeatureApiClient._(this._client, this._netKitExceptionTransformer);

  Future<Either<ApiError, ApiResponse<Err, Res>>> request(Req body) async {
    final requestSpec = createRequest(body);
    final rawResponse = await _client.execute(spec: requestSpec);
    return rawResponse.fold(
      onSuccess: (r) => Right(decodeResponse(r)),
      onFailure: (e) => Left(_netKitExceptionTransformer.transformApiError(e)),
    );
  }
}
