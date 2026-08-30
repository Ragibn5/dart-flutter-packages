import 'package:net_client/net_client.dart';

/// Decides when the interceptor should attempt auth recovery.
abstract interface class AuthRefreshPolicy<AuthData> {
  /// Returns `true` when the server response indicates that an
  /// auth error occurred and it should be refreshed.
  bool didServerReportAuthError(RawResponse response);

  /// Returns `true` when given [authData] is stale and a refresh
  /// should be attempted.
  ///
  /// This is used for situations like when another request in the
  /// queue already refreshed the auth data, and we no longer need
  /// to perform the auth data refresh.
  bool shouldRefreshAuthData(RequestSpec request, AuthData authData);
}
