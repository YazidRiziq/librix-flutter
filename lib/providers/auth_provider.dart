import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  String? _token;

  // Mengecek apakah user sudah punya token (sudah login)
  bool get isAuthenticated => _token != null;

  // Fungsi untuk login user ke Spring Boot
  Future<bool> login(String email, String password) async {
    try {
      final response = await _apiService.post('/auth/login/member', {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token']; // Menyesuaikan response JSON dari Spring Boot

        // Simpan token secara lokal
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);

        notifyListeners(); // Memberitahu seluruh aplikasi bahwa state berubah (user berhasil login)
        return true;
      }
    } catch (e) {
      debugPrint('Error saat login: $e');
    }
    return false;
  }

  // Fungsi untuk mendaftarkan user baru ke Spring Boot
  Future<bool> register(String name, String email, String password) async {
    try {
      final response = await _apiService.post('/auth/register/member', {
        'name': name,
        'email': email,
        'password': password,
      });

      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      }
    } catch (e) {
      debugPrint(
        'Waduh, error pas daftar: $e',
      );
    }
    return false;
  }
}
