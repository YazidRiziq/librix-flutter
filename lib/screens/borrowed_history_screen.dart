import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../models/book_model.dart'; // Import model yang baru kita buat

class BorrowedHistoryScreen extends StatefulWidget {
  const BorrowedHistoryScreen({super.key});

  @override
  State<BorrowedHistoryScreen> createState() => _BorrowedHistoryScreenState();
}

class _BorrowedHistoryScreenState extends State<BorrowedHistoryScreen> {
  final ApiService _apiService = ApiService();
  
  List<LoanHistory> activeLoans = [];
  List<LoanHistory> pastReads = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final memID = prefs.getString('memID') ?? '';

    if (memID.isEmpty) {
      setState(() => isLoading = false);
      return;
    }

    try {
      final response = await _apiService.get('/books/history/$memID');
      if (response.statusCode == 200) {
        final List<dynamic> jsonList = jsonDecode(response.body);
        final List<LoanHistory> allHistory = jsonList.map((json) => LoanHistory.fromJson(json)).toList();

        setState(() {
          // Filter data masuk ke Active Loans jika status belum dikembalikan
          activeLoans = allHistory.where((loan) => 
            loan.statusBadge.toLowerCase() == 'active' || 
            loan.statusBadge.toLowerCase() == 'overdue' ||
            loan.actualReturnDate == null
          ).toList();

          // Filter sisanya masuk ke Past Reads
          pastReads = allHistory.where((loan) => 
            loan.statusBadge.toLowerCase() == 'returned' || 
            loan.actualReturnDate != null
          ).toList();
        });
      }
    } catch (e) {
      print('Error fetching history: $e');
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryDarkBlue = Color(0xFF111860);
    const Color bgColor = Color(0xFFF9FAFB);

    // Membungkus layar dengan TabController (2 Tabs)
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: bgColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: primaryDarkBlue),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('My Borrowed Books', style: TextStyle(color: primaryDarkBlue, fontSize: 16, fontWeight: FontWeight.bold)),
          centerTitle: true,
          // TabBar diletakkan di bawah AppBar
          bottom: const TabBar(
            labelColor: primaryDarkBlue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: primaryDarkBlue,
            tabs: [
              Tab(text: 'ACTIVE LOANS'),
              Tab(text: 'PAST READS'),
            ],
          ),
        ),
        body: isLoading 
          ? const Center(child: CircularProgressIndicator())
          : TabBarView( // Isi dari masing-masing tab
              children: [
                _buildActiveLoansList(), // Layar 1
                _buildPastReadsList(),   // Layar 2
              ],
            ),
      ),
    );
  }

  // --- LAYAR 1: DAFTAR BUKU YANG SEDANG DIPINJAM ---
  Widget _buildActiveLoansList() {
    if (activeLoans.isEmpty) {
      return const Center(child: Text('No active loans right now.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: activeLoans.length,
      itemBuilder: (context, index) {
        final loan = activeLoans[index];
        // Warna badge dinamis: Merah jika Overdue, Hijau/Teal jika Active
        final bool isOverdue = loan.statusBadge.toLowerCase() == 'overdue';
        final Color badgeColor = isOverdue ? Colors.redAccent : Colors.teal;

        // Desain Kartu Premium (Mirip desain profil awalmu)
        return Container(
          margin: const EdgeInsets.only(bottom: 24),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF111860), // Background Biru Gelap
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 8))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Gambar Cover
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(loan.coverUrl, width: 80, height: 120, fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) => Container(width: 80, height: 120, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Label Status
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(12)),
                          child: Text(loan.statusBadge.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 12),
                        Text(loan.title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 4),
                        Text('by ${loan.author}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                      ],
                    ),
                  )
                ],
              ),
              const SizedBox(height: 20),
              // Garis pemisah tipis
              Divider(color: Colors.white.withOpacity(0.2)),
              const SizedBox(height: 8),
              // Tanggal peminjaman
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Borrowed Date', style: TextStyle(color: Colors.white54, fontSize: 10)),
                      const SizedBox(height: 2),
                      Text(loan.borrowedDate, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Due Date', style: TextStyle(color: Colors.white54, fontSize: 10)),
                      const SizedBox(height: 2),
                      Text(loan.dueDate, style: TextStyle(color: isOverdue ? Colors.redAccent : Colors.tealAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  // --- LAYAR 2: DAFTAR BUKU YANG SUDAH SELESAI ---
  Widget _buildPastReadsList() {
    if (pastReads.isEmpty) {
      return const Center(child: Text('No past reading history yet.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: pastReads.length,
      itemBuilder: (context, index) {
        final loan = pastReads[index];
        // Desain Kartu Sederhana Putih
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(loan.coverUrl, width: 60, height: 90, fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) => Container(width: 60, height: 90, color: Colors.grey),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(loan.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF111860)), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(loan.author, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.grey, size: 14),
                        const SizedBox(width: 4),
                        // Menampilkan actualReturnDate jika ada
                        Text('Returned: ${loan.actualReturnDate ?? loan.dueDate}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}