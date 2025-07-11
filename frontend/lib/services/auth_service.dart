import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:async';

class AuthService {
  static const String _baseUrl = 'http://10.0.2.2:8080'; // localhost из-под эмулятора Android
  final _storage = const FlutterSecureStorage();

  /// Входит и сразу кладёт токен в SecureStorage.
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

  /// TODO: Подключить API регистрации, когда появится backend.
  Future<void> register(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // Заглушка, имитирует сетевой вызов

    final fakeResponseStatusCode = 201;

    if (fakeResponseStatusCode != 201) {
      throw Exception('Ошибка регистрации');
    }

    // Если всё ок — ничего не делаем, просто выходим из метода
  }

  /// Просто помощник, если где-то нужно достать токен.
  Future<String?> get savedToken =>
      _storage.read(key: 'jwt_token');

  Future<void> logout() => _storage.delete(key: 'jwt_token');
}