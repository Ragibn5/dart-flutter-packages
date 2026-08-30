import 'package:net_client/net_client.dart';
import 'package:test/test.dart';

void main() {
  group('uri', () {
    test('Returns pathOrUrl as-is when no baseUrl is given', () {
      final spec = RequestSpec(pathOrUrl: '/users', method: HttpMethod.GET);
      expect(spec.uri.toString(), '/users');
    });

    test('Appends query parameters when no baseUrl is given', () {
      final spec = RequestSpec(
        pathOrUrl: '/users',
        method: HttpMethod.GET,
        queryParameters: {'role': 'admin'},
      );
      expect(spec.uri.toString(), '/users?role=admin');
    });

    test('Joins baseUrl with relative path', () {
      final spec = RequestSpec(
        pathOrUrl: '/users',
        method: HttpMethod.GET,
        baseUrl: 'https://api.example.com',
      );
      expect(spec.uri.toString(), 'https://api.example.com/users');
    });

    test('Handles baseUrl with trailing slash', () {
      final spec = RequestSpec(
        pathOrUrl: 'users',
        method: HttpMethod.GET,
        baseUrl: 'https://api.example.com/',
      );
      expect(spec.uri.toString(), 'https://api.example.com/users');
    });

    test(
      'Handles path with leading slash and baseUrl without trailing slash',
      () {
        final spec = RequestSpec(
          pathOrUrl: '/users',
          method: HttpMethod.GET,
          baseUrl: 'https://api.example.com',
        );
        expect(spec.uri.toString(), 'https://api.example.com/users');
      },
    );

    test('Includes query parameters in the constructed URL', () {
      final spec = RequestSpec(
        pathOrUrl: '/users',
        method: HttpMethod.GET,
        baseUrl: 'https://api.example.com',
        queryParameters: {'role': 'admin', 'active': 'true'},
      );
      expect(
        spec.uri.toString(),
        'https://api.example.com/users?role=admin&active=true',
      );
    });

    test('Uses pathOrUrl as-is when it already has a scheme', () {
      final spec = RequestSpec(
        pathOrUrl: 'https://other.com/users',
        method: HttpMethod.GET,
        baseUrl: 'https://api.example.com',
      );
      expect(spec.uri.toString(), 'https://other.com/users');
    });

    test('Appends query params to a full URL', () {
      final spec = RequestSpec(
        pathOrUrl: 'https://other.com/users',
        method: HttpMethod.GET,
        baseUrl: 'https://api.example.com',
        queryParameters: {'page': '1'},
      );
      expect(
        spec.uri.toString(),
        'https://other.com/users?page=1',
      );
    });

    test('Coerces non-string query param values to strings', () {
      final spec = RequestSpec(
        pathOrUrl: '/search',
        method: HttpMethod.GET,
        baseUrl: 'https://api.example.com',
        queryParameters: {'count': 5, 'enabled': true},
      );
      expect(
        spec.uri.toString(),
        'https://api.example.com/search?count=5&enabled=true',
      );
    });

    test('Ignores empty query parameters map', () {
      final spec = RequestSpec(
        pathOrUrl: '/users',
        method: HttpMethod.GET,
        baseUrl: 'https://api.example.com',
        queryParameters: {},
      );
      expect(spec.uri.toString(), 'https://api.example.com/users');
    });

    test('Ignores null query parameters', () {
      final spec = RequestSpec(
        pathOrUrl: '/users',
        method: HttpMethod.GET,
        baseUrl: 'https://api.example.com',
      );
      expect(spec.uri.toString(), 'https://api.example.com/users');
    });

    test('Normalizes dot segments in the path', () {
      final spec = RequestSpec(
        pathOrUrl: '/users/../users',
        method: HttpMethod.GET,
        baseUrl: 'https://api.example.com',
      );
      expect(spec.uri.toString(), 'https://api.example.com/users');
    });
  });

  group('defensive copy', () {
    test('`queryParameters` is a separate instance from input', () {
      final input = {'page': '1'};
      final spec = RequestSpec(
        pathOrUrl: '/',
        method: HttpMethod.GET,
        queryParameters: input,
      );
      expect(identical(spec.queryParameters, input), isFalse);
    });

    test('Mutating input does not affect queryParameters', () {
      final input = {'page': '1'};
      final spec = RequestSpec(
        pathOrUrl: '/',
        method: HttpMethod.GET,
        queryParameters: input,
      );
      input['page'] = '2';
      expect(spec.queryParameters['page'], '1');
    });

    test('`headers` is a separate instance from input', () {
      final input = {'Authorization': 'token'};
      final spec = RequestSpec(
        pathOrUrl: '/',
        method: HttpMethod.GET,
        headers: input,
      );
      expect(identical(spec.headers, input), isFalse);
    });

    test('Mutating input does not affect headers', () {
      final input = {'Authorization': 'token'};
      final spec = RequestSpec(
        pathOrUrl: '/',
        method: HttpMethod.GET,
        headers: input,
      );
      input['Authorization'] = 'hacked';
      expect(spec.headers['Authorization'], 'token');
    });

    test('Accepts const input without issue', () {
      final spec = RequestSpec(
        pathOrUrl: '/',
        method: HttpMethod.GET,
        queryParameters: const {'key': 'value'},
        headers: const {'Authorization': 'token'},
      );
      expect(spec.queryParameters, {'key': 'value'});
      expect(spec.headers, {'Authorization': 'token'});
    });
  });
}
