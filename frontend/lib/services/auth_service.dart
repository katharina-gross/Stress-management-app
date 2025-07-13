import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:async';

class AuthService {

  static const String _baseUrl = 'http://localhost:8080'; // localhost из-под эмулятора Android
  static String get baseUrl => _baseUrl;

  final _storage = const FlutterSecureStorage();


  Future<String> login(String email, String password) async {
    final resp = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (resp.statusCode == 200) {
      final token = jsonDecode(resp.body)['token'] as String;
      await _storage.write(key: 'jwt_token', value: token);
      return token;
    }

    throw Exception('Ошибка входа (${resp.statusCode}): ${resp.body}');
  }

  Future<void> register(String email, String password, String nickname) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/register'),
      body: json.encode({
        'email': email,
        'password': password,
        'nickname': nickname,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 201) {
      throw Exception('Ошибка регистрации');
    }
  }

  /// Просто помощник, если где-то нужно достать токен.
  Future<String?> get savedToken => _storage.read(key: 'jwt_token');
  Future<void> logout() => _storage.delete(key: 'jwt_token');

  /// Добавление новой стресс-сессии
  Future<void> addSession(String description, int level, DateTime date) async {
    final token = await savedToken;
    if (token == null) throw Exception('Токен не найден');

    final response = await http.post(
      Uri.parse('$_baseUrl/sessions'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'description': description,
        'stress_level': level,
        'date': date.toIso8601String(),
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Ошибка создания сессии (${response.statusCode}): ${response.body}');
    }
  }
}