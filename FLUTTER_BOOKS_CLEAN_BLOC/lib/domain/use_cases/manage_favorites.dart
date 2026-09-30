import '../entities/book.dart';
import '../repositories/book_repository.dart';

class GetFavorites {
  const GetFavorites(this._repository);
  final BookRepository _repository;
  Future<List<Book>> call() => _repository.favorites();
}

class ToggleFavorite {
  const ToggleFavorite(this._repository);
  final BookRepository _repository;
  Future<void> call(Book book) => _repository.toggleFavorite(book);
}
