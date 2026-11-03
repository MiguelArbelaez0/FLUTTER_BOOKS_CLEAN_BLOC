import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_books_clean_bloc/data/datasources/book_local_data_source.dart';
import 'package:flutter_books_clean_bloc/data/datasources/book_remote_data_source.dart';
import 'package:flutter_books_clean_bloc/data/repositories/book_repository_impl.dart';
import 'package:flutter_books_clean_bloc/domain/entities/book.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('encodes queries and pagination with HTTPS', () async {
    final client = MockClient((request) async {
      expect(request.url.scheme, 'https');
      expect(request.url.queryParameters['q'], 'a & b');
      expect(request.url.queryParameters['page'], '2');
      return http.Response(
        jsonEncode({
          'docs': [
            {'key': '/works/1', 'title': 'Book'},
          ],
        }),
        200,
      );
    });
    addTearDown(client.close);
    final books = await BookRemoteDataSource(
      client: client,
    ).search(' a & b ', page: 2);
    expect(books.single.id, '/works/1');
  });
  for (final body in ['invalid', '[]', '{}', '{"docs":null}', '{"docs":{}}']) {
    test('rejects malformed response $body', () async {
      final client = MockClient((_) async => http.Response(body, 200));
      addTearDown(client.close);
      await expectLater(
        BookRemoteDataSource(client: client).search('book'),
        throwsA(isA<BookApiException>()),
      );
    });
  }
  test('rejects HTTP failures and times out', () async {
    final client = MockClient((_) async => http.Response('', 429));
    addTearDown(client.close);
    await expectLater(
      BookRemoteDataSource(client: client).search('book'),
      throwsA(isA<BookApiException>()),
    );
    final slow = MockClient((_) => Completer<http.Response>().future);
    addTearDown(slow.close);
    await expectLater(
      BookRemoteDataSource(
        client: slow,
        timeout: const Duration(milliseconds: 5),
      ).search('book'),
      throwsA(isA<TimeoutException>()),
    );
  });
  for (final value in [
    'invalid',
    '{}',
    123,
    '[{"id":"a"},{"id":"a"},{"id":123},null]',
  ]) {
    test(
      'recovers favorites from malformed or duplicate data: $value',
      () async {
        SharedPreferences.setMockInitialValues({'bookish_favorites_v1': value});
        final local = BookLocalDataSource(
          await SharedPreferences.getInstance(),
        );
        expect(
          local.readFavorites().length,
          value.toString().startsWith('[') ? 1 : 0,
        );
      },
    );
  }
  test(
    'serializes concurrent favorite writes and persists across reload',
    () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final client = MockClient((_) async => http.Response('{"docs":[]}', 200));
      addTearDown(client.close);
      final repo = BookRepositoryImpl(
        remote: BookRemoteDataSource(client: client),
        local: BookLocalDataSource(prefs),
      );
      const a = Book(id: 'a', title: 'A');
      const b = Book(id: 'b', title: 'B');
      await Future.wait([repo.toggleFavorite(a), repo.toggleFavorite(b)]);
      await prefs.reload();
      expect((await repo.favorites()).map((book) => book.id), ['b', 'a']);
      await Future.wait([repo.toggleFavorite(a), repo.toggleFavorite(a)]);
      expect(await repo.favorites(), hasLength(2));
    },
  );
}
