import '../entities/book.dart';

abstract interface class BookRepository {
  Future<List<Book>> search(String query, {int page = 1, int limit = 20});
  Future<List<Book>> favorites();
  Future<void> toggleFavorite(Book book);
  Future<bool> isFavorite(String id);
}
