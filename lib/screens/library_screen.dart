import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/book_model.dart';
import 'book_detail_screen.dart';

class LibraryScreen extends StatefulWidget {
  final String userName;
  final VoidCallback onNavigateToSearch; // Fungsi untuk pindah ke tab Search

  const LibraryScreen({super.key, required this.userName, required this.onNavigateToSearch});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final ApiService _apiService = ApiService();
  
  List<Book> trendingBooks = [];
  List<Book> recommendedBooks = [];
  bool isLoading = true; // Status loading saat menunggu API

  @override
  void initState() {
    super.initState();
    _fetchBooks();
  }

  Future<void> _fetchBooks() async {
    try {
      final response = await _apiService.get('/books/dashboard');
      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body);
        
        // Ubah semua JSON jadi objek Book
        List<Book> allBooks = jsonList.map((json) => Book.fromJson(json)).toList();

        setState(() {
          // Ambil 4 buku pertama untuk Trending
          trendingBooks = allBooks.take(4).toList();
          
          // Ambil 10 buku terakhir untuk Rekomendasi (Dibalik posisinya agar yang paling akhir di atas)
          recommendedBooks = allBooks.length > 10 
              ? allBooks.sublist(allBooks.length - 10).reversed.toList() 
              : allBooks.reversed.toList();
          
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching books: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryDarkBlue = Color(0xFF111860);

    // Tampilkan indikator loading jika data belum datang
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER & WELCOME TEXT ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.menu, color: primaryDarkBlue),
                  Column(
                    children: const [
                      Text('Librix App', style: TextStyle(fontWeight: FontWeight.bold, color: primaryDarkBlue, fontSize: 16)),
                      Text('SCHOLARLY SANCTUARY', style: TextStyle(fontSize: 8, letterSpacing: 2, color: Colors.grey)),
                    ],
                  ),
                  const Icon(Icons.notifications, color: primaryDarkBlue),
                ],
              ),
              const SizedBox(height: 32),
              Text('Welcome, ${widget.userName}.', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: primaryDarkBlue)),
              const SizedBox(height: 8),
              const Text('Your private archive is curated and ready for today\'s exploration.', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),

              // --- SEARCH BAR (Berfungsi sebagai tombol pindah halaman) ---
              GestureDetector(
                onTap: widget.onNavigateToSearch, // Eksekusi fungsi remote dari Dashboard
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(color: const Color(0xFFF3F4F6), borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: const [
                      Icon(Icons.search, color: Colors.grey),
                      SizedBox(width: 8),
                      Text('Tap to search titles or authors...', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // --- TRENDING LIBRARY SECTION ---
              const Text('SELECTED WORKS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.teal, letterSpacing: 1.5)),
              const Text('Trending Library', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryDarkBlue)),
              const SizedBox(height: 16),
              
              SizedBox(
                height: 280,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: trendingBooks.length,
                  itemBuilder: (context, index) {
                    return _buildTrendingCard(trendingBooks[index], context);
                  },
                ),
              ),
              const SizedBox(height: 32),

              // --- RECOMMENDED READING SECTION ---
              const Text('TAILORED FOR YOU', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.teal, letterSpacing: 1.5)),
              const Text('Recommended Reading', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryDarkBlue)),
              const SizedBox(height: 16),

              ...recommendedBooks.map((book) => _buildRecommendedCard(book, context)),
            ],
          ),
        ),
      ),
    );
  }

  // Menambahkan context agar bisa menggunakan Navigator
  Widget _buildTrendingCard(Book book, BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Pindah ke halaman detail saat diklik
        Navigator.push(context, MaterialPageRoute(builder: (_) => BookDetailScreen(bookCode: book.bookCode)));
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              // Menampilkan gambar dari URL (Pastikan URL gambar valid)
              child: Image.network(book.coverUrl, height: 220, width: 160, fit: BoxFit.cover, 
                // Error handling kalau link gambar rusak
                errorBuilder: (context, error, stackTrace) => Container(height: 220, width: 160, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 8),
            Text(book.bookTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(book.autName, style: const TextStyle(color: Colors.grey, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendedCard(Book book, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => BookDetailScreen(bookCode: book.bookCode)));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(book.coverUrl, width: 70, height: 100, fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(width: 70, height: 100, color: Colors.grey),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(book.bookTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 4),
                  Text(book.autName, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}