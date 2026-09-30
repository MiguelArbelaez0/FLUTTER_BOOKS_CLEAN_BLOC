import 'package:flutter_bloc/flutter_bloc.dart';

import '../domain/entities/book.dart';
import '../domain/repositories/book_repository.dart';
import '../domain/use_cases/manage_favorites.dart';
import '../domain/use_cases/search_books.dart';

class LibraryState {
  const LibraryState({
    this.sections = const {},
    this.results = const [],
    this.favorites = const [],
    this.loading = false,
    this.loadingMore = false,
    this.error,
    this.query = '',
    this.page = 1,
    this.hasMore = true,
  });
  final Map<String, List<Book>> sections;
  final List<Book> results;
  final List<Book> favorites;
  final bool loading;
  final bool loadingMore;
  final String? error;
  final String query;
  final int page;
  final bool hasMore;

  LibraryState copyWith({
    Map<String, List<Book>>? sections,
    List<Book>? results,
    List<Book>? favorites,
    bool? loading,
    bool? loadingMore,
    String? error,
    bool clearError = false,
    String? query,
    int? page,
    bool? hasMore,
  }) => LibraryState(
    sections: sections ?? this.sections,
    results: results ?? this.results,
    favorites: favorites ?? this.favorites,
    loading: loading ?? this.loading,
    loadingMore: loadingMore ?? this.loadingMore,
    error: clearError ? null : error ?? this.error,
    query: query ?? this.query,
    page: page ?? this.page,
    hasMore: hasMore ?? this.hasMore,
  );
}

class LibraryCubit extends Cubit<LibraryState> {
  LibraryCubit(BookRepository repository)
    : _searchBooks = SearchBooks(repository),
      _getFavorites = GetFavorites(repository),
      _toggleFavorite = ToggleFavorite(repository),
      super(const LibraryState());
  final SearchBooks _searchBooks;
  final GetFavorites _getFavorites;
  final ToggleFavorite _toggleFavorite;
  static const pageSize = 20;
  int _requestId = 0;

  Future<void> loadHome() async {
    emit(state.copyWith(loading: true, clearError: true));
    try {
      final queries = await Future.wait([
        _searchBooks('bestselling books', limit: 12),
        _searchBooks('popular fiction', limit: 12),
        _searchBooks('award winning novels', limit: 12),
        _searchBooks('fiction', limit: pageSize),
      ]);
      emit(
        state.copyWith(
          sections: {
            'Destacados': queries[0],
            'En tendencia': queries[1],
            'Recomendados para ti': queries[2],
          },
          results: queries[3],
          page: 1,
          hasMore: queries[3].length == pageSize,
          loading: false,
          clearError: true,
        ),
      );
      await loadFavorites();
    } catch (error) {
      emit(state.copyWith(loading: false, error: _message(error)));
    }
  }

  Future<void> search(String query, {bool replace = true}) async {
    final requestId = ++_requestId;
    if (query.trim().isEmpty) {
      emit(
        state.copyWith(
          query: query,
          results: const [],
          loading: false,
          clearError: true,
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        query: query,
        loading: replace,
        loadingMore: !replace,
        clearError: true,
      ),
    );
    try {
      final page = replace ? 1 : state.page + 1;
      final books = await _searchBooks(query, page: page, limit: pageSize);
      if (requestId != _requestId) return;
      final previous = replace ? <Book>[] : state.results;
      final seen = previous.map((book) => book.id).toSet();
      final fresh = books
          .where((book) => book.id.isNotEmpty && seen.add(book.id))
          .toList();
      emit(
        state.copyWith(
          results: [...previous, ...fresh],
          page: page,
          hasMore: books.length == pageSize && fresh.isNotEmpty,
          loading: false,
          loadingMore: false,
          clearError: true,
        ),
      );
    } catch (error) {
      if (requestId != _requestId) return;
      emit(
        state.copyWith(
          loading: false,
          loadingMore: false,
          error: _message(error),
        ),
      );
    }
  }

  Future<void> loadMore() async {
    if (state.loading || state.loadingMore || !state.hasMore) return;
    await search(state.query.isEmpty ? 'fiction' : state.query, replace: false);
  }

  Future<void> loadFavorites() async =>
      emit(state.copyWith(favorites: await _getFavorites()));

  Future<void> toggleFavorite(Book book) async {
    await _toggleFavorite(book);
    await loadFavorites();
  }

  bool isFavorite(String id) => state.favorites.any((book) => book.id == id);
  String _message(Object error) {
    final message = error.toString();
    if (message.contains('Open Library')) return message;
    return 'No se pudieron cargar los libros. Comprueba tu conexión e inténtalo de nuevo.';
  }
}
