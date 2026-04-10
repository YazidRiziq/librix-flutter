import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  String? _token;

  // Mengecek apakah user punya token (sudah login)
  bool get isAuthenticated => _token != null;

  // ---------------------------------------
  // Fungsi untuk login
  // ---------------------------------------
  Future<bool> login(String email, String password) async {
    try {
      final response = await _apiService.post('/auth/login/member', {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        _token = data['token']; 
        final String name = data['name'];
        final String userEmail = data['email'];
        final String memID = data['id'];

        // Membuka brankas penyimpanan lokal
        final prefs = await SharedPreferences.getInstance();
        
        // Menyimpan data-data ke dalam brankas lokal
        await prefs.setString('token', _token!);
        await prefs.setString('name', name);
        await prefs.setString('email', userEmail);
        await prefs.setString('memID', memID);

        notifyListeners(); 
        return true;
      }
    } catch (e) {
      developer.log('Error saat login: $e');
    }
    return false;
  }

  // -------------------------------------------------
  // Fungsi untuk Register
  // -------------------------------------------------
  Future<bool> register(String name, String email, String telp, String address, String password) async {
    try {
      final response = await _apiService.post('/auth/register/member', {
        'name': name,
        'email': email,
        'telp': telp,
        'address': address,
        'password': password,
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true; 
      }
    } catch (e) {
      developer.log('Error saat register: $e');
    }
    return false;
  }
}
