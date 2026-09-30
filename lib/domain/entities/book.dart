class Book {
  const Book({
    required this.id,
    required this.title,
    this.authors = const [],
    this.coverId,
    this.firstPublishYear,
    this.editionCount,
    this.isbn = const [],
    this.subjects = const [],
  });

  final String id;
  final String title;
  final List<String> authors;
  final int? coverId;
  final int? firstPublishYear;
  final int? editionCount;
  final List<String> isbn;
  final List<String> subjects;

  String get authorLabel =>
      authors.isEmpty ? 'Autor desconocido' : authors.join(', ');
  String? get coverUrl => coverId == null
      ? null
      : 'https://covers.openlibrary.org/b/id/$coverId-L.jpg';
}
