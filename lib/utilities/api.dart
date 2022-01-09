import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const String apiUrl = 'http://192.168.1.8:5000';
FlutterSecureStorage storage = const FlutterSecureStorage();
String accessToken = '';
String refreshToken = '';

Future<Map<String, dynamic>> postAuthenticated(
  String url,
  Map<String, dynamic> body, {
  int retry = 2,
  bool isPut = false,
}) async {
  Map<String, String> headers = {
    'Accept': 'application/json',
    'Content-type': 'application/json',
    'Authorization': 'Bearer $accessToken'
  };
  http.Response result;
  if (isPut) {
    result = await http.put(
      Uri.parse(url),
      body: jsonEncode(body),
      headers: headers,
    );
  } else {
    result = await http.post(
      Uri.parse(url),
      body: jsonEncode(body),
      headers: headers,
    );
  }

  Map<String, dynamic> decodedResult = jsonDecode(result.body);
  if (decodedResult['code'] == 401 && retry > 0) {
    Map<String, dynamic> silentLoginRes = await silentLogin();
    if (silentLoginRes['code'] == 200) {
      return postAuthenticated(url, body, retry: retry - 1);
    }
  }
  return decodedResult;
}

Future<Map<String, dynamic>> getAuthenticated(
  String url, {
  int retry = 2,
}) async {
  http.Response result = await http.get(Uri.parse(url), headers: {
    'Accept': 'application/json',
    'Authorization': 'Bearer $accessToken'
  });

  Map<String, dynamic> decodedResult = jsonDecode(result.body);
  if (decodedResult['code'] == 401 && retry > 0) {
    Map<String, dynamic> silentLoginRes = await silentLogin();
    if (silentLoginRes['code'] == 200) {
      return getAuthenticated(url, retry: retry - 1);
    }
  }
  return decodedResult;
}

Future<void> initializeApi() async {
  List result = await Future.wait([
    storage.read(key: 'accessToken'),
    storage.read(key: 'refreshToken'),
  ]);
  accessToken = result[0];
  refreshToken = result[1];
}

Future<Map<String, dynamic>> login(String username, String password) async {
  http.Response result = await http.post(Uri.parse('$apiUrl/auth/login'),
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
      headers: {
        'Content-type': 'application/json',
        'Accept': 'application/json',
      });

  if (result.statusCode == 200) {
    String rawBody = result.body;
    Map<String, dynamic> decodedData = jsonDecode(rawBody);
    await Future.wait([
      storage.write(
        key: 'accessToken',
        value: decodedData['access_token'],
      ),
      storage.write(
        key: 'refreshToken',
        value: decodedData['refresh_token'],
      ),
    ]);
    accessToken = decodedData['access_token'];
    refreshToken = decodedData['refresh_token'];
  }

  return jsonDecode(result.body);
}

Future<Map<String, dynamic>> register(String username, String password) async {
  http.Response result = await http.post(Uri.parse('$apiUrl/auth/register'),
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
      headers: {
        'Content-type': 'application/json',
        'Accept': 'application/json',
      });

  return jsonDecode(result.body);
}

Future<Map<String, dynamic>> silentLogin() async {
  http.Response result = await http.post(Uri.parse('$apiUrl/auth/refresh'),
      body: jsonEncode({
        'refresh_token': refreshToken,
      }),
      headers: {
        'Content-type': 'application/json',
        'Accept': 'application/json',
      });

  return jsonDecode(result.body);
}

Future<Map<String, dynamic>> authCheck() {
  return getAuthenticated('$apiUrl/auth/check');
}

Future<Map<String, dynamic>> getUserData() {
  return getAuthenticated('$apiUrl/user');
}

Future<Map<String, dynamic>> updateUser(Map<String, dynamic> body) {
  return postAuthenticated('$apiUrl/user', body, isPut: true);
}

Future<Map<String, dynamic>> generateBotToken() {
  return postAuthenticated('$apiUrl/bot/token', {});
}
