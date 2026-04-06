import 'package:flutter/material.dart';
import 'package:librix/screens/profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import halaman-halaman tab kita
import 'library_screen.dart';
import 'search_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0; // State untuk melacak tab mana yang sedang aktif
  String userName = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('name') ?? 'Scholar';
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryDarkBlue = Color(0xFF111860);

    // Array berisi halaman-halaman yang akan ditukar-tukar
    // Kita passing parameter userName ke LibraryScreen
    final List<Widget> pages = [
      LibraryScreen(
        userName: userName,
        // Ini adalah "remote" yang kita berikan ke LibraryScreen
        onNavigateToSearch: () {
          setState(() {
            _currentIndex = 1; // Pindah ke tab Search (Index 1)
          });
        },
      ), 
      const SearchScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      
      // body akan berubah-ubah sesuai index tab yang dipilih
      body: pages[_currentIndex],

      // Konfigurasi Navigasi Bawah
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: primaryDarkBlue, // Warna saat aktif
        unselectedItemColor: Colors.grey, // Warna saat tidak aktif
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          // Mengubah state untuk me-render ulang UI dengan halaman baru
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'LIBRARY',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'SEARCH',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'PROFILE',
          ),
        ],
      ),
    );
  }
}