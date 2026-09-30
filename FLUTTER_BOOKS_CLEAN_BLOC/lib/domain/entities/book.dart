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

  Map<String, Object?> toJson() => {
    'id': id,
    'title': title,
    'authors': authors,
    'coverId': coverId,
    'firstPublishYear': firstPublishYear,
    'editionCount': editionCount,
    'isbn': isbn,
    'subjects': subjects,
  };

  factory Book.fromJson(Map<String, dynamic> json) => Book(
    id: json['id'] as String? ?? json['key'] as String? ?? '',
    title: json['title'] as String? ?? 'Sin título',
    authors: _strings(json['authors'] ?? json['author_name']),
    coverId: _integer(json['coverId'] ?? json['cover_i']),
    firstPublishYear: _integer(
      json['firstPublishYear'] ?? json['first_publish_year'],
    ),
    editionCount: _integer(json['editionCount'] ?? json['edition_count']),
    isbn: _strings(json['isbn']),
    subjects: _strings(json['subjects'] ?? json['subject']),
  );

  static int? _integer(Object? value) =>
      value is num ? value.toInt() : int.tryParse('$value');
  static List<String> _strings(Object? value) => value is List
      ? value.whereType<String>().where((item) => item.isNotEmpty).toList()
      : const [];
}
