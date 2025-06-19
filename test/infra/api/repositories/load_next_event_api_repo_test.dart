import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/fakes.dart';

class LoadNextEventApiRepository {
  final HttpGetClientSpy httpClient;
  final String url;

  LoadNextEventApiRepository({required this.httpClient, required this.url});

  Future<void> loadNextEvent({required String groupId}) async {
    await httpClient.get(url: url, params: {"groupId": groupId});
  }
}

abstract class HttpGetClient {
  Future<void> get({required String url, Map<String, String>? params});
}

class HttpGetClientSpy implements HttpGetClient {
  String? url;
  int callsCount = 0;
  Map<String, String>? params;

  @override
  Future<void> get({required String url, Map<String, String>? params}) async {
    this.url = url;
    this.params = params;
    callsCount++;
    // Simulate a successful response
  }
}

void main() {
  late String groupId;
  late String url;
  late HttpGetClientSpy httpClient;
  late LoadNextEventApiRepository sut;

  setUp(() {
    groupId = anyString();
    url = anyString();
    httpClient = HttpGetClientSpy();
    sut = LoadNextEventApiRepository(httpClient: httpClient, url: url);
  });
  test('should call http client with correct input', () async {
    await sut.loadNextEvent(groupId: groupId);
    expect(httpClient.url, url);
    expect(httpClient.callsCount, 1);
  });
  test('should call http client with correct params', () async {
    await sut.loadNextEvent(groupId: groupId);
    expect(httpClient.params, {"groupId": groupId});
  });
}
