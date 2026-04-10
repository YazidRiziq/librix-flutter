import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'dashboard_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // warna utama dari desain (Biru Gelap)
    const Color primaryDarkBlue = Color(0xFF111860);

    return Scaffold(
      // Warna background abu-abu sangat muda (mirip desain)
      backgroundColor: const Color(0xFFF9FAFB),
      
      body: Center(
        // SingleChildScrollView agar tidak error saat keyboard muncul
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            
            // Container ini adalah "KARTU PUTIH" tempat form berada
            child: Container(
              padding: const EdgeInsets.all(32.0),
              decoration: BoxDecoration(
                color: Colors.white, // Warna kartu putih
                borderRadius: BorderRadius.circular(24), // Ujung kartu melengkung
                boxShadow: [
                  // Memberikan efek bayangan tipis di belakang kartu
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Tinggi kartu menyesuaikan isi
                crossAxisAlignment: CrossAxisAlignment.start, // Semua rata kiri
                children: [
                  // --- BAGIAN LOGO & JUDUL ---
                  Row(
                    children: [
                      // Ikon Buku (Pengganti logo The Digital Atelier)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: primaryDarkBlue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.menu_book, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Librix App',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: primaryDarkBlue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Please sign in to your collection',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 32),

                  // --- BAGIAN INPUT EMAIL ---
                  const Text(
                    'EMAIL',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      hintText: 'Enter your email', // Placeholder teks
                      prefixIcon: const Icon(Icons.person, color: Colors.grey),
                      filled: true, // Mengaktifkan warna background input
                      fillColor: const Color(0xFFF3F4F6), // Warna abu-abu muda untuk input
                      // Menghilangkan garis border bawaan
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none, 
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- BAGIAN INPUT PASSWORD ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'PASSWORD',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                      ),
                      // Teks Lupa Password yang bisa diklik
                      GestureDetector(
                        onTap: () {
                          // TODO: Fitur lupa password
                        },
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(fontSize: 12, color: Colors.teal, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: '••••••••',
                      prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFFF3F4F6),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // --- BAGIAN TOMBOL LOGIN ---
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryDarkBlue, // Warna tombol biru gelap
                        foregroundColor: Colors.white, // Warna teks putih
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16), // Tombol agak melengkung
                        ),
                        elevation: 5, // Efek bayangan pada tombol
                      ),
                      onPressed: () async {
                        final auth = Provider.of<AuthProvider>(context, listen: false);
                        final success = await auth.login(
                          emailController.text,
                          passwordController.text,
                        );

                        if (context.mounted) {
                          if (success) {
                            // Jika berhasil, navigasi ke Dashboard!
                            // pushReplacement digunakan agar user tidak bisa "back" ke layar login lagi
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const DashboardScreen()),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Login Gagal. Cek kembali datanya.')),
                            );
                          }
                        }
                      },
                      child: const Text(
                        'Sign In',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // --- BAGIAN BAWAH (DAFTAR & IKON SOSIAL) ---
                  const Divider(), // Garis horizontal
                  const SizedBox(height: 16),
                  Center(
                    child: Wrap(
                      alignment: WrapAlignment.center, // Ini menengahkan teks kalau dia turun ke bawah
                      children: [
                        const Text('New to the library? '),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => RegisterScreen()),
                            );
                          },
                          child: const Text(
                            'Create an Account',
                            style: TextStyle(color: primaryDarkBlue, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Ikon bulat sebagai pemanis UI sesuai gambar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildCircularIcon(Icons.g_mobiledata), // Anggap ini logo Google
                      const SizedBox(width: 16),
                      _buildCircularIcon(Icons.fingerprint), // Logo Fingerprint
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Fungsi kecil (widget builder) untuk membuat tombol bulat abu-abu di bawah
  Widget _buildCircularIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        shape: BoxShape.circle, // Membuat bentuk menjadi lingkaran sempurna
      ),
      child: Icon(icon, color: Colors.grey[700]),
    );
  }
}