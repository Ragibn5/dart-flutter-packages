abstract interface class PreferenceReader {
  /// Returns true if the persistent storage contains the given key.
  Future<bool> containsKey(String key);

  /// Returns all keys in the persistent storage.
  ///
  /// If [allowList] is provided, only keys present in the allowList
  /// are returned, otherwise all stored keys are returned.
  Future<Set<String>> getKeys({Set<String>? allowList});

  /// Returns all key-value pairs in the persistent storage.
  ///
  /// If [allowList] is provided, only keys present in the allowList
  /// are returned.
  Future<Map<String, Object?>> getAll({Set<String>? allowList});

  /// Reads a boolean value from persistent storage.
  ///
  /// Returns null if the key doesn't exist or the value is not a boolean.
  Future<bool?> getBool(String key);

  /// Reads an integer value from persistent storage.
  ///
  /// Returns null if the key doesn't exist or the value is not an integer.
  Future<int?> getInt(String key);

  /// Reads a double value from persistent storage.
  ///
  /// Returns null if the key doesn't exist or the value is not a double.
  Future<double?> getDouble(String key);

  /// Reads a string value from persistent storage.
  ///
  /// Returns null if the key doesn't exist or the value is not a string.
  Future<String?> getString(String key);

  /// Reads a list of strings from persistent storage.
  ///
  /// Returns null if the key doesn't exist or the value
  /// is not a list of strings.
  Future<List<String>?> getStringList(String key);

  /// Reads a set of strings from persistent storage.
  ///
  /// Returns null if the key doesn't exist or the value
  /// is not a set of strings.
  Future<Set<String>?> getStringSet(String key);
}
