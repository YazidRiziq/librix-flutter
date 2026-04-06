import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/book_model.dart'; // Import file model

class BookDetailScreen extends StatefulWidget {
  final String bookCode;

  const BookDetailScreen({super.key, required this.bookCode});

  @override
  State<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends State<BookDetailScreen> {
  final ApiService _apiService = ApiService();
  BookDetail? bookDetail;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBookDetail();
  }

  Future<void> _fetchBookDetail() async {
    try {
      // Memanggil API detail buku menggunakan bookCode
      final response = await _apiService.get('/books/book_detail/${widget.bookCode}');
      if (response.statusCode == 200) {
        // 1. Kita tampung dulu datanya tanpa menentukan tipe secara kaku
        final decodedData = jsonDecode(response.body);
        Map<String, dynamic> jsonData;

        // 2. Kita cek, apakah Spring Boot mengirim Kardus Besar (List/Array)?
        if (decodedData is List) {
          if (decodedData.isNotEmpty) {
            // Ambil barang urutan pertama (index 0) dari dalam kardus
            jsonData = decodedData[0]; 
          } else {
            throw Exception('Data buku kosong dari API');
          }
        } else {
          // Kalau Spring Boot mengirim Kotak Sepatu (Map/Object) langsung
          jsonData = decodedData; 
        }

        setState(() {
          // 3. Masukkan datanya ke model kita
          bookDetail = BookDetail.fromJson(jsonData);
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching book detail: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryDarkBlue = Color(0xFF111860);
    const Color bgColor = Color(0xFFF9FAFB);

    if (isLoading) {
      return const Scaffold(
        backgroundColor: bgColor,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (bookDetail == null) {
      return Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(backgroundColor: bgColor, elevation: 0),
        body: const Center(child: Text('Buku tidak ditemukan.')),
      );
    }

    return Scaffold(
      backgroundColor: bgColor,
      // AppBar khusus untuk halaman detail yang bersih
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryDarkBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Librix App',
          style: TextStyle(color: primaryDarkBlue, fontSize: 16, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: primaryDarkBlue),
            onPressed: () {}, // Tombol share visual saja
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- BAGIAN GAMBAR COVER ---
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 16, bottom: 32),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    bookDetail!.coverUrl,
                    height: 320,
                    width: 220,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => 
                      Container(height: 320, width: 220, color: Colors.grey),
                  ),
                ),
              ),
            ),

            // --- BAGIAN DETAIL TEKS ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kategori Buku (Pill Hijau)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.tealAccent.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      bookDetail!.catName.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.teal, 
                        fontSize: 10, 
                        fontWeight: FontWeight.bold, 
                        letterSpacing: 1.2
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Judul Buku
                  Text(
                    bookDetail!.bookTitle,
                    style: const TextStyle(
                      fontSize: 28, 
                      fontWeight: FontWeight.bold, 
                      color: primaryDarkBlue, 
                      height: 1.2
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Penulis
                  Text(
                    'by ${bookDetail!.autName}',
                    style: const TextStyle(
                      fontSize: 16, 
                      fontStyle: FontStyle.italic, 
                      color: Colors.grey
                    ),
                  ),
                  const SizedBox(height: 24),

                  // --- INFO CARDS (Pages, Publisher, Year) ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoCard('PAGES', bookDetail!.numPages.toString()),
                      const SizedBox(width: 12), // Jarak antar card
                      _buildInfoCard('PUBLISHER', bookDetail!.publisher),
                      const SizedBox(width: 12),
                      _buildInfoCard('YEAR', bookDetail!.pubYear.toString()),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // --- SINOPSIS ---
                  const Text(
                    'Synopsis',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryDarkBlue),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    bookDetail!.synopsis,
                    style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.6),
                    textAlign: TextAlign.justify,
                  ),
                  
                  // Tambahan informasi ISBN di bawah sinopsis agar lengkap
                  const SizedBox(height: 16),
                  Text(
                    'ISBN: ${bookDetail!.isbn}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 48), // Padding bawah agar scrollnya nyaman
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGET BANTUAN UNTUK KOTAK INFO ---
  Widget _buildInfoCard(String title, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 1.0),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF111860)),
              maxLines: 1,
              overflow: TextOverflow.ellipsis, // Agar teks publisher panjang tidak error
            ),
          ],
        ),
      ),
    );
  }
}