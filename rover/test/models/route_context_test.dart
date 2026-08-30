import 'package:flutter_test/flutter_test.dart';
import 'package:rover/rover.dart';

void main() {
  group('RouteContext', () {
    test('stores info and defaults', () {
      const info = RouteInfo('home', '/home');
      const context = RouteContext(info: info);
      expect(context.info, info);
      expect(context.pathParameters, isEmpty);
      expect(context.queryParameters, isEmpty);
      expect(context.extra, isNull);
    });

    test('stores all fields', () {
      const info = RouteInfo('home', '/home');
      const context = RouteContext(
        info: info,
        pathParameters: {'id': '42'},
        queryParameters: {'q': 'test'},
        extra: 'extra',
      );
      expect(context.pathParameters, {'id': '42'});
      expect(context.queryParameters, {'q': 'test'});
      expect(context.extra, 'extra');
    });
  });
}
