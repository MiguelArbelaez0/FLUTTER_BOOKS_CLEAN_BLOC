import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_books_clean_bloc/domain/entities/book.dart';
import 'package:flutter_books_clean_bloc/domain/repositories/book_repository.dart';
import 'package:flutter_books_clean_bloc/presentation/library_cubit.dart';
import 'package:flutter_books_clean_bloc/presentation/library_app.dart';

class Repository implements BookRepository {
  final requests = <Completer<List<Book>>>[];
  bool failSave = false;
  @override
  Future<List<Book>> search(String query, {int page = 1, int limit = 20}) {
    final pending = Completer<List<Book>>();
    requests.add(pending);
    return pending.future;
  }

  @override
  Future<List<Book>> favorites() async => [
    const Book(id: 'saved', title: 'Saved'),
  ];
  @override
  Future<bool> isFavorite(String id) async => id == 'saved';
  @override
  Future<void> toggleFavorite(Book book) async {
    if (failSave) throw StateError('Disk full');
  }
}

void main() {
  test('latest search wins and clearing blocks pagination', () async {
    final repo = Repository();
    final cubit = LibraryCubit(repo);
    addTearDown(cubit.close);
    final first = cubit.search('old');
    final second = cubit.search('new');
    repo.requests[1].complete([const Book(id: 'new', title: 'New')]);
    await second;
    repo.requests[0].complete([const Book(id: 'old', title: 'Old')]);
    await first;
    expect(cubit.state.results.single.id, 'new');
    await cubit.search('  ');
    await cubit.loadMore();
    expect(repo.requests, hasLength(2));
    expect(cubit.state.loadingMore, false);
  });
  test('home cannot overwrite search; favorites load before network', () async {
    final repo = Repository();
    final cubit = LibraryCubit(repo);
    addTearDown(cubit.close);
    final home = cubit.loadHome();
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.favorites.single.id, 'saved');
    final search = cubit.search('new');
    repo.requests.last.complete([const Book(id: 'new', title: 'New')]);
    await search;
    for (final pending in repo.requests.take(4)) {
      pending.complete([]);
    }
    await home;
    expect(cubit.state.results.single.id, 'new');
  });
  test(
    'safe completion after close and favorite failure is reported',
    () async {
      final repo = Repository()..failSave = true;
      final cubit = LibraryCubit(repo);
      expect(
        await cubit.toggleFavorite(const Book(id: 'a', title: 'A')),
        false,
      );
      expect(cubit.state.favoriteError, isNotNull);
      final search = cubit.search('book');
      await cubit.close();
      repo.requests.single.complete([]);
      await search;
    },
  );
  test('network failure preserves favorites and can be retried', () async {
    final repo = Repository();
    final cubit = LibraryCubit(repo);
    addTearDown(cubit.close);
    final home = cubit.loadHome();
    await Future<void>.delayed(Duration.zero);
    for (final pending in repo.requests) {
      pending.completeError(StateError('offline'));
    }
    await home;
    expect(cubit.state.loading, false);
    expect(cubit.state.error, isNotNull);
    expect(cubit.state.favorites.single.id, 'saved');
    final retry = cubit.search('retry');
    repo.requests.last.complete([]);
    await retry;
    expect(cubit.state.error, isNull);
  });
  test(
    'pagination failure retains results and retries the same page once',
    () async {
      final repo = Repository();
      final cubit = LibraryCubit(repo);
      addTearDown(cubit.close);
      final first = cubit.search('books');
      repo.requests.last.complete(
        List.generate(20, (i) => Book(id: '$i', title: '$i')),
      );
      await first;
      final more = cubit.loadMore();
      await cubit.loadMore();
      expect(repo.requests, hasLength(2));
      repo.requests.last.completeError(StateError('offline'));
      await more;
      expect(cubit.state.page, 1);
      expect(cubit.state.results, hasLength(20));
      final retry = cubit.loadMore();
      repo.requests.last.complete([const Book(id: 'last', title: 'Last')]);
      await retry;
      expect(cubit.state.page, 2);
      expect(cubit.state.results, hasLength(21));
      expect(cubit.state.hasMore, false);
    },
  );
  testWidgets('empty results, debounce cancellation and offline favorites', (
    tester,
  ) async {
    final repo = Repository();
    final cubit = LibraryCubit(repo);
    addTearDown(cubit.close);
    await cubit.loadFavorites();
    await tester.pumpWidget(
      BlocProvider.value(value: cubit, child: const BookishApp()),
    );
    await tester.tap(find.text('Buscar'));
    await tester.pumpAndSettle();
    final field = find.byType(TextField).hitTestable();
    await tester.enterText(field, 'missing');
    await tester.pump(const Duration(milliseconds: 500));
    repo.requests.single.complete([]);
    await tester.pumpAndSettle();
    expect(find.textContaining('No encontramos libros'), findsOneWidget);
    await tester.enterText(field, 'pending');
    await tester.tap(find.byIcon(Icons.close).hitTestable());
    await tester.pump(const Duration(milliseconds: 500));
    expect(repo.requests, hasLength(1));
    await tester.tap(find.text('Favoritos'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Saved').first);
    await tester.pumpAndSettle();
    expect(find.text('Detalle del libro'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
