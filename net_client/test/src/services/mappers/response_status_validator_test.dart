import 'package:net_client/src/services/mappers/response_status_validator.dart';
import 'package:test/test.dart';

void main() {
  late DefaultResponseStatusValidator sut;

  setUp(() {
    sut = const DefaultResponseStatusValidator();
  });

  test('Returns true for any status code including null', () {
    expect(sut.validateStatus(null), true);
    expect(sut.validateStatus(200), true);
    expect(sut.validateStatus(300), true);
    expect(sut.validateStatus(400), true);
    expect(sut.validateStatus(500), true);
  });
}
