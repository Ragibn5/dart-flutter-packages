abstract interface class ResponseStatusValidator {
  bool validateStatus(int? statusCode);
}

class DefaultResponseStatusValidator implements ResponseStatusValidator {
  const DefaultResponseStatusValidator();

  @override
  bool validateStatus(int? statusCode) => true;
}
