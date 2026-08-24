import "package:shared_preferences/shared_preferences.dart";

import "api_client.dart";

class AuthService {
  static const _tokenKey = "auth_token";
  static const _nameKey = "customer_name";

  Future<void> login({required String email, required String password}) async {
    final client = ApiClient();
    final result = await client.post(
      "/auth/login",
      {
        "email": email.trim().toLowerCase(),
        "password": password,
      },
      includeAuth: false,
    );

    final token = result["token"]?.toString() ?? "";
    final customer = (result["customer"] as Map<String, dynamic>? ?? <String, dynamic>{});
    final fullName = customer["fullName"]?.toString() ?? "Customer";

    if (token.isEmpty) {
      throw Exception("Token missing in login response");
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_nameKey, fullName);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<String> getCustomerName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_nameKey) ?? "Customer";
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_nameKey);
  }
}
