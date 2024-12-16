import 'package:http/http.dart' as http;
import 'dart:convert';

class Api {
  static const String baseUrl = 'http://localhost:5000';

  static Future<http.Response> get(String endpoint, [String? accessToken]) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    final Map<String, String> headers = accessToken != null ? {'Authorization': 'Bearer $accessToken'} : {};
    return await http.get(url, headers: headers);
  }

  static Future<http.Response> post(String endpoint, Map<String, dynamic> body, [String? accessToken]) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      if (accessToken != null) 'Authorization': 'Bearer $accessToken',
    };
    return await http.post(url, headers: headers, body: jsonEncode(body));
  }

  static Future<http.Response> put(String endpoint, Map<String, dynamic> body, [String? accessToken]) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      if (accessToken != null) 'Authorization': 'Bearer $accessToken',
    };
    return await http.put(url, headers: headers, body: jsonEncode(body));
  }

  static Future<http.Response> delete(String endpoint, [String? accessToken]) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    final Map<String, String> headers = accessToken != null ? {'Authorization': 'Bearer $accessToken'} : {};
    return await http.delete(url, headers: headers);
  }
}

class UserApi {
  static Future<http.Response> getUser(String name, String password) async {
    return await Api.post('user/login', {'name': name, 'password': password});
  }
}

class ClientApi {
  static Future<http.Response> getAllClients(int userId, String accessToken) async {
    return await Api.get('client/getAll/$userId', accessToken);
  }

  static Future<http.Response> createClient(Map<String, dynamic> clientData, String accessToken) async {
    return await Api.post('client/create', clientData, accessToken);
  }

  static Future<http.Response> getClientById(int clientId, String accessToken) async {
    return await Api.get('client/get/$clientId', accessToken);
  }

  static Future<http.Response> updateClient(int clientId, Map<String, dynamic> clientData, String accessToken) async {
    return await Api.put('client/update/$clientId', clientData, accessToken);
  }

  static Future<http.Response> deleteClient(int clientId, String accessToken) async {
    return await Api.delete('client/delete/$clientId', accessToken);
  }
}
