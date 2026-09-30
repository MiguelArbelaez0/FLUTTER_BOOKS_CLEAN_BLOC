import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_auth_clean_bloc/domain/entities/book.dart';

void main() {
  group('Book', () {
    test('parses Open Library fields and builds a cover URL', () {
      final book = Book.fromJson({
        'key': '/works/OL123W',
        'title': 'The Left Hand of Darkness',
        'author_name': ['Ursula K. Le Guin'],
        'cover_i': 12345,
        'first_publish_year': 1969,
        'edition_count': 42,
        'isbn': ['9780441478125'],
        'subject': ['Science fiction', 'Gender identity'],
      });
      expect(book.id, '/works/OL123W');
      expect(book.authorLabel, 'Ursula K. Le Guin');
      expect(book.coverUrl, 'https://covers.openlibrary.org/b/id/12345-L.jpg');
      expect(book.editionCount, 42);
      expect(book.subjects, contains('Science fiction'));
    });

    test('uses safe defaults when API fields are missing', () {
      final book = Book.fromJson({'key': '/works/OL0W'});
      expect(book.title, 'Sin título');
      expect(book.authorLabel, 'Autor desconocido');
      expect(book.coverUrl, isNull);
      expect(book.firstPublishYear, isNull);
      expect(Book.fromJson(book.toJson()).id, book.id);
    });
  });
}
