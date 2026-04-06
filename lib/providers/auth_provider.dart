import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  String? _token;

  // Mengecek apakah user sudah punya token (sudah login)
  bool get isAuthenticated => _token != null;

  // ---------------------------------------
  // Fungsi untuk login user ke Spring Boot
  // ---------------------------------------
  Future<bool> login(String email, String password) async {
    try {
      final response = await _apiService.post('/auth/login/member', {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Mengambil data dari response JSON Spring Boot kamu
        _token = data['token']; 
        final String name = data['name']; // Mengambil nama ("Baim")
        final String userEmail = data['email']; // Mengambil email
        final String memID = data['id']; // Mengambil memID (ID pengguna)

        // Membuka brankas penyimpanan lokal HP
        final prefs = await SharedPreferences.getInstance();
        
        // Menyimpan data-data tersebut ke dalam brankas
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
  // Fungsi untuk mendaftarkan user baru ke Spring Boot
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
