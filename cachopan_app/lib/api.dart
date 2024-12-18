import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Api {
  static const String baseUrl = 'http://localhost:5000';
  static final storage = FlutterSecureStorage();

  static Future<String?> _getAccessToken() async {
    return await storage.read(key: 'access_token');
  }

  static Future<String?> _refreshAccessToken() async {
    print('Refreshing access token');
    final refreshToken = await storage.read(key: 'refresh_token');
    if (refreshToken == null) return null;

    final response = await http.post(
      Uri.parse('$baseUrl/user/refresh'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $refreshToken',
      },
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      final newAccessToken = responseData['access_token'];
      await storage.write(key: 'access_token', value: newAccessToken);
      return newAccessToken;
    } else {
      return null;
    }
  }

  static Future<http.Response> _retryRequest(
      Future<http.Response> Function(String?) requestFunction) async {
    try {
      final newAccessToken = await _refreshAccessToken();
      if (newAccessToken != null) {
        return await requestFunction(newAccessToken);
      } else {
        throw Exception('Failed to refresh access token');
      }
    } catch (e) {
      print('Error refreshing access token: $e');
      rethrow;
    }
  }

  static Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    final accessToken = await _getAccessToken();
    final Map<String, String> headers = accessToken != null ? {'Authorization': 'Bearer $accessToken'} : {};
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 401 && accessToken != null) {
      return await _retryRequest((newToken) => get(endpoint));
    }

    return response;
  }

  static Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    final accessToken = await _getAccessToken();
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      if (accessToken != null) 'Authorization': 'Bearer $accessToken',
    };
    final response = await http.post(url, headers: headers, body: jsonEncode(body));

    if (response.statusCode == 401 && accessToken != null) {
      return await _retryRequest((newToken) => post(endpoint, body));
    }

    return response;
  }

  static Future<http.Response> put(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    final accessToken = await _getAccessToken();
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      if (accessToken != null) 'Authorization': 'Bearer $accessToken',
    };
    final response = await http.put(url, headers: headers, body: jsonEncode(body));

    if (response.statusCode == 401 && accessToken != null) {
      return await _retryRequest((newToken) => put(endpoint, body));
    }

    return response;
  }

  static Future<http.Response> delete(String endpoint) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    final accessToken = await _getAccessToken();
    final Map<String, String> headers = accessToken != null ? {'Authorization': 'Bearer $accessToken'} : {};
    final response = await http.delete(url, headers: headers);

    if (response.statusCode == 401 && accessToken != null) {
      return await _retryRequest((newToken) => delete(endpoint));
    }

    return response;
  }
}

class UserApi {
  static Future<http.Response> getUser(String name, String password) async {
    return await Api.post('user/login', {'name': name, 'password': password});
  }
}

class ClientApi {
  static Future<http.Response> getAllClients(int userId, String search) async {
    return await Api.get('client/getAll/$userId?search=$search');
  }

  static Future<http.Response> createClient(Map<String, dynamic> clientData) async {
    return await Api.post('client/create', clientData);
  }

  static Future<http.Response> getClientById(int clientId) async {
    return await Api.get('client/get/$clientId');
  }

  static Future<http.Response> updateClient(int clientId, Map<String, dynamic> clientData) async {
    return await Api.put('client/update/$clientId', clientData);
  }

  static Future<http.Response> deleteClient(int clientId) async {
    return await Api.delete('client/delete/$clientId');
  }
}

class ArticleApi {
  static Future<http.Response> getAllArticles(int userId, String search) async {
    return await Api.get('article/getAll/$userId?search=$search');
  }

  static Future<http.Response> createArticle(Map<String, dynamic> articleData) async {
    return await Api.post('article/create', articleData);
  }

  static Future<http.Response> getArticleById(int articleId) async {
    return await Api.get('article/get/$articleId');
  }

  static Future<http.Response> updateArticle(int articleId, Map<String, dynamic> articleData) async {
    return await Api.put('article/update/$articleId', articleData);
  }

  static Future<http.Response> deleteArticle(int articleId) async {
    return await Api.delete('article/delete/$articleId');
  }
}
