import 'package:dartx/dartx.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';

import 'client_spy.dart';

class HttpClient {
  final Client client;

  HttpClient({required this.client});

  Future<void> get({
    required String url,
    Map<String, String>? headers,
    Map<String, String?>? params,
    Map<String, String>? queryString,
  }) async {
    final allHeaders = (headers ?? {})
      ..addAll({
        'content-type': 'application/json',
        'accept': 'application/json',
      });
    final uri = _buildUri(url: url, params: params, queryString: queryString);
    await client.get(uri, headers: allHeaders);
  }

  Uri _buildUri({
    required String url,
    Map<String, String?>? params,
    Map<String, String>? queryString,
  }) {
    url =
        params?.keys
            .fold(
              url,
              (result, key) => result.replaceFirst(':$key', params[key] ?? ''),
            )
            .removeSuffix('/') ??
        url;
    url =
        queryString?.keys
            .fold('$url?', (result, key) => '$result$key=${queryString[key]}&')
            .removeSuffix('&') ??
        url;
    return Uri.parse(url);
  }
}

void main() {
  late ClientSpy client;
  late HttpClient sut;
  late String url;

  setUp(() {
    client = ClientSpy();
    sut = HttpClient(client: client);
    url = 'any_url';
  });

  group('get', () {
    test('should request with correct method', () async {
      await sut.get(url: url);
      expect(client.method, 'get');
      expect(client.callsCount, 1);
    });
    test('should request with correct url', () async {
      await sut.get(url: url);
      expect(client.url, url);
    });
    test('should request with default headers', () async {
      await sut.get(url: url);
      expect(client.headers?['content-type'], 'application/json');
      expect(client.headers?['accept'], 'application/json');
    });
    test('should append headers', () async {
      await sut.get(url: url, headers: {'h1': 'value1', 'h2': 'value2'});
      expect(client.headers?['content-type'], 'application/json');
      expect(client.headers?['accept'], 'application/json');
      expect(client.headers?['h1'], 'value1');
      expect(client.headers?['h2'], 'value2');
    });
    test('should request with correct params', () async {
      url = 'https://anyurl.com/api/:p1/:p2';
      await sut.get(url: url, params: {'p1': 'v1', 'p2': 'v2'});
      expect(client.url, 'https://anyurl.com/api/v1/v2');
    });
    test('should request with optional params', () async {
      url = 'https://anyurl.com/api/:p1/:p2';
      await sut.get(url: url, params: {'p1': 'v1', 'p2': null});
      expect(client.url, 'https://anyurl.com/api/v1');
    });
    test('should request with invalid params', () async {
      url = 'https://anyurl.com/api/:p1/:p2';
      await sut.get(url: url, params: {'p3': 'v3'});
      expect(client.url, 'https://anyurl.com/api/:p1/:p2');
    });
    test('should request with correct queryStrings', () async {
      await sut.get(url: url, queryString: {'q1': 'v1', 'q2': 'v2'});
      expect(client.url, '$url?q1=v1&q2=v2');
    });
    test('should request with correct queryStrings and params', () async {
      url = 'https://anyurl.com/api/:p3/:p4';
      await sut.get(
        url: url,
        params: {'p3': 'v3', 'p4': 'v4'},
        queryString: {'q1': 'v1', 'q2': 'v2'},
      );
      expect(client.url, 'https://anyurl.com/api/v3/v4?q1=v1&q2=v2');
    });
  });
}
