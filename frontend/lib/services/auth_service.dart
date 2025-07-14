import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:intl/intl.dart';
// Для Web
import 'dart:html' as html;
// Для мобильных
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {

  static const String _baseUrl = 'http://localhost:8080'; // localhost из-под Web  
  static String get baseUrl => _baseUrl;

  final _storage = const FlutterSecureStorage();

  Future<void> _saveToken(String token) async {
    if (kIsWeb) {
      html.window.localStorage['jwt_token'] = token;
    } else {
      await _storage.write(key: 'jwt_token', value: token);
    }
  }

  Future<String?> _getToken() async {
    if (kIsWeb) {
      return html.window.localStorage['jwt_token'];
    } else {
      return _storage.read(key: 'jwt_token');
    }
  }

  Future<void> _removeToken() async {
    if (kIsWeb) {
      html.window.localStorage.remove('jwt_token');
    } else {
      await _storage.delete(key: 'jwt_token');
    }
  }

  Future<String> login(String email, String password) async {
    final resp = await http.post(
      Uri.parse('$_baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (resp.statusCode == 200) {
      final token = jsonDecode(resp.body)['token'] as String;
      await _saveToken(token);
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
  Future<String?> get savedToken => _getToken();
  Future<void> logout() => _removeToken();

  /// Добавление новой стресс-сессии
  Future<void> addSession(String description, int level, DateTime date) async {
    final token = await savedToken;
    if (token == null) throw Exception('Токен не найден');

    final payload = {
      'description': description,
      'stress_level': level,
      // полный ISO-стринг с временем и зоной:
      'date': date.toUtc().toIso8601String(),
    };
    print('>> sessions payload: ${jsonEncode(payload)}');  // для отладки
    final response = await http.post(
      Uri.parse('$_baseUrl/sessions'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Ошибка создания сессии (${response.statusCode}): ${response.body}'
      );
    }
  }
}