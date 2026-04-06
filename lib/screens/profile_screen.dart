import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:librix/screens/borrowed_history_screen.dart';
import 'package:librix/screens/edit_profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'login_screen.dart'; // Untuk navigasi saat logout

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _apiService = ApiService();
  
  String userName = '';
  String userEmail = '';
  String memID = '';
  
  int ongoingBorrowed = 0;
  int doneBorrowed = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    
    setState(() {
      userName = prefs.getString('name') ?? 'Scholar';
      userEmail = prefs.getString('email') ?? 'user@email.com';
      memID = prefs.getString('memID') ?? '';
    });

    debugPrint('DEBUG CCTV 1: memID di brankas adalah = "$memID"');

    if (memID.isNotEmpty) {
      try {
        final response = await _apiService.get('/members/stats/$memID');
        
        if (response.statusCode == 200) {
          final decodedData = jsonDecode(response.body);
          
          if (decodedData is List && decodedData.isNotEmpty) {
            final data = decodedData[0]; 
            
            setState(() {
              ongoingBorrowed = data['ongoing_borrowed'] ?? 0;
              doneBorrowed = data['done_borrowed'] ?? 0;
            });
          }
          else if (decodedData is Map) { 
            setState(() {
              ongoingBorrowed = decodedData['ongoing_borrowed'] ?? 0;
              doneBorrowed = decodedData['done_borrowed'] ?? 0;
            });
          }
        }
      } catch (e) {
        debugPrint('Ada Error -> $e');
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryDarkBlue = Color(0xFF111860);
    const Color bgColor = Color(0xFFF9FAFB);

    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // --- HEADER ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.menu, color: primaryDarkBlue),
                  const Text('Librix App', style: TextStyle(fontWeight: FontWeight.bold, color: primaryDarkBlue, fontSize: 16)),
                  const Icon(Icons.notifications, color: primaryDarkBlue),
                ],
              ),
              const SizedBox(height: 32),

              // --- FOTO PROFIL & IDENTITAS ---
              Center(
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.blueGrey,
                      child: Icon(Icons.person, size: 60, color: Colors.white),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(color: primaryDarkBlue, shape: BoxShape.circle),
                      child: const Icon(Icons.edit, color: Colors.white, size: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(userName, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryDarkBlue)),
              const SizedBox(height: 4),
              Text(userEmail, style: const TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 32),

              // --- STATISTIK PEMINJAMAN (ONGOING & DONE) ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStatBox(ongoingBorrowed.toString(), 'ONGOING'),
                  const SizedBox(width: 16),
                  _buildStatBox(doneBorrowed.toString(), 'DONE'),
                ],
              ),
              const SizedBox(height: 40),

              // --- ACCOUNT MANAGEMENT MENU ---
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('ACCOUNT MANAGEMENT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: Colors.grey)),
              ),
              const SizedBox(height: 16),

              // Tombol Personal Info
              _buildMenuCard(
                icon: Icons.person,
                iconColor: Colors.indigo,
                iconBgColor: Colors.indigo.withOpacity(0.1),
                title: 'Personal Info',
                subtitle: 'Update your bio and credentials',
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                  );

                  if (result == true) {
                    _loadProfileData(); 
                  }
                },
              ),

              // Tombol My Borrowed Books
              _buildMenuCard(
                icon: Icons.menu_book,
                iconColor: Colors.teal,
                iconBgColor: Colors.teal.withOpacity(0.1),
                title: 'My Borrowed Books',
                subtitle: 'Manage active loans and history',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const BorrowedHistoryScreen()),
                  );
                },
              ),
              const SizedBox(height: 24),

              // --- TOMBOL LOGOUT ---
              SizedBox(
                width: double.infinity,
                height: 55,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.red.withOpacity(0.3)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text('Logout', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
                  onPressed: () async {
                    // Hapus data dari brankas lokal saat logout
                    final prefs = await SharedPreferences.getInstance();
                    await prefs.clear();

                    if (context.mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET BANTUAN UNTUK KOTAK STATISTIK ---
  Widget _buildStatBox(String count, String label) {
    return Container(
      width: 110,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6), // Abu-abu muda
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(count, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF111860))),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2)),
        ],
      ),
    );
  }

  // --- WIDGET BANTUAN UNTUK MENU CARD ---
  Widget _buildMenuCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 5)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: iconBgColor, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF111860))),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}