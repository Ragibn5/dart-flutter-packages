import 'package:flutter_test/flutter_test.dart';
import 'package:rover/rover.dart';

void main() {
  group('RouteInfo', () {
    test('stores name and path', () {
      const info = RouteInfo('home', '/home');
      expect(info.name, 'home');
      expect(info.path, '/home');
    });
  });
}
