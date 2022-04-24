import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

String apiUrl = dotenv.env['API_URL'] as String;
FlutterSecureStorage storage = const FlutterSecureStorage();
String accessToken = 'None';
String refreshToken = 'None';
const errorNetworkResponse = {
  'code': 502,
  'detail':
      'There is a network connection problem. Check your internet and try again later!',
  'message': 'Network Connection Problem'
};

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

  try {
    Map<String, dynamic> decodedResult = jsonDecode(result.body);
    if (decodedResult['code'] == 401 && retry > 0) {
      Map<String, dynamic> silentLoginRes = await silentLogin();
      if (silentLoginRes['code'] == 200) {
        return postAuthenticated(url, body, retry: retry - 1);
      }
    }
    return decodedResult;
  } catch (e) {
    return errorNetworkResponse;
  }
}

Future<Map<String, dynamic>> getAuthenticated(
  String url, {
  int retry = 2,
}) async {
  http.Response result = await http.get(Uri.parse(url), headers: {
    'Accept': 'application/json',
    'Authorization': 'Bearer $accessToken'
  });

  try {
    Map<String, dynamic> decodedResult = jsonDecode(result.body);
    if (decodedResult['code'] == 401 && retry > 0) {
      Map<String, dynamic> silentLoginRes = await silentLogin();
      if (silentLoginRes['code'] == 200) {
        return getAuthenticated(url, retry: retry - 1);
      }
    }
    return decodedResult;
  } catch (e) {
    return errorNetworkResponse;
  }
}

Future<void> initializeApi() async {
  List result = await Future.wait([
    storage.read(key: 'accessToken'),
    storage.read(key: 'refreshToken'),
  ]);
  accessToken = result[0] ?? 'None';
  refreshToken = result[1] ?? 'None';
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

  try {
    String rawBody = result.body;
    Map<String, dynamic> decodedData = jsonDecode(rawBody);
    if (result.statusCode == 200) {
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
    return decodedData;
  } catch (e) {
    return errorNetworkResponse;
  }
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

  try {
    return jsonDecode(result.body);
  } catch (e) {
    return errorNetworkResponse;
  }
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

Future<Map<String, dynamic>> authCheck() {
  return getAuthenticated('$apiUrl/auth/check');
}

Future<Map<String, dynamic>> getUserData() {
  return getAuthenticated('$apiUrl/user');
}

Future<Map<String, dynamic>> updateUser(Map<String, dynamic> body) {
  return postAuthenticated('$apiUrl/user', body, isPut: true);
}

Future<Map<String, dynamic>> generateChannelToken() {
  return postAuthenticated('$apiUrl/bot/token/channel', {});
}

Future<Map<String, dynamic>> generateUserToken() {
  return postAuthenticated('$apiUrl/bot/token/user', {});
}

Future<Map<String, dynamic>> postLocation(
  String latitude,
  String longitude,
  int batteryLevel,
) {
  return postAuthenticated(
    '$apiUrl/location',
    {
      'latitude': latitude,
      'longitude': longitude,
      'battery_level': batteryLevel,
    },
  );
}
