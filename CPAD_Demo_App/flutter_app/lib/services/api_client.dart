import "dart:convert";

import "package:flutter/foundation.dart";
import "package:http/http.dart" as http;

class ApiClient {
  final String? authToken;

  ApiClient({this.authToken});

  static String get baseUrl {
    if (kIsWeb) {
      return "http://localhost:4000/api";
    }
    return "http://10.0.2.2:4000/api";
  }

  Map<String, String> _headers({bool includeAuth = true}) {
    final headers = <String, String>{
      "Content-Type": "application/json",
    };

    if (includeAuth && authToken != null && authToken!.isNotEmpty) {
      headers["Authorization"] = "Bearer $authToken";
    }

    return headers;
  }

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body, {bool includeAuth = true}) async {
    final response = await http.post(
      Uri.parse("$baseUrl$path"),
      headers: _headers(includeAuth: includeAuth),
      body: jsonEncode(body),
    );
    return _parseResponse(response);
  }

  Future<Map<String, dynamic>> get(String path) async {
    final response = await http.get(
      Uri.parse("$baseUrl$path"),
      headers: _headers(),
    );
    return _parseResponse(response);
  }

  Map<String, dynamic> _parseResponse(http.Response response) {
    final decoded = response.body.isEmpty ? <String, dynamic>{} : jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }

    final message = decoded["message"]?.toString() ?? "Request failed (${response.statusCode})";
    throw Exception(message);
  }
}
