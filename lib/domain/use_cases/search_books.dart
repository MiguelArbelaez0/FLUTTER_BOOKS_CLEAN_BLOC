import '../entities/book.dart';
import '../repositories/book_repository.dart';

class SearchBooks {
  const SearchBooks(this._repository);
  final BookRepository _repository;
  Future<List<Book>> call(String query, {int page = 1, int limit = 20}) =>
      _repository.search(query, page: page, limit: limit);
}
