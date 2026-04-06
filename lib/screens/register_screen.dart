import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

// Kita pakai StatefulWidget karena butuh menyimpan state (status) Checkbox
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Semua controller untuk 5 inputan kita
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController telpController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Variabel (state) untuk melacak apakah Checkbox dicentang
  bool isAgreed = false; 

  @override
  Widget build(BuildContext context) {
    const Color primaryDarkBlue = Color(0xFF111860);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB), // Background abu-abu muda
      body: SafeArea( // SafeArea menjaga agar UI tidak tertutup notch/kamera HP
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // --- BAGIAN HEADER (Custom, tanpa AppBar bawaan) ---
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Librix App',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primaryDarkBlue,
                      ),
                    ),
                    // Tombol panah back
                    TextButton.icon(
                      onPressed: () {
                        Navigator.pop(context); // Kembali ke halaman Login
                      },
                      icon: const Icon(Icons.arrow_back, size: 16, color: primaryDarkBlue),
                      label: const Text(
                        'BACK TO LOGIN',
                        style: TextStyle(color: primaryDarkBlue, letterSpacing: 1.0),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // --- BAGIAN KARTU PUTIH ---
                Container(
                  padding: const EdgeInsets.all(32.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Create Account',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Begin your journey in the library sanctuary.',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                      const SizedBox(height: 32),

                      // --- MEMANGGIL REUSABLE INPUT FIELDS ---
                      _buildInputField('FULL NAME', 'Enter your name', nameController),
                      _buildInputField('EMAIL ADDRESS', 'Enter your email', emailController),
                      _buildInputField('PHONE NUMBER', 'Enter your phone', telpController),
                      _buildInputField('HOME ADDRESS', 'Enter your address', addressController),
                      _buildInputField('PASSWORD', '••••••••', passwordController, isPassword: true),

                      // --- BAGIAN CHECKBOX ---
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Checkbox(
                            value: isAgreed,
                            activeColor: primaryDarkBlue,
                            onChanged: (bool? value) {
                              // setState ini mirip seperti setNamaVariabel di React
                              // Fungsinya me-render ulang layar saat kotak dicentang
                              setState(() {
                                isAgreed = value ?? false;
                              });
                            },
                          ),
                          Expanded( // Expanded agar teks tidak nabrak batas layar (overflow)
                            child: const Text(
                              'I agree to the Terms of Service and Privacy Policy.',
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // --- TOMBOL SIGN UP ---
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryDarkBlue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 5,
                          ),
                          onPressed: () async {
                            // Validasi sederhana: pastikan centang dicentang
                            if (!isAgreed) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Please agree to the terms first!')),
                              );
                              return; // Hentikan eksekusi kalau belum dicentang
                            }

                            final auth = Provider.of<AuthProvider>(context, listen: false);
                            
                            // Eksekusi API Register
                            final success = await auth.register(
                              nameController.text,
                              emailController.text,
                              telpController.text,
                              addressController.text,
                              passwordController.text,
                            );

                            if (context.mounted) {
                              if (success) {
                                // Tampilkan notifikasi berhasil
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Registrasi Berhasil! Silakan Login.'),
                                    backgroundColor: Colors.green, // Warna hijau biar afdol
                                  ),
                                );
                                // Pindahkan ke halaman login
                                Navigator.pop(context);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Registrasi Gagal. Coba lagi.')),
                                );
                              }
                            }
                          },
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),

                      // --- LINK SIGN IN DI BAWAH ---
                      Center(
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          children: [
                            const Text('Already a member? '),
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context); // Kembali ke Login
                              },
                              child: const Text(
                                'Sign In',
                                style: TextStyle(color: primaryDarkBlue, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- REUSABLE COMPONENT UNTUK KOTAK INPUT ---
  // Fungsi ini bertugas mencetak label dan TextField, agar kode di atas bersih.
  Widget _buildInputField(String label, String hint, TextEditingController controller, {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0), // Jarak bawah antar input
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            obscureText: isPassword, // Sembunyikan teks kalau ini input password
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: const Color(0xFFF3F4F6),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}