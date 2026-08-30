abstract interface class AuthDataProvider<AuthData> {
  /// Returns the current auth data, or `null` if none is available.
  Future<AuthData?> getAuthData();

  /// Attempts to refresh the auth data.
  ///
  /// Returns the new auth data on success, or `null` on failure.
  ///
  /// > Note: The request is cancelled immediately if this returns null.
  Future<AuthData?> requestAuthDataRefresh(AuthData oldAuthData);
}
