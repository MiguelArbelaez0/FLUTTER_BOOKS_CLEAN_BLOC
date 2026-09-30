import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_auth_clean_bloc/domain/entities/book.dart';
import 'package:flutter_auth_clean_bloc/domain/repositories/book_repository.dart';
import 'package:flutter_auth_clean_bloc/presentation/library_cubit.dart';

void main() {
  late _FakeBookRepository repository;
  late LibraryCubit cubit;

  setUp(() {
    repository = _FakeBookRepository();
    cubit = LibraryCubit(repository);
  });
  tearDown(() => cubit.close());

  test('searches results and paginates without duplicate works', () async {
    await cubit.search('fantasy');
    expect(cubit.state.results, hasLength(20));

    await cubit.loadMore();
    expect(cubit.state.page, 2);
    expect(cubit.state.results, hasLength(39));
    expect(cubit.state.results.map((book) => book.id).toSet(), hasLength(39));
  });

  test('toggles a favorite in repository state', () async {
    await cubit.toggleFavorite(_book('/works/1'));
    expect(cubit.state.favorites.single.title, 'Book /works/1');

    await cubit.toggleFavorite(_book('/works/1'));
    expect(cubit.state.favorites, isEmpty);
  });
}

Book _book(String id) => Book(id: id, title: 'Book $id');

class _FakeBookRepository implements BookRepository {
  final List<Book> saved = [];

  @override
  Future<List<Book>> search(
    String query, {
    int page = 1,
    int limit = 20,
  }) async => switch (page) {
    1 => [
      _book('/works/1'),
      _book('/works/2'),
      ...List.generate(18, (i) => _book('/works/${i + 3}')),
    ],
    2 => [
      _book('/works/2'),
      ...List.generate(19, (i) => _book('/works/${i + 21}')),
    ],
    _ => [],
  };

  @override
  Future<List<Book>> favorites() async => List.of(saved);

  @override
  Future<bool> isFavorite(String id) async =>
      saved.any((book) => book.id == id);

  @override
  Future<void> toggleFavorite(Book book) async {
    if (await isFavorite(book.id)) {
      saved.removeWhere((item) => item.id == book.id);
    } else {
      saved.add(book);
    }
  }
}
