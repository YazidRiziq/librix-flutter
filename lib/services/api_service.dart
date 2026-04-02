import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class ApiService {
  // Fungsi internal untuk meracik Header
  // Otomatis menyelipkan Token JWT jika user sudah login
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // Fungsi template untuk HTTP POST (Login, Register, Create Data)
  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse('${Constants.baseUrl}$endpoint');
    final headers = await _getHeaders();
    
    return await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );
  }

  // Fungsi template untuk HTTP GET (Get Books, Get Profile)
  Future<http.Response> get(String endpoint) async {
    final url = Uri.parse('${Constants.baseUrl}$endpoint');
    final headers = await _getHeaders();
    
    return await http.get(url, headers: headers);
  }
}