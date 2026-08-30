abstract interface class PreferenceWriter {
  /// Removes an entry from persistent storage.
  Future<void> remove(String key);

  /// Removes multiple entries from persistent storage.
  ///
  /// - If [allowList] is null, all entries are removed.
  /// - If [allowList] is provided, only keys present in the allowList
  ///   are removed.
  Future<void> removeAll({Set<String>? allowList});

  /// Stores a boolean value in persistent storage.
  // ignore: avoid_positional_boolean_parameters
  Future<void> setBool(String key, bool value);

  /// Stores an integer value in persistent storage.
  Future<void> setInt(String key, int value);

  /// Stores a double value in persistent storage.
  Future<void> setDouble(String key, double value);

  /// Stores a string value in persistent storage.
  Future<void> setString(String key, String value);

  /// Stores a list of strings in persistent storage.
  Future<void> setStringList(String key, List<String> value);
}
