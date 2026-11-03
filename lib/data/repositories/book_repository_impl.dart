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
  Future<void> _writes = Future.value();

  @override
  Future<void> toggleFavorite(Book book) {
    final operation = _writes.then((_) => _saveToggle(book));
    _writes = operation.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {},
    );
    return operation;
  }

  Future<void> _saveToggle(Book book) async {
    if (book.id.trim().isEmpty) throw ArgumentError.value(book.id, 'id');
    final books = local.readFavorites();
    if (books.any((item) => item.id == book.id)) {
      books.removeWhere((item) => item.id == book.id);
    } else {
      books.insert(0, book);
    }
    await local.saveFavorites(books);
  }
}
