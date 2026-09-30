import '../../domain/entities/book.dart';
import '../../domain/repositories/book_repository.dart';
import '../datasources/book_local_data_source.dart';
import '../datasources/book_remote_data_source.dart';

class BookRepositoryImpl implements BookRepository {
  BookRepositoryImpl({required this.remote, required this.local});
  final BookRemoteDataSource remote;
  final BookLocalDataSource local;

  @override
  Future<List<Book>> search(String query, {int page = 1, int limit = 20}) =>
      remote.search(query, page: page, limit: limit);
  @override
  Future<List<Book>> favorites() async => local.readFavorites();
  @override
  Future<bool> isFavorite(String id) async =>
      local.readFavorites().any((book) => book.id == id);
  @override
  Future<void> toggleFavorite(Book book) async {
    final books = local.readFavorites();
    if (books.any((item) => item.id == book.id)) {
      books.removeWhere((item) => item.id == book.id);
    } else {
      books.insert(0, book);
    }
    await local.saveFavorites(books);
  }
}
