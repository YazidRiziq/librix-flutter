import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final ApiService _apiService = ApiService();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController telpController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  String memID = '';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  // Mengambil data awal dari brankas HP untuk mengisi form Name dan Email
  Future<void> _loadInitialData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      memID = prefs.getString('memID') ?? '';
      nameController.text = prefs.getString('name') ?? '';
      emailController.text = prefs.getString('email') ?? '';
      // Telp dan Address dikosongkan dulu karena belum ada di SharedPreferences
    });
  }

  Future<void> _updateProfile() async {
    if (memID.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: ID Member tidak ditemukan!')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      // Menyiapkan paket data sesuai struktur API kamu
      final Map<String, dynamic> payload = {
        "memName": nameController.text,
        "memEmail": emailController.text,
        "memTelp": telpController.text,
        "memAddress": addressController.text,
      };

      final response = await _apiService.put('/members/$memID', payload);

      if (response.statusCode == 200) {
        // Karena Spring Boot me-return Teks Biasa, BUKAN JSON, 
        // kita TIDAK PERLU menggunakan jsonDecode(response.body) di sini.

        // Simpan nama & email baru ke brankas HP agar Profile Screen ikut berubah
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('name', nameController.text);
        await prefs.setString('email', emailController.text);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context, true); // Kembali ke halaman sebelumnya dan kirim sinyal 'true'
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal update: ${response.statusCode}')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e')),
        );
      }
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryDarkBlue = Color(0xFF111860);
    const Color bgColor = Color(0xFFF9FAFB);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryDarkBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Librix App', style: TextStyle(color: primaryDarkBlue, fontSize: 16, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER TEXT ---
              const Text('ACCOUNT SETTINGS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.teal, letterSpacing: 1.5)),
              const SizedBox(height: 8),
              const Text('Edit Personal Info', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: primaryDarkBlue)),
              const SizedBox(height: 8),
              const Text('Refine your archival profile to personalize your journey through the sanctuary.', style: TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 32),

              // --- FOTO PAJANGAN (DUMMY) ---
              Row(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.blueGrey[800],
                      borderRadius: BorderRadius.circular(16),
                      image: const DecorationImage(
                        // Menggunakan gambar placeholder random
                        image: NetworkImage('https://placehold.co/400x400/2c3e50/white?text=Avatar'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.camera_alt, color: primaryDarkBlue, size: 16),
                          SizedBox(width: 8),
                          Text('Change Portrait', style: TextStyle(fontWeight: FontWeight.bold, color: primaryDarkBlue)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      const Text('Recommended: 400x400px', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // --- FORM INPUT ---
              _buildInputField('FULL NAME', 'E.g. Julian Thorne', nameController),
              _buildInputField('EMAIL ADDRESS', 'julian.thorne@atelier.com', emailController),
              _buildInputField('PHONE NUMBER', '+1 (555) 012-3456', telpController),
              
              // Mengganti Archival Bio menjadi Home Address sesuai API
              _buildInputField('HOME ADDRESS', 'Enter your home address...', addressController, maxLines: 3),
              const SizedBox(height: 32),

              // --- TOMBOL SAVE & DISCARD ---
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryDarkBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: isLoading ? null : _updateProfile,
                  child: isLoading 
                      ? const CircularProgressIndicator(color: Colors.white) 
                      : const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Discard', style: TextStyle(color: primaryDarkBlue, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 32),

              // --- DATA PRIVACY CARD ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(16)),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.security, color: Colors.teal),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Data Privacy', style: TextStyle(fontWeight: FontWeight.bold, color: primaryDarkBlue)),
                          SizedBox(height: 4),
                          Text(
                            'Your personal information is encrypted and stored in our secure vault. We never share your data with third parties.',
                            style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.5),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- REUSABLE WIDGET UNTUK INPUT FORM ---
  Widget _buildInputField(String label, String hint, TextEditingController controller, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(color: Colors.black38),
              filled: true,
              fillColor: const Color(0xFFF3F4F6),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
        ],
      ),
    );
  }
}