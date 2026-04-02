import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends StatelessWidget {
  // Controller ini ibarat "id" atau "ref" di HTML untuk mengambil teks dari input
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar = Header di Web
      appBar: AppBar(title: const Text('Daftar Akun Librix')),
      
      // SingleChildScrollView = Supaya layar bisa di-scroll kalau keyboard muncul
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0), // Jarak dalam (padding) 24 pixel
          child: Column(
            children: [
              // Input Nama
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Nama Lengkap', // Placeholder/Label input
                  border: OutlineInputBorder(), // Garis pinggir kotak input
                  prefixIcon: Icon(Icons.person), // Ikon di sebelah kiri input
                ),
              ),
              const SizedBox(height: 16), // Jarak antar elemen (Margin Bottom)
              
              // Input Email
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
              ),
              const SizedBox(height: 16),
              
              // Input Password
              TextField(
                controller: passwordController,
                obscureText: true, // Menyembunyikan teks (untuk password)
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
              ),
              const SizedBox(height: 24),
              
              // Tombol Daftar
              SizedBox(
                width: double.infinity, // Lebar penuh (w-full di Tailwind)
                height: 50, // Tinggi tombol
                child: ElevatedButton(
                  onPressed: () async {
                    // Mengambil fungsi register dari provider
                    final auth = Provider.of<AuthProvider>(context, listen: false);
                    
                    final success = await auth.register(
                      nameController.text,
                      emailController.text,
                      passwordController.text,
                    );

                    if (context.mounted) {
                      if (success) {
                        // Menampilkan notifikasi sukses (Toast/SnackBar)
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Registrasi Berhasil! Silakan Login.')),
                        );
                        // Kembali ke halaman Login (Navigator.pop ibarat tombol Back di browser)
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Registrasi Gagal, coba lagi.')),
                        );
                      }
                    }
                  },
                  child: const Text('DAFTAR SEKARANG'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}