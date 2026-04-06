import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/book_model.dart';
import 'book_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController searchController = TextEditingController();
  
  List<Book> displayBooks = [];
  bool isLoading = true;
  bool isSearching = false; // Status apakah sedang melihat hasil pencarian atau default

  @override
  void initState() {
    super.initState();
    _fetchRandomBooks();
  }

  // Fungsi untuk layar default (3 buku random)
  Future<void> _fetchRandomBooks() async {
    try {
      final response = await _apiService.get('/books/dashboard');
      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body);
        List<Book> allBooks = jsonList.map((json) => Book.fromJson(json)).toList();
        
        // Acak urutan buku lalu ambil 3
        allBooks.shuffle();
        
        setState(() {
          displayBooks = allBooks.take(3).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  // Fungsi saat user menekan Enter di keyboard
  Future<void> _executeSearch(String query) async {
    if (query.trim().isEmpty) return; // Abaikan jika input kosong

    setState(() {
      isLoading = true;
      isSearching = true; // Mode pencarian aktif
    });

    try {
      // Memanggil API spesifik untuk pencarian
      final response = await _apiService.get('/books/dashboard/$query');
      if (response.statusCode == 200) {
        List<dynamic> jsonList = jsonDecode(response.body);
        setState(() {
          displayBooks = jsonList.map((json) => Book.fromJson(json)).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryDarkBlue = Color(0xFF111860);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Explore the Archive', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryDarkBlue)),
            const SizedBox(height: 16),

            // --- SEARCH INPUT ---
            TextField(
              controller: searchController,
              // onSubmitted dieksekusi saat user menekan enter di keyboard HP
              onSubmitted: (value) => _executeSearch(value),
              decoration: InputDecoration(
                hintText: 'Search titles or authors...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: isSearching ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    // Tombol X untuk reset pencarian
                    searchController.clear();
                    setState(() => isSearching = false);
                    _fetchRandomBooks();
                  },
                ) : null,
                filled: true,
                fillColor: const Color(0xFFF3F4F6),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isSearching ? 'Search Results' : 'Discover Random Books', 
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryDarkBlue)
                    ),
                    if (isSearching) // Tampilkan jumlah hasil hanya jika sedang mencari
                      Text('Found ${displayBooks.length} items', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Expanded digunakan karena ListView berada di dalam Column
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : displayBooks.isEmpty 
                      ? const Center(child: Text("No books found."))
                      : ListView.builder(
                          itemCount: displayBooks.length,
                          itemBuilder: (context, index) {
                            return _buildResultCard(displayBooks[index], context);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(Book book, BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => BookDetailScreen(bookCode: book.bookCode)));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(book.coverUrl, height: 450, width: 300, fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(height: 250, width: double.infinity, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 12),
            Text(book.bookTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(book.autName, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}