import 'package:http/http.dart' as http;
import 'dart:convert';

class Api {
  static const String baseUrl = 'http://localhost:5000';

  static Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    return await http.get(url);
  }

  static Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    return await http.post(url, headers: {'Content-Type': 'application/json'}, body: jsonEncode(body));
  }

  static Future<http.Response> put(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    return await http.put(url, headers: {'Content-Type': 'application/json'}, body: jsonEncode(body));
  }

  static Future<http.Response> delete(String endpoint) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    return await http.delete(url);
  }
}

class UserApi {

  static Future<http.Response> getUser(String name, String password) async {

    final Map<String,dynamic> body = {
      'name': name,
      'password': password,
    };

    return await Api.post('user/login', body);
  }

}

class ClientApi {

}