class Book {
  final String bookCode;
  final String bookTitle;
  final String autName;
  final String coverUrl;

  Book({
    required this.bookCode,
    required this.bookTitle,
    required this.autName,
    required this.coverUrl,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      bookCode: json['bookCode'] ?? '',
      bookTitle: json['bookTitle'] ?? 'Unknown Title',
      autName: json['autName'] ?? 'Unknown Author',
      coverUrl: json['cover_url'] ?? 'https://placehold.co/400x600/png',
    );
  }
}

class BookDetail {
  final String bookCode;
  final String catName;
  final String bookTitle;
  final String isbn;
  final String autName;
  final String publisher;
  final int pubYear;
  final int numPages;
  final String coverUrl;
  final String synopsis;

  BookDetail({
    required this.bookCode,
    required this.catName,
    required this.bookTitle,
    required this.isbn,
    required this.autName,
    required this.publisher,
    required this.pubYear,
    required this.numPages,
    required this.coverUrl,
    required this.synopsis,
  });

  factory BookDetail.fromJson(Map<String, dynamic> json) {
    return BookDetail(
      bookCode: json['bookCode'] ?? '',
      catName: json['catName'] ?? 'Uncategorized',
      bookTitle: json['bookTitle'] ?? 'Unknown Title',
      isbn: json['isbn'] ?? '-',
      autName: json['autName'] ?? 'Unknown Author',
      publisher: json['publisher'] ?? 'Unknown Publisher',
      pubYear: json['pubYear'] ?? 0,
      numPages: json['numPages'] ?? 0,
      coverUrl: json['cover_url'] ?? 'https://placehold.co/400x600/png',
      synopsis: json['synopsis'] ?? 'No synopsis available.',
    );
  }
}

class LoanHistory {
  final String memID;
  final String loanCode;
  final String title;
  final String author;
  final String coverUrl;
  final String? actualReturnDate;
  final String borrowedDate;
  final String dueDate;
  final String statusBadge;

  LoanHistory({
    required this.memID,
    required this.loanCode,
    required this.title,
    required this.author,
    required this.coverUrl,
    this.actualReturnDate,
    required this.borrowedDate,
    required this.dueDate,
    required this.statusBadge,
  });

  factory LoanHistory.fromJson(Map<String, dynamic> json) {
    return LoanHistory(
      memID: json['memID'] ?? '',
      loanCode: json['loanCode'] ?? '',
      title: json['title'] ?? 'Unknown Title',
      author: json['author'] ?? 'Unknown Author',
      coverUrl: json['cover_url'] ?? 'https://placehold.co/400x600/png',
      actualReturnDate: json['actualReturnDate'],
      borrowedDate: json['borrowedDate'] ?? '-',
      dueDate: json['dueDate'] ?? '-',
      statusBadge: json['statusBadge'] ?? 'Unknown',
    );
  }
}